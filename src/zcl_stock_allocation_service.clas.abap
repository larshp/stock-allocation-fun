CLASS zcl_stock_allocation_service DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_stock_source    TYPE REF TO zif_stock_source
        io_demand_source   TYPE REF TO zif_demand_source
        io_allocation_sink TYPE REF TO zif_allocation_sink.
    METHODS run
      IMPORTING
        iv_material           TYPE zif_stock_allocation=>ty_material
        iv_plant              TYPE zif_stock_allocation=>ty_plant
        iv_storage_location   TYPE zif_stock_allocation=>ty_storage_loc
      RETURNING
        VALUE(rt_allocations) TYPE zif_stock_allocation=>tt_allocations.
  PRIVATE SECTION.
    DATA mo_stock_source TYPE REF TO zif_stock_source.
    DATA mo_demand_source TYPE REF TO zif_demand_source.
    DATA mo_allocation_sink TYPE REF TO zif_allocation_sink.
ENDCLASS.

CLASS zcl_stock_allocation_service IMPLEMENTATION.
  METHOD constructor.
    ASSERT io_stock_source IS BOUND.
    ASSERT io_demand_source IS BOUND.
    ASSERT io_allocation_sink IS BOUND.
    mo_stock_source = io_stock_source.
    mo_demand_source = io_demand_source.
    mo_allocation_sink = io_allocation_sink.
  ENDMETHOD.

  METHOD run.
    DATA(lv_available) = mo_stock_source->get_available(
      iv_material = iv_material
      iv_plant = iv_plant
      iv_storage_location = iv_storage_location ).
    DATA(lt_demands) = mo_demand_source->get_open_demands(
      iv_material = iv_material
      iv_plant = iv_plant
      iv_storage_location = iv_storage_location ).

    rt_allocations = NEW zcl_stock_allocator( )->allocate(
      iv_available = lv_available
      it_demands = lt_demands ).
    mo_allocation_sink->save(
      iv_material = iv_material
      iv_plant = iv_plant
      iv_storage_location = iv_storage_location
      it_allocations = rt_allocations ).
  ENDMETHOD.
ENDCLASS.
