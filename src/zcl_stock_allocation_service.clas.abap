CLASS zcl_stock_allocation_service DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING io_stock_reader TYPE REF TO zif_stock_reader OPTIONAL.
    METHODS run
      IMPORTING iv_material      TYPE mard-matnr
                iv_plant         TYPE mard-werks
                it_requirements  TYPE zcl_stock_allocator=>ty_requirements
                iv_safety_stock  TYPE mard-labst DEFAULT 0
                iv_full_delivery TYPE abap_bool DEFAULT abap_false
                iv_horizon       TYPE d OPTIONAL
                it_locations     TYPE zcl_stock_allocator=>ty_locations OPTIONAL
      RETURNING VALUE(rs_plan)   TYPE zcl_stock_allocator=>ty_plan.
  PRIVATE SECTION.
    DATA mo_stock_reader TYPE REF TO zif_stock_reader.
ENDCLASS.

CLASS zcl_stock_allocation_service IMPLEMENTATION.
  METHOD constructor.
    mo_stock_reader = io_stock_reader.
    IF mo_stock_reader IS NOT BOUND.
      mo_stock_reader = NEW zcl_stock_reader_mard( ).
    ENDIF.
  ENDMETHOD.

  METHOD run.
    IF iv_material IS INITIAL OR iv_plant IS INITIAL OR it_requirements IS INITIAL.
      RETURN.
    ENDIF.
    DATA(stock) = mo_stock_reader->read_stock( iv_material = iv_material iv_plant = iv_plant ).
    rs_plan = zcl_stock_allocator=>plan(
      it_stock         = stock
      it_requirements  = it_requirements
      iv_material      = iv_material
      iv_plant         = iv_plant
      iv_safety_stock  = iv_safety_stock
      iv_full_delivery = iv_full_delivery
      iv_horizon       = iv_horizon
      it_locations     = it_locations ).
  ENDMETHOD.
ENDCLASS.
