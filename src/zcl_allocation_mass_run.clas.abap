CLASS zcl_allocation_mass_run DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    "! What became of one material in a plant wide run. FAILED lines carry the
    "! reason instead of a result, so a run can be read as a whole.
    TYPES:
      BEGIN OF ty_outcome,
        matnr  TYPE mard-matnr,
        failed TYPE abap_bool,
        reason TYPE string,
        run    TYPE zif_allocation_service=>ty_run,
      END OF ty_outcome.
    TYPES ty_outcome_tab TYPE STANDARD TABLE OF ty_outcome WITH EMPTY KEY.

    "! <p class="shorttext synchronized">Plant wide run wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter io_strategy     | <p class="shorttext synchronized">Distribution rule, priority by default</p>
    "! @parameter iv_horizon_days | <p class="shorttext synchronized">Days ahead to look, 0 for no limit</p>
    "! @parameter iv_lgort        | <p class="shorttext synchronized">Location to allocate from, all if empty</p>
    "! @parameter iv_cap_percent  | <p class="shorttext synchronized">Most one customer may take, 0 for no cap</p>
    "! @parameter iv_planned      | <p class="shorttext synchronized">Planned orders count as supply too</p>
    "! @parameter iv_whole_units  | <p class="shorttext synchronized">Confirm whole order units only</p>
    "! @parameter iv_recut        | <p class="shorttext synchronized">Give earlier allocations back and start again</p>
    "! @parameter iv_sto_priority | <p class="shorttext synchronized">Where a transfer stands against an order</p>
    "! @parameter it_dispo        | <p class="shorttext synchronized">MRP controllers to cover, all if empty</p>
    "! @parameter ro_mass_run     | <p class="shorttext synchronized">Ready to use plant wide run</p>
    CLASS-METHODS create_default
      IMPORTING
        io_strategy        TYPE REF TO zif_allocation_strategy OPTIONAL
        iv_horizon_days    TYPE i DEFAULT zcl_demand_within_horizon=>c_no_horizon
        iv_lgort           TYPE mard-lgort OPTIONAL
        iv_cap_percent     TYPE i DEFAULT zcl_alloc_customer_cap=>c_no_cap
        iv_planned         TYPE abap_bool DEFAULT abap_false
        iv_whole_units     TYPE abap_bool DEFAULT abap_false
        iv_recut           TYPE abap_bool DEFAULT abap_false
        iv_sto_priority    TYPE zif_allocation=>ty_priority DEFAULT zcl_sto_demand_reader=>c_default_priority
        it_dispo           TYPE zcl_demand_of_controller=>ty_dispo_tab OPTIONAL
      RETURNING
        VALUE(ro_mass_run) TYPE REF TO zcl_allocation_mass_run.

    "! <p class="shorttext synchronized">Wire up the plant wide run</p>
    "!
    "! @parameter io_service | <p class="shorttext synchronized">Allocates one material</p>
    "! @parameter io_demand  | <p class="shorttext synchronized">Says which materials need one</p>
    "! @parameter io_log     | <p class="shorttext synchronized">Where the run says what it did</p>
    METHODS constructor
      IMPORTING
        io_service TYPE REF TO zif_allocation_service
        io_demand  TYPE REF TO zif_demand_reader
        io_log     TYPE REF TO zif_allocation_log.

    "! <p class="shorttext synchronized">Allocate every material in a plant that is waiting for stock</p>
    "!
    "! One material failing does not stop the rest. This runs unattended, and a
    "! single blocked material must not cost a night's worth of allocations.
    "!
    "! @parameter iv_werks   | <p class="shorttext synchronized">Plant</p>
    "! @parameter it_matnr    | <p class="shorttext synchronized">Materials to cover, everything waiting if empty</p>
    "! @parameter iv_simulate | <p class="shorttext synchronized">Work it out but change nothing</p>
    "! @parameter rt_outcome  | <p class="shorttext synchronized">One line per material, in material order</p>
    METHODS run
      IMPORTING
        iv_werks          TYPE mard-werks
        it_matnr          TYPE zif_demand_reader=>ty_matnr_tab OPTIONAL
        iv_simulate       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_outcome) TYPE ty_outcome_tab.

  PRIVATE SECTION.
    DATA mo_service TYPE REF TO zif_allocation_service.
    DATA mo_demand  TYPE REF TO zif_demand_reader.
    DATA mo_log     TYPE REF TO zif_allocation_log.

    METHODS short_lines
      IMPORTING
        it_allocation   TYPE zif_allocation=>ty_allocation_tab
      RETURNING
        VALUE(rv_lines) TYPE i.

ENDCLASS.


CLASS zcl_allocation_mass_run IMPLEMENTATION.

  METHOD create_default.

    " the material list wants the sources themselves, not the netted view of
    " them: which materials are worth looking at is a wider question than what
    " is left to serve, and the service works that out per material anyway
    ro_mass_run = NEW zcl_allocation_mass_run(
      io_service = zcl_allocation_service=>create_default(
        io_strategy     = io_strategy
        iv_horizon_days = iv_horizon_days
        iv_lgort        = iv_lgort
        iv_cap_percent  = iv_cap_percent
        iv_planned      = iv_planned
        iv_whole_units  = iv_whole_units
        iv_recut        = iv_recut
        iv_sto_priority = iv_sto_priority )
      io_demand  = NEW zcl_demand_of_controller(
        io_demand = zcl_allocation_service=>create_default_demand(
          iv_sto_priority = iv_sto_priority )
        it_dispo  = it_dispo )
      io_log     = NEW zcl_alloc_log_bal( NEW zcl_unit_of_work( ) ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_service = io_service.
    mo_demand  = io_demand.
    mo_log     = io_log.

  ENDMETHOD.

  METHOD run.

    DATA ls_outcome TYPE ty_outcome.
    DATA lt_matnr   TYPE zif_demand_reader=>ty_matnr_tab.

    lt_matnr = it_matnr.
    IF lt_matnr IS INITIAL.
      lt_matnr = mo_demand->materials_with_demand( iv_werks ).
    ENDIF.

    " a test run keeps no diary. It changes nothing, so there is nothing to
    " account for afterwards, and saving a log would commit work that a run
    " which promises to change nothing has no business committing.
    IF iv_simulate = abap_false.
      mo_log->start( iv_werks ).
    ENDIF.

    LOOP AT lt_matnr INTO DATA(lv_matnr).

      CLEAR ls_outcome.
      ls_outcome-matnr = lv_matnr.

      TRY.
          IF iv_simulate = abap_true.
            ls_outcome-run = mo_service->simulate(
              iv_matnr = lv_matnr
              iv_werks = iv_werks ).
          ELSE.
            ls_outcome-run = mo_service->run(
              iv_matnr = lv_matnr
              iv_werks = iv_werks ).

            mo_log->allocated(
              iv_matnr       = lv_matnr
              iv_run_id      = ls_outcome-run-run_id
              iv_short_lines = short_lines( ls_outcome-run-allocation ) ).
          ENDIF.
        CATCH zcx_allocation INTO DATA(lx_error).
          ls_outcome-failed = abap_true.
          ls_outcome-reason = lx_error->get_text( ).

          IF iv_simulate = abap_false.
            mo_log->failed(
              iv_matnr  = lv_matnr
              iv_reason = ls_outcome-reason ).
          ENDIF.
      ENDTRY.

      APPEND ls_outcome TO rt_outcome.

    ENDLOOP.

    IF iv_simulate = abap_false.
      mo_log->save( ).
    ENDIF.

  ENDMETHOD.

  METHOD short_lines.

    LOOP AT it_allocation INTO DATA(ls_allocation).
      IF ls_allocation-shortfall > 0.
        rv_lines = rv_lines + 1.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
