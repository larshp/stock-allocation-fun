CLASS zcl_alloc_changes DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_line_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    "! <p class="shorttext synchronized">Comparison wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter io_mass_run | <p class="shorttext synchronized">Works out what a run now would decide</p>
    "! @parameter ro_changes  | <p class="shorttext synchronized">Ready to use comparison</p>
    CLASS-METHODS create_default
      IMPORTING
        io_mass_run       TYPE REF TO zcl_allocation_mass_run OPTIONAL
      RETURNING
        VALUE(ro_changes) TYPE REF TO zcl_alloc_changes.

    "! <p class="shorttext synchronized">Wire up the comparison</p>
    "!
    "! @parameter io_store     | <p class="shorttext synchronized">Where runs are recorded</p>
    "! @parameter io_authority | <p class="shorttext synchronized">Decides who may see a plant</p>
    "! @parameter io_mass_run  | <p class="shorttext synchronized">Works out what a run now would decide</p>
    METHODS constructor
      IMPORTING
        io_store     TYPE REF TO zif_allocation_store
        io_authority TYPE REF TO zif_allocation_authority
        io_mass_run  TYPE REF TO zcl_allocation_mass_run OPTIONAL.

    "! <p class="shorttext synchronized">What the last run changed about the one before it</p>
    "!
    "! An allocation is re-cut every night, and since feature 49 a run can take
    "! back what an earlier one set aside. Somebody has to ring the customers
    "! who lost stock, and reading two runs side by side to find them is not a
    "! thing anybody does twice. This is that comparison: per line, what it had
    "! and what it has now, where the two differ.
    "!
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
    "! @parameter iv_kunnr       | <p class="shorttext synchronized">Customer, every one if empty</p>
    "! @parameter iv_worse_only  | <p class="shorttext synchronized">Only the lines that lost stock</p>
    "! @parameter iv_preview     | <p class="shorttext synchronized">Against what a run now would decide</p>
    "! @parameter rt_line        | <p class="shorttext synchronized">Lines to display</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">Plant may not be seen</p>
    METHODS run
      IMPORTING
        iv_werks       TYPE mard-werks
        iv_kunnr       TYPE vbak-kunnr OPTIONAL
        iv_worse_only  TYPE abap_bool DEFAULT abap_false
        iv_preview     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab
      RAISING
        zcx_allocation.

  PRIVATE SECTION.

    CONSTANTS c_width_matnr TYPE i VALUE 20.
    CONSTANTS c_width_id    TYPE i VALUE 26.
    CONSTANTS c_width_kunnr TYPE i VALUE 12.
    CONSTANTS c_width_qty   TYPE i VALUE 14.

    "! Reading what two runs decided, not deciding anything.
    CONSTANTS c_activity_display TYPE activ_auth VALUE '03'.

    DATA mo_store     TYPE REF TO zif_allocation_store.
    DATA mo_authority TYPE REF TO zif_allocation_authority.
    DATA mo_mass_run  TYPE REF TO zcl_allocation_mass_run.

    METHODS simulated
      IMPORTING
        iv_werks             TYPE mard-werks
      RETURNING
        VALUE(rt_allocation) TYPE zif_allocation=>ty_allocation_tab.

    METHODS previous_run
      IMPORTING
        iv_matnr         TYPE mard-matnr
        iv_werks         TYPE mard-werks
        iv_run_id        TYPE zstock_alloc_res-run_id
      RETURNING
        VALUE(rv_run_id) TYPE zstock_alloc_res-run_id.

    METHODS confirmed_before
      IMPORTING
        it_before          TYPE zif_allocation=>ty_allocation_tab
        iv_demand_id       TYPE zif_allocation=>ty_demand_id
      RETURNING
        VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity.

    METHODS format_row
      IMPORTING
        iv_matnr       TYPE string
        iv_id          TYPE string
        iv_kunnr       TYPE string
        iv_before      TYPE string
        iv_now         TYPE string
      RETURNING
        VALUE(rv_line) TYPE string.

ENDCLASS.


CLASS zcl_alloc_changes IMPLEMENTATION.

  METHOD create_default.

    ro_changes = NEW zcl_alloc_changes(
      io_store     = NEW zcl_allocation_store( )
      io_authority = NEW zcl_authority_plant( c_activity_display )
      io_mass_run  = io_mass_run ).

  ENDMETHOD.

  METHOD constructor.

    mo_store     = io_store.
    mo_authority = io_authority.
    mo_mass_run  = io_mass_run.

  ENDMETHOD.

  METHOD run.

    DATA lv_matnr    TYPE mard-matnr.
    DATA lv_before   TYPE zif_allocation=>ty_allocation_tab.
    DATA lt_preview  TYPE zif_allocation=>ty_allocation_tab.
    DATA lv_lost     TYPE i.
    DATA lv_shown    TYPE i.

    mo_authority->check_plant( iv_werks ).

    IF iv_preview = abap_true.
      APPEND |Plant { iv_werks }, what a run now would change| TO rt_line.
      lt_preview = simulated( iv_werks ).
    ELSE.
      APPEND |Plant { iv_werks }, what the last run changed| TO rt_line.
    ENDIF.

    APPEND format_row(
      iv_matnr  = `Material`
      iv_id     = `Demand`
      iv_kunnr  = `Customer`
      iv_before = `Had`
      iv_now    = `Has now` ) TO rt_line.

    LOOP AT mo_store->latest_per_material( iv_werks ) INTO DATA(ls_now).

      " the lines of one material all belong to one run, so the run before it
      " is read once per material rather than once per line
      IF ls_now-matnr <> lv_matnr.
        lv_matnr = ls_now-matnr.
        CLEAR lv_before.

        DATA(lv_earlier) = previous_run(
          iv_matnr  = ls_now-matnr
          iv_werks  = iv_werks
          iv_run_id = ls_now-run_id ).
        IF lv_earlier IS NOT INITIAL.
          lv_before = mo_store->read( lv_earlier ).
        ENDIF.
      ENDIF.

      IF iv_kunnr IS NOT INITIAL AND ls_now-customer <> iv_kunnr.
        CONTINUE.
      ENDIF.

      " in a preview the recorded run is what the line has and the simulation
      " is what it would have; otherwise it is the run before against the run
      " that stands
      DATA(lv_had)   = ls_now-confirmed.
      DATA(lv_would) = ls_now-confirmed.

      IF iv_preview = abap_true.
        lv_would = confirmed_before(
          it_before    = lt_preview
          iv_demand_id = ls_now-demand_id ).
      ELSE.
        lv_had = confirmed_before(
          it_before    = lv_before
          iv_demand_id = ls_now-demand_id ).
      ENDIF.

      " a line that is exactly where it was is not news
      IF lv_had = lv_would.
        CONTINUE.
      ENDIF.

      IF iv_worse_only = abap_true AND lv_would >= lv_had.
        CONTINUE.
      ENDIF.

      IF lv_would < lv_had.
        lv_lost = lv_lost + 1.
      ENDIF.
      lv_shown = lv_shown + 1.

      APPEND format_row(
        iv_matnr  = |{ ls_now-matnr }|
        iv_id     = |{ ls_now-demand_id }|
        iv_kunnr  = |{ ls_now-customer }|
        iv_before = |{ lv_had }|
        iv_now    = |{ lv_would }| ) TO rt_line.

    ENDLOOP.

    APPEND || TO rt_line.

    IF lv_shown = 0.
      APPEND `Nothing changed` TO rt_line.
      RETURN.
    ENDIF.

    APPEND |{ lv_shown } line(s) changed, { lv_lost } of them for the worse| TO rt_line.

  ENDMETHOD.

  METHOD simulated.

    " the whole plant worked out again as it stands, and thrown away. It is
    " the same calculation a run does, which is what makes the preview worth
    " anything: an answer arrived at differently would only say that two
    " programs disagree.
    IF mo_mass_run IS NOT BOUND.
      RETURN.
    ENDIF.

    LOOP AT mo_mass_run->run(
        iv_werks    = iv_werks
        iv_simulate = abap_true ) INTO DATA(ls_outcome).
      APPEND LINES OF ls_outcome-run-allocation TO rt_allocation.
    ENDLOOP.

  ENDMETHOD.

  METHOD previous_run.

    " the runs of a material come back newest first, so the one after the run
    " that is being displayed is the one before it in time
    DATA(lt_run) = mo_store->runs_of_material(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    DATA(lv_found) = abap_false.

    LOOP AT lt_run INTO DATA(ls_run).

      IF lv_found = abap_true.
        rv_run_id = ls_run-run_id.
        RETURN.
      ENDIF.

      IF ls_run-run_id = iv_run_id.
        lv_found = abap_true.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD confirmed_before.

    READ TABLE it_before INTO DATA(ls_before)
      WITH KEY demand_id = iv_demand_id.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    rv_quantity = ls_before-confirmed.

  ENDMETHOD.

  METHOD format_row.

    rv_line = |{ iv_matnr WIDTH = c_width_matnr }|
           && |{ iv_id WIDTH = c_width_id }|
           && |{ iv_kunnr WIDTH = c_width_kunnr }|
           && |{ iv_before WIDTH = c_width_qty ALIGN = RIGHT }|
           && |{ iv_now WIDTH = c_width_qty ALIGN = RIGHT }|.

  ENDMETHOD.

ENDCLASS.
