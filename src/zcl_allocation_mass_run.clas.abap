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
    "! @parameter iv_ship_days    | <p class="shorttext synchronized">Days between the goods being ready and gone</p>
    "! @parameter it_dispo        | <p class="shorttext synchronized">MRP controllers to cover, all if empty</p>
    "! @parameter iv_package      | <p class="shorttext synchronized">Package this run covers, 0 for all of them</p>
    "! @parameter iv_packages     | <p class="shorttext synchronized">How many jobs share the plant, 0 for one</p>
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
        iv_ship_days       TYPE i DEFAULT 0
        it_dispo           TYPE zcl_demand_of_controller=>ty_dispo_tab OPTIONAL
        iv_package         TYPE i DEFAULT 0
        iv_packages        TYPE i DEFAULT 0
      RETURNING
        VALUE(ro_mass_run) TYPE REF TO zcl_allocation_mass_run.

    "! <p class="shorttext synchronized">Wire up the plant wide run</p>
    "!
    "! @parameter io_service | <p class="shorttext synchronized">Allocates one material</p>
    "! @parameter io_demand  | <p class="shorttext synchronized">Says which materials need one</p>
    "! @parameter io_log      | <p class="shorttext synchronized">Where the run says what it did</p>
    "! @parameter iv_settings | <p class="shorttext synchronized">What the run was told to do, in a line</p>
    METHODS constructor
      IMPORTING
        io_service  TYPE REF TO zif_allocation_service
        io_demand   TYPE REF TO zif_demand_reader
        io_log      TYPE REF TO zif_allocation_log
        iv_settings TYPE string OPTIONAL.

    "! <p class="shorttext synchronized">What this run was told to do, in a line</p>
    "!
    "! The same sentence the log is headed with. A spool that does not say what
    "! the run was set to do is a spool somebody has to guess about, and the
    "! variant can have been changed by the time they read it.
    "!
    "! @parameter rv_settings | <p class="shorttext synchronized">The settings, in the words a person would use</p>
    METHODS settings
      RETURNING
        VALUE(rv_settings) TYPE string.

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
    DATA mo_log      TYPE REF TO zif_allocation_log.
    DATA mv_settings TYPE string.

    "! What the run was told to do, in the words a person would use. Rendered
    "! where the settings are known, which is the only place that knows all of
    "! them at once.
    CLASS-METHODS settings_text
      IMPORTING
        io_strategy     TYPE REF TO zif_allocation_strategy
        iv_horizon_days TYPE i
        iv_lgort        TYPE mard-lgort
        iv_cap_percent  TYPE i
        iv_planned      TYPE abap_bool
        iv_whole_units  TYPE abap_bool
        iv_recut        TYPE abap_bool
      RETURNING
        VALUE(rv_text)  TYPE string.

    METHODS short_lines
      IMPORTING
        it_allocation   TYPE zif_allocation=>ty_allocation_tab
      RETURNING
        VALUE(rv_lines) TYPE i.

    METHODS short_materials
      IMPORTING
        it_outcome      TYPE ty_outcome_tab
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS failed_materials
      IMPORTING
        it_outcome      TYPE ty_outcome_tab
      RETURNING
        VALUE(rv_count) TYPE i.

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
        iv_sto_priority = iv_sto_priority
        iv_ship_days    = iv_ship_days )
      io_demand  = NEW zcl_demand_in_package(
        io_demand   = NEW zcl_demand_of_controller(
          io_demand = zcl_allocation_service=>create_default_demand(
            iv_sto_priority = iv_sto_priority
            iv_ship_days    = iv_ship_days )
          it_dispo  = it_dispo )
        iv_package  = iv_package
        iv_packages = iv_packages )
      io_log     = NEW zcl_alloc_log_bal( NEW zcl_unit_of_work( ) ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_service = io_service.
    mo_demand  = io_demand.
    mo_log      = io_log.
    mv_settings = iv_settings.

  ENDMETHOD.

  METHOD settings.
    rv_settings = mv_settings.
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
      mo_log->start(
        iv_werks    = iv_werks
        iv_settings = mv_settings ).
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

            " a material nothing was waiting for was not allocated, and a
            " line in the log saying it was would be a line to look up and
            " find nothing behind
            IF ls_outcome-run-run_id IS NOT INITIAL.
              mo_log->allocated(
                iv_matnr       = lv_matnr
                iv_run_id      = ls_outcome-run-run_id
                iv_short_lines = short_lines( ls_outcome-run-allocation ) ).
            ENDIF.
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
      mo_log->finished(
        iv_materials = lines( rt_outcome )
        iv_short     = short_materials( rt_outcome )
        iv_failed    = failed_materials( rt_outcome ) ).
      mo_log->save( ).
    ENDIF.

  ENDMETHOD.

  METHOD settings_text.

    " the strategy is named by what it is, not by its class: a customer that
    " swapped in one of its own reads its own name here rather than "fair
    " share" or a blank
    DATA(lv_strategy) = `priority`.
    IF io_strategy IS BOUND.
      lv_strategy = cl_abap_classdescr=>get_class_name( io_strategy ).
    ENDIF.

    rv_text = |{ lv_strategy }| &&
              COND string( WHEN iv_horizon_days > 0
                           THEN |, horizon { iv_horizon_days } day(s)| ) &&
              COND string( WHEN iv_lgort IS NOT INITIAL
                           THEN |, location { iv_lgort }| ) &&
              COND string( WHEN iv_cap_percent > 0
                           THEN |, cap { iv_cap_percent } percent| ) &&
              COND string( WHEN iv_planned = abap_true
                           THEN `, plan counts` ) &&
              COND string( WHEN iv_whole_units = abap_true
                           THEN `, whole units` ) &&
              COND string( WHEN iv_recut = abap_true
                           THEN `, re-cut` ).

  ENDMETHOD.

  METHOD short_materials.

    LOOP AT it_outcome INTO DATA(ls_outcome).
      IF ls_outcome-failed = abap_false
          AND short_lines( ls_outcome-run-allocation ) > 0.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD failed_materials.

    LOOP AT it_outcome INTO DATA(ls_outcome).
      IF ls_outcome-failed = abap_true.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD short_lines.

    LOOP AT it_allocation INTO DATA(ls_allocation).
      IF ls_allocation-shortfall > 0.
        rv_lines = rv_lines + 1.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
