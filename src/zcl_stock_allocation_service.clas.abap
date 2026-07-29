CLASS zcl_stock_allocation_service DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_stock_source    TYPE REF TO zif_stock_source
        io_demand_source   TYPE REF TO zif_demand_source
        io_allocation_sink TYPE REF TO zif_allocation_sink
        io_allocation_lock TYPE REF TO zif_allocation_lock
        io_authorization   TYPE REF TO zif_allocation_authorization
        io_allocation_log  TYPE REF TO zif_allocation_log.
    METHODS run
      IMPORTING
        iv_material           TYPE zif_stock_allocation=>ty_material
        iv_plant              TYPE zif_stock_allocation=>ty_plant
        iv_storage_location   TYPE zif_stock_allocation=>ty_storage_loc
        iv_reserve            TYPE zif_stock_allocation=>ty_quantity OPTIONAL
        iv_strategy           TYPE zif_stock_allocation=>ty_strategy DEFAULT zif_stock_allocation=>c_strategy_fifo
        iv_start_date         TYPE zif_stock_allocation=>ty_start_date OPTIONAL
        iv_cutoff_date        TYPE zif_stock_allocation=>ty_cutoff_date OPTIONAL
        iv_expected_version   TYPE i OPTIONAL
        iv_require_new        TYPE abap_bool OPTIONAL
        iv_run_note           TYPE zif_stock_allocation=>ty_run_note OPTIONAL
      RETURNING
        VALUE(rt_allocations) TYPE zif_stock_allocation=>tt_allocations
      RAISING
        zcx_stock_allocation.
    METHODS preview
      IMPORTING
        iv_material           TYPE zif_stock_allocation=>ty_material
        iv_plant              TYPE zif_stock_allocation=>ty_plant
        iv_storage_location   TYPE zif_stock_allocation=>ty_storage_loc
        iv_reserve            TYPE zif_stock_allocation=>ty_quantity OPTIONAL
        iv_strategy           TYPE zif_stock_allocation=>ty_strategy DEFAULT zif_stock_allocation=>c_strategy_fifo
        iv_start_date         TYPE zif_stock_allocation=>ty_start_date OPTIONAL
        iv_cutoff_date        TYPE zif_stock_allocation=>ty_cutoff_date OPTIONAL
      RETURNING
        VALUE(rt_allocations) TYPE zif_stock_allocation=>tt_allocations
      RAISING
        zcx_stock_allocation.
    METHODS run_plan
      IMPORTING
        iv_material         TYPE zif_stock_allocation=>ty_material
        iv_plant            TYPE zif_stock_allocation=>ty_plant
        iv_storage_location TYPE zif_stock_allocation=>ty_storage_loc
        iv_reserve          TYPE zif_stock_allocation=>ty_quantity OPTIONAL
        iv_strategy         TYPE zif_stock_allocation=>ty_strategy DEFAULT zif_stock_allocation=>c_strategy_fifo
        iv_start_date       TYPE zif_stock_allocation=>ty_start_date OPTIONAL
        iv_cutoff_date      TYPE zif_stock_allocation=>ty_cutoff_date OPTIONAL
        iv_expected_version TYPE i OPTIONAL
        iv_require_new      TYPE abap_bool OPTIONAL
        iv_run_note         TYPE zif_stock_allocation=>ty_run_note OPTIONAL
      RETURNING
        VALUE(rs_plan)      TYPE zif_stock_allocation=>ty_plan
      RAISING
        zcx_stock_allocation.
    METHODS preview_plan
      IMPORTING
        iv_material         TYPE zif_stock_allocation=>ty_material
        iv_plant            TYPE zif_stock_allocation=>ty_plant
        iv_storage_location TYPE zif_stock_allocation=>ty_storage_loc
        iv_reserve          TYPE zif_stock_allocation=>ty_quantity OPTIONAL
        iv_strategy         TYPE zif_stock_allocation=>ty_strategy DEFAULT zif_stock_allocation=>c_strategy_fifo
        iv_start_date       TYPE zif_stock_allocation=>ty_start_date OPTIONAL
        iv_cutoff_date      TYPE zif_stock_allocation=>ty_cutoff_date OPTIONAL
      RETURNING
        VALUE(rs_plan)      TYPE zif_stock_allocation=>ty_plan
      RAISING
        zcx_stock_allocation.
    METHODS preview_all_strategies
      IMPORTING
        iv_material         TYPE zif_stock_allocation=>ty_material
        iv_plant            TYPE zif_stock_allocation=>ty_plant
        iv_storage_location TYPE zif_stock_allocation=>ty_storage_loc
        iv_reserve          TYPE zif_stock_allocation=>ty_quantity OPTIONAL
        iv_start_date       TYPE zif_stock_allocation=>ty_start_date OPTIONAL
        iv_cutoff_date      TYPE zif_stock_allocation=>ty_cutoff_date OPTIONAL
      RETURNING
        VALUE(rt_plans)     TYPE zif_stock_allocation=>tt_plans
      RAISING
        zcx_stock_allocation.
  PRIVATE SECTION.
    CONSTANTS c_snapshot_attempts TYPE i VALUE 3.
    TYPES:
      BEGIN OF ty_context,
        stock   TYPE zif_stock_allocation=>ty_stock,
        demands TYPE zif_stock_allocation=>tt_demands,
      END OF ty_context.
    DATA mo_stock_source TYPE REF TO zif_stock_source.
    DATA mo_demand_source TYPE REF TO zif_demand_source.
    DATA mo_allocation_sink TYPE REF TO zif_allocation_sink.
    DATA mo_allocation_lock TYPE REF TO zif_allocation_lock.
    DATA mo_authorization TYPE REF TO zif_allocation_authorization.
    DATA mo_allocation_log TYPE REF TO zif_allocation_log.
    METHODS calculate
      IMPORTING
        iv_material         TYPE zif_stock_allocation=>ty_material
        iv_plant            TYPE zif_stock_allocation=>ty_plant
        iv_storage_location TYPE zif_stock_allocation=>ty_storage_loc
        iv_reserve          TYPE zif_stock_allocation=>ty_quantity
        iv_strategy         TYPE zif_stock_allocation=>ty_strategy
        iv_start_date       TYPE zif_stock_allocation=>ty_start_date
        iv_cutoff_date      TYPE zif_stock_allocation=>ty_cutoff_date
      RETURNING
        VALUE(rs_plan)      TYPE zif_stock_allocation=>ty_plan
      RAISING
        zcx_stock_allocation.
    METHODS load_context
      IMPORTING
        iv_material         TYPE zif_stock_allocation=>ty_material
        iv_plant            TYPE zif_stock_allocation=>ty_plant
        iv_storage_location TYPE zif_stock_allocation=>ty_storage_loc
        iv_start_date       TYPE zif_stock_allocation=>ty_start_date
        iv_cutoff_date      TYPE zif_stock_allocation=>ty_cutoff_date
      RETURNING
        VALUE(rs_context)   TYPE ty_context
      RAISING
        zcx_stock_allocation.
    METHODS build_plan
      IMPORTING
        is_stock       TYPE zif_stock_allocation=>ty_stock
        it_demands     TYPE zif_stock_allocation=>tt_demands
        iv_reserve     TYPE zif_stock_allocation=>ty_quantity
        iv_strategy    TYPE zif_stock_allocation=>ty_strategy
        iv_start_date  TYPE zif_stock_allocation=>ty_start_date
        iv_cutoff_date TYPE zif_stock_allocation=>ty_cutoff_date
      RETURNING
        VALUE(rs_plan) TYPE zif_stock_allocation=>ty_plan
      RAISING
        zcx_stock_allocation.
ENDCLASS.

CLASS zcl_stock_allocation_service IMPLEMENTATION.
  METHOD constructor.
    ASSERT io_stock_source IS BOUND.
    ASSERT io_demand_source IS BOUND.
    ASSERT io_allocation_sink IS BOUND.
    ASSERT io_allocation_lock IS BOUND.
    ASSERT io_authorization IS BOUND.
    ASSERT io_allocation_log IS BOUND.
    mo_stock_source = io_stock_source.
    mo_demand_source = io_demand_source.
    mo_allocation_sink = io_allocation_sink.
    mo_allocation_lock = io_allocation_lock.
    mo_authorization = io_authorization.
    mo_allocation_log = io_allocation_log.
  ENDMETHOD.

  METHOD run.
    DATA(ls_plan) = run_plan(
      iv_material         = iv_material
      iv_plant            = iv_plant
      iv_storage_location = iv_storage_location
      iv_reserve          = iv_reserve
      iv_strategy         = iv_strategy
      iv_start_date       = iv_start_date
      iv_cutoff_date      = iv_cutoff_date
      iv_expected_version = iv_expected_version
      iv_require_new      = iv_require_new
      iv_run_note         = iv_run_note ).
    rt_allocations = ls_plan-allocations.
  ENDMETHOD.

  METHOD run_plan.
    zcl_stock_alloc_validator=>validate_scope(
      iv_material         = iv_material
      iv_plant            = iv_plant
      iv_storage_location = iv_storage_location ).
    zcl_stock_alloc_validator=>validate_reserve( iv_reserve ).
    zcl_stock_alloc_validator=>validate_strategy( iv_strategy ).
    zcl_stock_alloc_validator=>validate_window(
      iv_start_date  = iv_start_date
      iv_cutoff_date = iv_cutoff_date ).
    IF iv_expected_version < 0.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Expected allocation plan version cannot be negative' ).
    ENDIF.
    IF iv_require_new = abap_true AND iv_expected_version > 0.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'New-only execution cannot also expect an existing version' ).
    ENDIF.
    IF mo_authorization->is_authorized(
         iv_activity         = '16'
         iv_plant            = iv_plant
         iv_storage_location = iv_storage_location ) = abap_false.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Not authorized to execute stock allocation' ).
    ENDIF.

    DATA(lv_acquired) = mo_allocation_lock->acquire(
      iv_material         = iv_material
      iv_plant            = iv_plant
      iv_storage_location = iv_storage_location ).
    IF lv_acquired = abap_false.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Another stock allocation run is already active' ).
    ENDIF.

    TRY.
        DATA(lv_prepared_version) = mo_allocation_sink->prepare_save(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_expected_version = iv_expected_version
          iv_require_new      = iv_require_new ).
        rs_plan = calculate(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_reserve          = iv_reserve
          iv_strategy         = iv_strategy
          iv_start_date       = iv_start_date
          iv_cutoff_date      = iv_cutoff_date ).
        DATA(lv_recorded) = mo_allocation_log->record_run(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_version_no       = lv_prepared_version
          iv_stock_qty        = rs_plan-stock_qty
          iv_allocatable_qty  = rs_plan-allocatable_qty
          iv_reserve          = rs_plan-reserve_qty
          iv_unit             = rs_plan-unit
          iv_strategy         = rs_plan-strategy
          iv_start_date       = rs_plan-start_date
          iv_cutoff_date      = rs_plan-cutoff_date
          iv_run_note         = iv_run_note
          it_allocations      = rs_plan-allocations ).
        IF lv_recorded = abap_false.
          RAISE EXCEPTION NEW zcx_stock_allocation(
            'Unable to write the stock allocation application log' ).
        ENDIF.
        DATA(lv_saved_version) = mo_allocation_sink->save(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          is_plan             = rs_plan
          iv_expected_version = iv_expected_version
          iv_require_new      = iv_require_new
          iv_run_note         = iv_run_note ).
        IF lv_saved_version <> lv_prepared_version.
          RAISE EXCEPTION NEW zcx_stock_allocation(
            'Prepared and persisted allocation versions differ' ).
        ENDIF.
        rs_plan-version_no = lv_saved_version.
      CATCH cx_root INTO DATA(lo_failure).
        mo_allocation_lock->release(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location ).
        RAISE EXCEPTION NEW zcx_stock_allocation(
          iv_text     = lo_failure->get_text( )
          io_previous = lo_failure ).
    ENDTRY.

  ENDMETHOD.

  METHOD preview.
    DATA(ls_plan) = preview_plan(
      iv_material         = iv_material
      iv_plant            = iv_plant
      iv_storage_location = iv_storage_location
      iv_reserve          = iv_reserve
      iv_strategy         = iv_strategy
      iv_start_date       = iv_start_date
      iv_cutoff_date      = iv_cutoff_date ).
    rt_allocations = ls_plan-allocations.
  ENDMETHOD.

  METHOD preview_plan.
    zcl_stock_alloc_validator=>validate_scope(
      iv_material         = iv_material
      iv_plant            = iv_plant
      iv_storage_location = iv_storage_location ).
    zcl_stock_alloc_validator=>validate_reserve( iv_reserve ).
    zcl_stock_alloc_validator=>validate_strategy( iv_strategy ).
    zcl_stock_alloc_validator=>validate_window(
      iv_start_date  = iv_start_date
      iv_cutoff_date = iv_cutoff_date ).
    IF mo_authorization->is_authorized(
         iv_activity         = '03'
         iv_plant            = iv_plant
         iv_storage_location = iv_storage_location ) = abap_false.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Not authorized to preview stock allocation' ).
    ENDIF.

    TRY.
        rs_plan = calculate(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_reserve          = iv_reserve
          iv_strategy         = iv_strategy
          iv_start_date       = iv_start_date
          iv_cutoff_date      = iv_cutoff_date ).
      CATCH cx_root INTO DATA(lo_failure).
        RAISE EXCEPTION NEW zcx_stock_allocation(
          iv_text     = lo_failure->get_text( )
          io_previous = lo_failure ).
    ENDTRY.
  ENDMETHOD.

  METHOD preview_all_strategies.
    zcl_stock_alloc_validator=>validate_scope(
      iv_material         = iv_material
      iv_plant            = iv_plant
      iv_storage_location = iv_storage_location ).
    zcl_stock_alloc_validator=>validate_reserve( iv_reserve ).
    zcl_stock_alloc_validator=>validate_window(
      iv_start_date  = iv_start_date
      iv_cutoff_date = iv_cutoff_date ).
    IF mo_authorization->is_authorized(
         iv_activity         = '03'
         iv_plant            = iv_plant
         iv_storage_location = iv_storage_location ) = abap_false.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Not authorized to compare stock allocation strategies' ).
    ENDIF.

    TRY.
        DATA(ls_context) = load_context(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_start_date       = iv_start_date
          iv_cutoff_date      = iv_cutoff_date ).
        APPEND build_plan(
          is_stock       = ls_context-stock
          it_demands     = ls_context-demands
          iv_reserve     = iv_reserve
          iv_strategy    = zif_stock_allocation=>c_strategy_fifo
          iv_start_date  = iv_start_date
          iv_cutoff_date = iv_cutoff_date ) TO rt_plans.
        APPEND build_plan(
          is_stock       = ls_context-stock
          it_demands     = ls_context-demands
          iv_reserve     = iv_reserve
          iv_strategy    = zif_stock_allocation=>c_strategy_proportional
          iv_start_date  = iv_start_date
          iv_cutoff_date = iv_cutoff_date ) TO rt_plans.
        APPEND build_plan(
          is_stock       = ls_context-stock
          it_demands     = ls_context-demands
          iv_reserve     = iv_reserve
          iv_strategy    = zif_stock_allocation=>c_strategy_fair_share
          iv_start_date  = iv_start_date
          iv_cutoff_date = iv_cutoff_date ) TO rt_plans.
        APPEND build_plan(
          is_stock       = ls_context-stock
          it_demands     = ls_context-demands
          iv_reserve     = iv_reserve
          iv_strategy    = zif_stock_allocation=>c_strategy_smallest_first
          iv_start_date  = iv_start_date
          iv_cutoff_date = iv_cutoff_date ) TO rt_plans.
        APPEND build_plan(
          is_stock       = ls_context-stock
          it_demands     = ls_context-demands
          iv_reserve     = iv_reserve
          iv_strategy    = zif_stock_allocation=>c_strategy_complete_only
          iv_start_date  = iv_start_date
          iv_cutoff_date = iv_cutoff_date ) TO rt_plans.
      CATCH cx_root INTO DATA(lo_failure).
        RAISE EXCEPTION NEW zcx_stock_allocation(
          iv_text     = lo_failure->get_text( )
          io_previous = lo_failure ).
    ENDTRY.
  ENDMETHOD.

  METHOD calculate.
    DATA(ls_context) = load_context(
      iv_material         = iv_material
      iv_plant            = iv_plant
      iv_storage_location = iv_storage_location
      iv_start_date       = iv_start_date
      iv_cutoff_date      = iv_cutoff_date ).
    rs_plan = build_plan(
      is_stock       = ls_context-stock
      it_demands     = ls_context-demands
      iv_reserve     = iv_reserve
      iv_strategy    = iv_strategy
      iv_start_date  = iv_start_date
      iv_cutoff_date = iv_cutoff_date ).
  ENDMETHOD.

  METHOD load_context.
    DATA lv_stable TYPE abap_bool.
    DO c_snapshot_attempts TIMES.
      DATA(ls_initial_stock) = mo_stock_source->get_available(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location ).
      DATA(lt_initial_demands) = mo_demand_source->get_open_demands(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_start_date       = iv_start_date
        iv_cutoff_date      = iv_cutoff_date ).
      zcl_stock_alloc_validator=>validate_demands( lt_initial_demands ).

      DATA(ls_intermediate_stock) = mo_stock_source->get_available(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location ).
      IF ls_intermediate_stock <> ls_initial_stock.
        CONTINUE.
      ENDIF.

      rs_context-demands = mo_demand_source->get_open_demands(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_start_date       = iv_start_date
        iv_cutoff_date      = iv_cutoff_date ).
      zcl_stock_alloc_validator=>validate_demands( rs_context-demands ).
      DATA(ls_latest_stock) = mo_stock_source->get_available(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location ).

      SORT lt_initial_demands BY sales_order sales_item schedule_line.
      SORT rs_context-demands BY sales_order sales_item schedule_line.
      IF ls_latest_stock = ls_intermediate_stock
          AND rs_context-demands = lt_initial_demands.
        rs_context-stock = ls_latest_stock.
        lv_stable = abap_true.
        EXIT.
      ENDIF.
    ENDDO.
    IF lv_stable = abap_false.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Stock or demand changed continuously while building the snapshot' ).
    ENDIF.
    IF rs_context-stock-unit IS INITIAL.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Material base unit could not be determined' ).
    ENDIF.
  ENDMETHOD.

  METHOD build_plan.
    DATA(lv_allocatable) = is_stock-quantity - iv_reserve.
    IF lv_allocatable < 0.
      CLEAR lv_allocatable.
    ENDIF.

    rs_plan-stock_qty = is_stock-quantity.
    rs_plan-allocatable_qty = lv_allocatable.
    rs_plan-reserve_qty = iv_reserve.
    rs_plan-unit = is_stock-unit.
    rs_plan-strategy = iv_strategy.
    rs_plan-start_date = iv_start_date.
    rs_plan-cutoff_date = iv_cutoff_date.
    rs_plan-allocations = NEW zcl_stock_allocator( )->allocate(
      iv_available   = lv_allocatable
      it_demands     = it_demands
      iv_unit        = is_stock-unit
      iv_reserve     = iv_reserve
      iv_strategy    = iv_strategy
      iv_start_date  = iv_start_date
      iv_cutoff_date = iv_cutoff_date ).
    zcl_stock_alloc_validator=>validate_plan( rs_plan ).
  ENDMETHOD.
ENDCLASS.
