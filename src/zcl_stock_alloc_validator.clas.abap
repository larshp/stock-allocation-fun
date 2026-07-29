CLASS zcl_stock_alloc_validator DEFINITION PUBLIC FINAL CREATE PRIVATE.
  PUBLIC SECTION.
    CLASS-METHODS validate_scope
      IMPORTING
        iv_material         TYPE zif_stock_allocation=>ty_material
        iv_plant            TYPE zif_stock_allocation=>ty_plant
        iv_storage_location TYPE zif_stock_allocation=>ty_storage_loc
      RAISING
        zcx_stock_allocation.
    CLASS-METHODS validate_priority_key
      IMPORTING
        iv_material         TYPE zif_stock_allocation=>ty_material
        iv_plant            TYPE zif_stock_allocation=>ty_plant
        iv_storage_location TYPE zif_stock_allocation=>ty_storage_loc
        iv_sales_order      TYPE zif_stock_allocation=>ty_sales_order
        iv_sales_item       TYPE zif_stock_allocation=>ty_sales_item
      RAISING
        zcx_stock_allocation.
    CLASS-METHODS validate_reserve
      IMPORTING
        iv_reserve TYPE zif_stock_allocation=>ty_quantity
      RAISING
        zcx_stock_allocation.
    CLASS-METHODS validate_strategy
      IMPORTING
        iv_strategy TYPE zif_stock_allocation=>ty_strategy
      RAISING
        zcx_stock_allocation.
    CLASS-METHODS validate_demands
      IMPORTING
        it_demands TYPE zif_stock_allocation=>tt_demands
      RAISING
        zcx_stock_allocation.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_demand_key,
        sales_order   TYPE zif_stock_allocation=>ty_sales_order,
        sales_item    TYPE zif_stock_allocation=>ty_sales_item,
        schedule_line TYPE zif_stock_allocation=>ty_schedule_line,
      END OF ty_demand_key.
    TYPES tt_demand_keys TYPE HASHED TABLE OF ty_demand_key
      WITH UNIQUE KEY sales_order sales_item schedule_line.
ENDCLASS.

CLASS zcl_stock_alloc_validator IMPLEMENTATION.
  METHOD validate_scope.
    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_storage_location IS INITIAL.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Material, plant, and storage location are required' ).
    ENDIF.
  ENDMETHOD.

  METHOD validate_priority_key.
    validate_scope(
      iv_material = iv_material
      iv_plant = iv_plant
      iv_storage_location = iv_storage_location ).
    IF iv_sales_order IS INITIAL OR iv_sales_item IS INITIAL.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Sales order and item are required for a priority' ).
    ENDIF.
  ENDMETHOD.

  METHOD validate_reserve.
    IF iv_reserve < 0.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Stock reserve quantity cannot be negative' ).
    ENDIF.
  ENDMETHOD.

  METHOD validate_strategy.
    IF iv_strategy <> zif_stock_allocation=>c_strategy_fifo
        AND iv_strategy <> zif_stock_allocation=>c_strategy_proportional
        AND iv_strategy <> zif_stock_allocation=>c_strategy_fair_share
        AND iv_strategy <> zif_stock_allocation=>c_strategy_smallest_first.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Allocation strategy must be F, P, E, or S' ).
    ENDIF.
  ENDMETHOD.

  METHOD validate_demands.
    DATA lt_keys TYPE tt_demand_keys.
    LOOP AT it_demands INTO DATA(ls_demand) WHERE requested_qty > 0.
      IF ls_demand-sales_order IS INITIAL
          OR ls_demand-sales_item IS INITIAL
          OR ls_demand-schedule_line IS INITIAL
          OR ls_demand-delivery_date IS INITIAL.
        RAISE EXCEPTION NEW zcx_stock_allocation(
          'Open demand contains an incomplete schedule-line key or date' ).
      ENDIF.

      INSERT VALUE #(
        sales_order = ls_demand-sales_order
        sales_item = ls_demand-sales_item
        schedule_line = ls_demand-schedule_line ) INTO TABLE lt_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION NEW zcx_stock_allocation(
          'Open demand contains a duplicate schedule-line key' ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
