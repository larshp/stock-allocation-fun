CLASS zcl_demand_aging DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    "! Nobody moves up the queue for waiting, which is what a plant gets until
    "! it asks for it.
    CONSTANTS c_never TYPE i VALUE 0.

    "! The front of the queue. A line cannot move past it however long it has
    "! been waiting.
    CONSTANTS c_first TYPE zif_allocation=>ty_priority VALUE '01'.

    "! <p class="shorttext synchronized">Move a line up the queue for having waited</p>
    "!
    "! Priority alone is a stable order, and a stable order starves the bottom
    "! of it: a line behind a customer that orders every week is behind it
    "! every week, and a run that is short every night is short for the same
    "! lines every night. Nobody notices, because each run on its own looks
    "! like a reasonable answer.
    "!
    "! This is the correction. A line that has been short in every run for as
    "! long as the plant is prepared to let anybody wait moves up one place,
    "! and another place for every further wait of the same length, until it
    "! is at the front. Waiting is thereby a thing the run can see, rather
    "! than something a planner discovers when the customer rings.
    "!
    "! @parameter io_demand | <p class="shorttext synchronized">Reader of the demand as the documents have it</p>
    "! @parameter iv_days   | <p class="shorttext synchronized">Wait that earns a place, 0 for none</p>
    METHODS constructor
      IMPORTING
        io_demand TYPE REF TO zif_demand_reader
        iv_days   TYPE i DEFAULT c_never.

  PRIVATE SECTION.

    "! The recorded runs are stamped in UTC, as ZCL_ALLOC_HOUSEKEEPING writes
    "! them, so the age of one is worked out in the same zone.
    CONSTANTS c_time_zone TYPE timezone VALUE 'UTC'.

    "! One recorded line. Declared explicitly rather than inferred with
    "! INTO TABLE @DATA(), see ANOMALIES.md.
    TYPES:
      BEGIN OF ty_recorded,
        demand_id  TYPE zstock_alloc_res-demand_id,
        created_at TYPE zstock_alloc_res-created_at,
        shortfall  TYPE zstock_alloc_res-shortfall,
      END OF ty_recorded.
    TYPES ty_recorded_tab TYPE STANDARD TABLE OF ty_recorded WITH EMPTY KEY.

    "! Since when one line has been short in every run.
    TYPES:
      BEGIN OF ty_waiting,
        demand_id TYPE zstock_alloc_res-demand_id,
        since     TYPE d,
      END OF ty_waiting.
    TYPES ty_waiting_tab TYPE STANDARD TABLE OF ty_waiting WITH EMPTY KEY.

    DATA mo_demand TYPE REF TO zif_demand_reader.
    DATA mv_days   TYPE i.

    METHODS waiting_since
      IMPORTING
        iv_matnr          TYPE mard-matnr
        iv_werks          TYPE mard-werks
      RETURNING
        VALUE(rt_waiting) TYPE ty_waiting_tab.

    METHODS unbroken_run_of_short
      IMPORTING
        it_recorded       TYPE ty_recorded_tab
      RETURNING
        VALUE(rt_waiting) TYPE ty_waiting_tab.

    METHODS moved_up
      IMPORTING
        iv_priority        TYPE zif_allocation=>ty_priority
        iv_since           TYPE d
      RETURNING
        VALUE(rv_priority) TYPE zif_allocation=>ty_priority.

ENDCLASS.


CLASS zcl_demand_aging IMPLEMENTATION.

  METHOD constructor.

    mo_demand = io_demand.
    mv_days   = iv_days.

  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.

    rt_demand = mo_demand->read_open_demand(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    IF mv_days <= c_never OR rt_demand IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lt_waiting) = waiting_since(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).
    IF lt_waiting IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT rt_demand ASSIGNING FIELD-SYMBOL(<ls_demand>).

      READ TABLE lt_waiting INTO DATA(ls_waiting)
        WITH KEY demand_id = <ls_demand>-demand_id.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      <ls_demand>-priority = moved_up(
        iv_priority = <ls_demand>-priority
        iv_since    = ls_waiting-since ).

    ENDLOOP.

  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.

    " how long a line has waited does not change whether the material is worth
    " looking at: it is waiting because the run keeps looking at it
    rt_matnr = mo_demand->materials_with_demand( iv_werks ).

  ENDMETHOD.

  METHOD waiting_since.

    DATA lt_recorded TYPE ty_recorded_tab.

    " every recorded line of the material, newest first: what is wanted is the
    " run of shortfalls at the near end, and a run that served a line in full
    " ends it. Read in one go per material, which is what the netting in
    " feature 12 does with the same table.
    SELECT demand_id,
           created_at,
           shortfall
      FROM zstock_alloc_res
      WHERE matnr = @iv_matnr
        AND werks = @iv_werks
      ORDER BY demand_id ASCENDING, created_at DESCENDING
      INTO TABLE @lt_recorded.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    rt_waiting = unbroken_run_of_short( lt_recorded ).

  ENDMETHOD.

  METHOD unbroken_run_of_short.

    DATA lv_demand_id TYPE zstock_alloc_res-demand_id.
    DATA lv_ended     TYPE abap_bool.
    DATA lv_date      TYPE d.
    DATA ls_waiting   TYPE ty_waiting.

    LOOP AT it_recorded INTO DATA(ls_recorded).

      IF ls_recorded-demand_id <> lv_demand_id.
        lv_demand_id = ls_recorded-demand_id.
        lv_ended     = abap_false.
      ENDIF.

      " a run that served the line in full ends its wait: what came before
      " that was a different wait, and it is over
      IF lv_ended = abap_true.
        CONTINUE.
      ENDIF.

      IF ls_recorded-shortfall <= 0.
        lv_ended = abap_true.
        CONTINUE.
      ENDIF.

      CONVERT TIME STAMP ls_recorded-created_at TIME ZONE c_time_zone
        INTO DATE lv_date.

      READ TABLE rt_waiting INTO ls_waiting
        WITH KEY demand_id = ls_recorded-demand_id.
      IF sy-subrc <> 0.
        ls_waiting-demand_id = ls_recorded-demand_id.
        ls_waiting-since     = lv_date.
        APPEND ls_waiting TO rt_waiting.
        CONTINUE.
      ENDIF.

      " the rows come newest first, so each further short run pushes the start
      " of the wait further back
      IF lv_date < ls_waiting-since.
        ls_waiting-since = lv_date.
        MODIFY rt_waiting FROM ls_waiting
          TRANSPORTING since
          WHERE demand_id = ls_waiting-demand_id.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD moved_up.

    DATA lv_place TYPE i.

    rv_priority = iv_priority.

    IF iv_since IS INITIAL OR iv_since > sy-datum.
      RETURN.
    ENDIF.

    " one place per whole wait: a line that has been short for three weeks
    " where a week earns a place is three places further forward than the
    " order it was typed with
    DATA(lv_steps) = ( sy-datum - iv_since ) DIV mv_days.
    IF lv_steps <= 0.
      RETURN.
    ENDIF.

    lv_place = iv_priority - lv_steps.
    IF lv_place < c_first.
      lv_place = c_first.
    ENDIF.

    rv_priority = lv_place.

  ENDMETHOD.

ENDCLASS.
