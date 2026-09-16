CLASS lcl_reader DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_reader.
    DATA calls TYPE i.
ENDCLASS.

CLASS lcl_reader IMPLEMENTATION.
  METHOD zif_stock_reader~read_stock.
    calls = calls + 1.
    rt_stock = VALUE #( ( mandt = sy-mandt matnr = iv_material werks = iv_plant lgort = '0001' labst = 3 ) ).
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_service DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS database_plan FOR TESTING.
    METHODS repeated_simulation FOR TESTING.
    METHODS injected_reader FOR TESTING.
    METHODS no_demand_no_read FOR TESTING.
ENDCLASS.

CLASS ltcl_service IMPLEMENTATION.
  METHOD database_plan.
    DATA(service) = NEW zcl_stock_allocation_service( ).
    DATA(reqs) = VALUE zcl_stock_allocator=>ty_requirements( ( order_id = '1' item_id = '10' quantity = 15 ) ).
    DATA(plan) = service->run( iv_material = 'MAT1' iv_plant = '1000' it_requirements = reqs ).
    READ TABLE plan-results INDEX 1 INTO DATA(result).
    cl_abap_unit_assert=>assert_equals( act = result-allocated exp = '12.750' ).
    cl_abap_unit_assert=>assert_equals( act = result-shortage exp = '2.250' ).
    cl_abap_unit_assert=>assert_equals( act = lines( plan-picks ) exp = 2 ).
  ENDMETHOD.

  METHOD repeated_simulation.
    DATA(service) = NEW zcl_stock_allocation_service( ).
    DATA(reqs) = VALUE zcl_stock_allocator=>ty_requirements( ( order_id = '1' item_id = '10' quantity = 15 ) ).
    DATA(first) = service->run( iv_material = 'MAT1' iv_plant = '1000' it_requirements = reqs ).
    DATA(second) = service->run( iv_material = 'MAT1' iv_plant = '1000' it_requirements = reqs ).
    cl_abap_unit_assert=>assert_equals( act = second exp = first ).
    READ TABLE second-results INDEX 1 INTO DATA(result).
    cl_abap_unit_assert=>assert_equals( act = result-allocated exp = '12.750' ).
  ENDMETHOD.

  METHOD injected_reader.
    DATA(reader) = NEW lcl_reader( ).
    DATA(service) = NEW zcl_stock_allocation_service( reader ).
    DATA(reqs) = VALUE zcl_stock_allocator=>ty_requirements( ( order_id = '1' item_id = '10' quantity = 5 ) ).
    DATA(plan) = service->run( iv_material = 'CUSTOM' iv_plant = '1000' it_requirements = reqs ).
    READ TABLE plan-results INDEX 1 INTO DATA(result).
    cl_abap_unit_assert=>assert_equals( act = result-allocated exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = result-shortage exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = reader->calls exp = 1 ).
  ENDMETHOD.

  METHOD no_demand_no_read.
    DATA(reader) = NEW lcl_reader( ).
    DATA(service) = NEW zcl_stock_allocation_service( reader ).
    DATA reqs TYPE zcl_stock_allocator=>ty_requirements.
    DATA(plan) = service->run( iv_material = 'MAT1' iv_plant = '1000' it_requirements = reqs ).
    cl_abap_unit_assert=>assert_initial( plan ).
    cl_abap_unit_assert=>assert_equals( act = reader->calls exp = 0 ).
  ENDMETHOD.
ENDCLASS.
