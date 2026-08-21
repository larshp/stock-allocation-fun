CLASS zcl_alloc_coverage DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_line_tab  TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    TYPES ty_matnr_tab TYPE STANDARD TABLE OF zstock_alloc_res-matnr WITH EMPTY KEY.

    "! A night, which is what somebody asking this in the morning means.
    CONSTANTS c_default_hours TYPE i VALUE 24.

    "! <p class="shorttext synchronized">Check wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter ro_coverage | <p class="shorttext synchronized">Ready to use check</p>
    CLASS-METHODS create_for_plant
      IMPORTING
        iv_werks           TYPE mard-werks
      RETURNING
        VALUE(ro_coverage) TYPE REF TO zcl_alloc_coverage.

    "! <p class="shorttext synchronized">Wire up the check</p>
    "!
    "! @parameter io_demand    | <p class="shorttext synchronized">Says which materials are waiting for stock</p>
    "! @parameter io_authority | <p class="shorttext synchronized">Decides who may see a plant</p>
    METHODS constructor
      IMPORTING
        io_demand    TYPE REF TO zif_demand_reader
        io_authority TYPE REF TO zif_allocation_authority.

    "! <p class="shorttext synchronized">Which materials the last night did not get to</p>
    "!
    "! A split night is several jobs (feature 97), and the failure they share
    "! is quiet: a job that was never scheduled, or died in its first minute,
    "! leaves a part of the plant unallocated, and nothing in the result
    "! reports says so. A material nobody allocated has no result to be missing
    "! from -- it looks exactly like a material nobody is waiting for.
    "!
    "! This is the other way round: everything waiting for stock, less
    "! everything a run has decided about since a point in time.
    "!
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
    "! @parameter iv_hours       | <p class="shorttext synchronized">How far back a run still counts</p>
    "! @parameter rt_line        | <p class="shorttext synchronized">Lines to display</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">Plant may not be seen, or reading failed</p>
    METHODS run
      IMPORTING
        iv_werks       TYPE mard-werks
        iv_hours       TYPE i DEFAULT c_default_hours
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab
      RAISING
        zcx_allocation.

    "! <p class="shorttext synchronized">The materials a run has already decided about</p>
    "!
    "! Public because a run that carries on where the last one stopped has to
    "! ask exactly the question this report asks, and two implementations of
    "! "already done" would disagree about the material that matters.
    "!
    "! @parameter iv_werks | <p class="shorttext synchronized">Plant</p>
    "! @parameter iv_hours | <p class="shorttext synchronized">How far back a run still counts</p>
    "! @parameter rt_matnr | <p class="shorttext synchronized">Materials with a run since then</p>
    CLASS-METHODS allocated_since
      IMPORTING
        iv_werks        TYPE mard-werks
        iv_hours        TYPE i DEFAULT c_default_hours
      RETURNING
        VALUE(rt_matnr) TYPE ty_matnr_tab.

  PRIVATE SECTION.

    "! Reading what the night did, not doing any of it again.
    CONSTANTS c_activity_display TYPE activ_auth VALUE '03'.

    CONSTANTS c_hours_in_day TYPE i VALUE 24.

    DATA mo_demand    TYPE REF TO zif_demand_reader.
    DATA mo_authority TYPE REF TO zif_allocation_authority.

ENDCLASS.


CLASS zcl_alloc_coverage IMPLEMENTATION.

  METHOD create_for_plant.

    DATA(ls_settings) = CAST zif_alloc_config( NEW zcl_alloc_config( ) )->for_plant( iv_werks ).

    " the list of materials has to be the list a run works from, or a material
    " the run never intended to cover is reported as one it missed
    ro_coverage = NEW zcl_alloc_coverage(
      io_demand    = zcl_allocation_service=>create_default_demand(
        iv_sto_priority = ls_settings-sto_priority
        iv_ship_days    = ls_settings-ship_days
        iv_age_days     = ls_settings-age_days
        iv_work_days    = ls_settings-work_days )
      io_authority = NEW zcl_authority_alloc( c_activity_display ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_demand    = io_demand.
    mo_authority = io_authority.

  ENDMETHOD.

  METHOD run.

    DATA lv_missed TYPE i.
    DATA lv_total  TYPE i.

    mo_authority->check_plant( iv_werks ).

    DATA(lv_hours) = iv_hours.
    IF lv_hours <= 0.
      lv_hours = c_default_hours.
    ENDIF.

    APPEND |Plant { iv_werks }, waiting and not allocated in the last { lv_hours } hour(s)| TO rt_line.

    DATA(lt_done) = allocated_since(
      iv_werks = iv_werks
      iv_hours = lv_hours ).

    LOOP AT mo_demand->materials_with_demand( iv_werks ) INTO DATA(lv_matnr).

      lv_total = lv_total + 1.

      IF line_exists( lt_done[ table_line = lv_matnr ] ).
        CONTINUE.
      ENDIF.

      lv_missed = lv_missed + 1.
      APPEND |{ lv_matnr }| TO rt_line.

    ENDLOOP.

    APPEND || TO rt_line.

    IF lv_total = 0.
      APPEND `Nothing is waiting for stock in this plant` TO rt_line.
      RETURN.
    ENDIF.

    IF lv_missed = 0.
      APPEND |All { lv_total } material(s) with demand were allocated| TO rt_line.
      RETURN.
    ENDIF.

    APPEND |{ lv_missed } of { lv_total } material(s) with demand were not| TO rt_line.

  ENDMETHOD.

  METHOD allocated_since.

    DATA lv_cutoff TYPE zstock_alloc_res-created_at.
    DATA lv_date   TYPE d.
    DATA lv_days   TYPE i.

    " whole days back, rounded up: a run counted as missing because it
    " finished forty minutes outside the window would send somebody looking
    " for a job that did its work
    lv_days = ( iv_hours + c_hours_in_day - 1 ) DIV c_hours_in_day.
    lv_date = sy-datum - lv_days.

    lv_cutoff = zcl_alloc_clock=>stamp_of( lv_date ).

    SELECT DISTINCT matnr
      FROM zstock_alloc_res
      WHERE werks = @iv_werks
        AND created_at >= @lv_cutoff
      ORDER BY matnr
      INTO TABLE @rt_matnr.
    IF sy-subrc <> 0.
      CLEAR rt_matnr.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
