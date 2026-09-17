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
    METHODS selected_location FOR TESTING.
    METHODS unknown_location FOR TESTING.
    METHODS selected_safety_stock FOR TESTING.
    METHODS selected_full_delivery FOR TESTING.
    METHODS empty_locations FOR TESTING.
    METHODS duplicate_locations FOR TESTING.
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

  METHOD selected_location.
    DATA(service) = NEW zcl_stock_allocation_service( ).
    DATA(plan) = service->run(
      iv_material     = 'MAT1'
      iv_plant        = '1000'
      it_requirements = VALUE #( ( quantity = 10 ) )
      it_locations    = VALUE #( ( '0002' ) ) ).
    READ TABLE plan-results INDEX 1 INTO DATA(result).
    cl_abap_unit_assert=>assert_equals( act = result-allocated exp = '8.250' ).
    cl_abap_unit_assert=>assert_equals( act = result-shortage exp = '1.750' ).
    cl_abap_unit_assert=>assert_equals( act = lines( plan-picks ) exp = 1 ).
    READ TABLE plan-picks INDEX 1 INTO DATA(pick).
    cl_abap_unit_assert=>assert_equals( act = pick-location exp = '0002' ).
    cl_abap_unit_assert=>assert_equals( act = pick-quantity exp = '8.250' ).
  ENDMETHOD.

  METHOD unknown_location.
    DATA(service) = NEW zcl_stock_allocation_service( ).
    DATA(plan) = service->run(
      iv_material     = 'MAT1'
      iv_plant        = '1000'
      it_requirements = VALUE #( ( quantity = 10 ) )
      it_locations    = VALUE #( ( 'NONE' ) ) ).
    READ TABLE plan-results INDEX 1 INTO DATA(result).
    cl_abap_unit_assert=>assert_initial( plan-picks ).
    cl_abap_unit_assert=>assert_initial( result-allocated ).
    cl_abap_unit_assert=>assert_equals( act = result-shortage exp = 10 ).
  ENDMETHOD.

  METHOD selected_safety_stock.
    DATA(service) = NEW zcl_stock_allocation_service( ).
    DATA(plan) = service->run(
      iv_material     = 'MAT1'
      iv_plant        = '1000'
      it_requirements = VALUE #( ( quantity = 10 ) )
      iv_safety_stock = 5
      it_locations    = VALUE #( ( '0002' ) ) ).
    READ TABLE plan-results INDEX 1 INTO DATA(result).
    cl_abap_unit_assert=>assert_equals( act = result-allocated exp = '3.250' ).
    cl_abap_unit_assert=>assert_equals( act = result-shortage exp = '6.750' ).
  ENDMETHOD.

  METHOD selected_full_delivery.
    DATA(service) = NEW zcl_stock_allocation_service( ).
    DATA(plan) = service->run(
      iv_material      = 'MAT1'
      iv_plant         = '1000'
      it_requirements  = VALUE #( ( quantity = 10 priority = 1 ) ( quantity = 8 priority = 2 ) )
      iv_full_delivery = abap_true
      it_locations     = VALUE #( ( '0002' ) ) ).
    READ TABLE plan-results INDEX 1 INTO DATA(first).
    READ TABLE plan-results INDEX 2 INTO DATA(second).
    cl_abap_unit_assert=>assert_initial( first-allocated ).
    cl_abap_unit_assert=>assert_equals( act = first-shortage exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = second-allocated exp = 8 ).
    cl_abap_unit_assert=>assert_initial( second-shortage ).
  ENDMETHOD.

  METHOD empty_locations.
    DATA(service) = NEW zcl_stock_allocation_service( ).
    DATA(plan) = service->run(
      iv_material     = 'MAT1'
      iv_plant        = '1000'
      it_requirements = VALUE #( ( quantity = 15 ) )
      it_locations    = VALUE #( ) ).
    READ TABLE plan-results INDEX 1 INTO DATA(result).
    cl_abap_unit_assert=>assert_equals( act = result-allocated exp = '12.750' ).
    cl_abap_unit_assert=>assert_equals( act = lines( plan-picks ) exp = 2 ).
  ENDMETHOD.

  METHOD duplicate_locations.
    DATA(service) = NEW zcl_stock_allocation_service( ).
    DATA(plan) = service->run(
      iv_material     = 'MAT1'
      iv_plant        = '1000'
      it_requirements = VALUE #( ( quantity = 20 ) )
      it_locations    = VALUE #( ( '0002' ) ( '0002' ) ( '0001' ) ) ).
    READ TABLE plan-results INDEX 1 INTO DATA(result).
    cl_abap_unit_assert=>assert_equals( act = result-allocated exp = '12.750' ).
    cl_abap_unit_assert=>assert_equals( act = result-shortage exp = '7.250' ).
    cl_abap_unit_assert=>assert_equals( act = lines( plan-picks ) exp = 2 ).
    READ TABLE plan-picks INDEX 1 INTO DATA(first).
    cl_abap_unit_assert=>assert_equals( act = first-location exp = '0001' ).
  ENDMETHOD.
ENDCLASS.
