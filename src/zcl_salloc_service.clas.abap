CLASS zcl_salloc_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_stock TYPE REF TO zif_salloc_stock
        io_orders TYPE REF TO zif_salloc_orders.
    METHODS run
      IMPORTING
        iv_material TYPE zif_salloc_types=>ty_material
        iv_plant TYPE zif_salloc_types=>ty_plant
      RETURNING
        VALUE(rt_allocations) TYPE zif_salloc_types=>tt_demands
      RAISING
        zcx_salloc_invalid.
  PRIVATE SECTION.
    DATA mo_stock TYPE REF TO zif_salloc_stock.
    DATA mo_orders TYPE REF TO zif_salloc_orders.
ENDCLASS.

CLASS zcl_salloc_service IMPLEMENTATION.
  METHOD constructor.
    mo_stock = io_stock.
    mo_orders = io_orders.
  ENDMETHOD.

  METHOD run.
    IF iv_material IS INITIAL OR iv_plant IS INITIAL.
      RAISE EXCEPTION TYPE zcx_salloc_invalid
        EXPORTING iv_reason = `Material and plant are required`.
    ENDIF.

    DATA(available) = mo_stock->get_available(
      iv_material = iv_material
      iv_plant = iv_plant ).
    rt_allocations = mo_orders->get_open_demands(
      iv_material = iv_material
      iv_plant = iv_plant ).
    DATA(remaining) = zcl_salloc_allocator=>allocate(
      EXPORTING iv_available = available
      CHANGING ct_demands = rt_allocations ).
    DATA(reserved) = available - remaining.

    IF reserved > 0.
      mo_stock->reserve(
        iv_material = iv_material
        iv_plant = iv_plant
        iv_quantity = reserved ).
      mo_orders->save_allocations( rt_allocations ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
