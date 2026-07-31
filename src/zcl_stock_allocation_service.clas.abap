CLASS zcl_stock_allocation_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_stock_source TYPE REF TO zif_stock_source
        io_order_source TYPE REF TO zif_order_source
        io_sink         TYPE REF TO zif_allocation_sink
        io_allocator    TYPE REF TO zif_stock_allocation
        io_reservation  TYPE REF TO zif_stock_reservation.
    METHODS allocate
      IMPORTING
        iv_material         TYPE zif_stock_allocation=>ty_material
        iv_plant            TYPE zif_stock_allocation=>ty_plant
        iv_storage_location TYPE zif_stock_allocation=>ty_storage_location
        iv_movement_type    TYPE zif_stock_allocation=>ty_movement_type
        iv_unit             TYPE zif_stock_allocation=>ty_unit
      RETURNING
        VALUE(rv_remaining) TYPE zif_stock_allocation=>ty_quantity
      RAISING
        zcx_stock_allocation.
  PRIVATE SECTION.
    DATA mo_stock_source TYPE REF TO zif_stock_source.
    DATA mo_order_source TYPE REF TO zif_order_source.
    DATA mo_sink TYPE REF TO zif_allocation_sink.
    DATA mo_allocator TYPE REF TO zif_stock_allocation.
    DATA mo_reservation TYPE REF TO zif_stock_reservation.
ENDCLASS.

CLASS zcl_stock_allocation_service IMPLEMENTATION.
  METHOD constructor.
    mo_stock_source = io_stock_source.
    mo_order_source = io_order_source.
    mo_sink = io_sink.
    mo_allocator = io_allocator.
    mo_reservation = io_reservation.
  ENDMETHOD.

  METHOD allocate.
    DATA lv_available TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_to_reserve TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_reservation_id TYPE zif_stock_allocation=>ty_order_id.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.

    lv_available = mo_stock_source->get_available(
      iv_material         = iv_material
      iv_plant            = iv_plant
      iv_storage_location = iv_storage_location ).
    lt_demands = mo_order_source->get_open_demands(
      iv_material = iv_material
      iv_plant    = iv_plant ).
    rv_remaining = mo_allocator->allocate(
      EXPORTING
        iv_available = lv_available
      CHANGING
        ct_demands   = lt_demands ).
    LOOP AT lt_demands ASSIGNING FIELD-SYMBOL(<ls_demand>).
      lv_to_reserve = lv_to_reserve + <ls_demand>-allocated.
    ENDLOOP.
    IF lv_to_reserve > 0.
      lv_reservation_id = mo_reservation->reserve(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_movement_type    = iv_movement_type
          iv_quantity         = lv_to_reserve
          iv_unit             = iv_unit ).
      LOOP AT lt_demands ASSIGNING <ls_demand>.
        IF <ls_demand>-allocated > 0.
          <ls_demand>-reservation_id = lv_reservation_id.
        ENDIF.
    ENDLOOP.
    ENDIF.
    mo_sink->save_allocations(
      iv_material = iv_material
      iv_plant    = iv_plant
      it_demands  = lt_demands ).
  ENDMETHOD.
ENDCLASS.
