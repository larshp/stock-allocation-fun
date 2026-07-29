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
      RETURNING
        VALUE(rs_plan)      TYPE zif_stock_allocation=>ty_plan
      RAISING
        zcx_stock_allocation.
  PRIVATE SECTION.
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
      RETURNING
        VALUE(rs_plan)      TYPE zif_stock_allocation=>ty_plan
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
      iv_material = iv_material
      iv_plant = iv_plant
      iv_storage_location = iv_storage_location
      iv_reserve = iv_reserve ).
    rt_allocations = ls_plan-allocations.
  ENDMETHOD.

  METHOD run_plan.
    zcl_stock_alloc_validator=>validate_scope(
      iv_material = iv_material
      iv_plant = iv_plant
      iv_storage_location = iv_storage_location ).
    zcl_stock_alloc_validator=>validate_reserve( iv_reserve ).
    IF mo_authorization->is_authorized(
         iv_activity = '16'
         iv_plant = iv_plant
         iv_storage_location = iv_storage_location ) = abap_false.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Not authorized to execute stock allocation' ).
    ENDIF.

    DATA(lv_acquired) = mo_allocation_lock->acquire(
      iv_material = iv_material
      iv_plant = iv_plant
      iv_storage_location = iv_storage_location ).
    IF lv_acquired = abap_false.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Another stock allocation run is already active' ).
    ENDIF.

    TRY.
        rs_plan = calculate(
          iv_material = iv_material
          iv_plant = iv_plant
          iv_storage_location = iv_storage_location
          iv_reserve = iv_reserve ).
        DATA(lv_recorded) = mo_allocation_log->record_run(
          iv_material = iv_material
          iv_plant = iv_plant
          iv_storage_location = iv_storage_location
          iv_stock_qty = rs_plan-stock_qty
          iv_allocatable_qty = rs_plan-allocatable_qty
          iv_reserve = rs_plan-reserve_qty
          iv_unit = rs_plan-unit
          it_allocations = rs_plan-allocations ).
        IF lv_recorded = abap_false.
          RAISE EXCEPTION NEW zcx_stock_allocation(
            'Unable to write the stock allocation application log' ).
        ENDIF.
        mo_allocation_sink->save(
          iv_material = iv_material
          iv_plant = iv_plant
          iv_storage_location = iv_storage_location
          it_allocations = rs_plan-allocations ).
      CATCH cx_root INTO DATA(lo_failure).
        mo_allocation_lock->release(
          iv_material = iv_material
          iv_plant = iv_plant
          iv_storage_location = iv_storage_location ).
        RAISE EXCEPTION NEW zcx_stock_allocation(
          iv_text = lo_failure->get_text( )
          io_previous = lo_failure ).
    ENDTRY.

  ENDMETHOD.

  METHOD preview.
    DATA(ls_plan) = preview_plan(
      iv_material = iv_material
      iv_plant = iv_plant
      iv_storage_location = iv_storage_location
      iv_reserve = iv_reserve ).
    rt_allocations = ls_plan-allocations.
  ENDMETHOD.

  METHOD preview_plan.
    zcl_stock_alloc_validator=>validate_scope(
      iv_material = iv_material
      iv_plant = iv_plant
      iv_storage_location = iv_storage_location ).
    zcl_stock_alloc_validator=>validate_reserve( iv_reserve ).
    IF mo_authorization->is_authorized(
         iv_activity = '03'
         iv_plant = iv_plant
         iv_storage_location = iv_storage_location ) = abap_false.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Not authorized to preview stock allocation' ).
    ENDIF.

    TRY.
        rs_plan = calculate(
          iv_material = iv_material
          iv_plant = iv_plant
          iv_storage_location = iv_storage_location
          iv_reserve = iv_reserve ).
      CATCH cx_root INTO DATA(lo_failure).
        RAISE EXCEPTION NEW zcx_stock_allocation(
          iv_text = lo_failure->get_text( )
          io_previous = lo_failure ).
    ENDTRY.
  ENDMETHOD.

  METHOD calculate.
    DATA(ls_stock) = mo_stock_source->get_available(
      iv_material = iv_material
      iv_plant = iv_plant
      iv_storage_location = iv_storage_location ).
    DATA(lt_demands) = mo_demand_source->get_open_demands(
      iv_material = iv_material
      iv_plant = iv_plant
      iv_storage_location = iv_storage_location ).
    zcl_stock_alloc_validator=>validate_demands( lt_demands ).

    DATA(ls_latest_stock) = mo_stock_source->get_available(
      iv_material = iv_material
      iv_plant = iv_plant
      iv_storage_location = iv_storage_location ).
    IF ls_latest_stock <> ls_stock.
      ls_stock = ls_latest_stock.
    ENDIF.
    IF ls_stock-unit IS INITIAL.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Material base unit could not be determined' ).
    ENDIF.

    DATA(lv_allocatable) = ls_stock-quantity - iv_reserve.
    IF lv_allocatable < 0.
      CLEAR lv_allocatable.
    ENDIF.

    rs_plan-stock_qty = ls_stock-quantity.
    rs_plan-allocatable_qty = lv_allocatable.
    rs_plan-reserve_qty = iv_reserve.
    rs_plan-unit = ls_stock-unit.
    rs_plan-allocations = NEW zcl_stock_allocator( )->allocate(
      iv_available = lv_allocatable
      it_demands = lt_demands
      iv_unit = ls_stock-unit
      iv_reserve = iv_reserve ).
  ENDMETHOD.
ENDCLASS.
