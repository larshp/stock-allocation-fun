CLASS lcl_stock_source DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_source.
    METHODS constructor
      IMPORTING
        iv_quantity TYPE zif_stock_allocation=>ty_quantity.
  PRIVATE SECTION.
    DATA mv_quantity TYPE zif_stock_allocation=>ty_quantity.
ENDCLASS.

CLASS lcl_stock_source IMPLEMENTATION.
  METHOD constructor.
    mv_quantity = iv_quantity.
  ENDMETHOD.

  METHOD zif_stock_source~get_available.
    rv_quantity = mv_quantity.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_demand_source DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_demand_source.
    METHODS constructor
      IMPORTING
        it_demands TYPE zif_stock_allocation=>tt_demands.
  PRIVATE SECTION.
    DATA mt_demands TYPE zif_stock_allocation=>tt_demands.
ENDCLASS.

CLASS lcl_demand_source IMPLEMENTATION.
  METHOD constructor.
    mt_demands = it_demands.
  ENDMETHOD.

  METHOD zif_demand_source~get_open_demands.
    rt_demands = mt_demands.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_allocation_sink DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_sink.
    METHODS get_saved
      RETURNING
        VALUE(rt_allocations) TYPE zif_stock_allocation=>tt_allocations.
  PRIVATE SECTION.
    DATA mt_allocations TYPE zif_stock_allocation=>tt_allocations.
ENDCLASS.

CLASS lcl_allocation_sink IMPLEMENTATION.
  METHOD zif_allocation_sink~save.
    mt_allocations = it_allocations.
  ENDMETHOD.

  METHOD get_saved.
    rt_allocations = mt_allocations.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_stock_allocation_service DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS orchestrates_and_saves FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_allocation_service IMPLEMENTATION.
  METHOD orchestrates_and_saves.
    DATA(lt_demands) = VALUE zif_stock_allocation=>tt_demands(
      ( sales_order = '1'
        sales_item = '000010'
        schedule_line = '0001'
        delivery_date = '20250101'
        requested_qty = '7' ) ).
    DATA(lo_sink) = NEW lcl_allocation_sink( ).
    DATA(lo_service) = NEW zcl_stock_allocation_service(
      io_stock_source = NEW lcl_stock_source( '5' )
      io_demand_source = NEW lcl_demand_source( lt_demands )
      io_allocation_sink = lo_sink ).

    DATA(lt_result) = lo_service->run(
      iv_material = 'MAT-1'
      iv_plant = '1000'
      iv_storage_location = '0001' ).
    DATA(lt_saved) = lo_sink->get_saved( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_saved ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty exp = '5' ).
    cl_abap_unit_assert=>assert_equals( act = lt_saved[ 1 ]-shortage_qty exp = '2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_saved[ 1 ]-schedule_line exp = '0001' ).
  ENDMETHOD.
ENDCLASS.
