CLASS lcl_gateway DEFINITION FINAL INHERITING FROM zcl_stock_reservation_sap.
  PUBLIC SECTION.
    DATA response TYPE zif_stock_reservation=>ty_result.
    DATA captured_header TYPE bapi2093_res_head.
    DATA captured_items TYPE ty_items.
    DATA captured_test TYPE abap_bool.
    DATA calls TYPE i.
  PROTECTED SECTION.
    METHODS invoke REDEFINITION.
ENDCLASS.

CLASS lcl_gateway IMPLEMENTATION.
  METHOD invoke.
    calls = calls + 1.
    captured_header = header.
    captured_items = items.
    captured_test = test_run.
    result = response.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_reservation DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA gateway TYPE REF TO lcl_gateway.
    DATA writer TYPE REF TO zif_stock_reservation.
    DATA allocations TYPE zif_stock_alloc_types=>ty_allocations.
    METHODS setup.
    METHODS maps_allocated_quantity FOR TESTING RAISING zcx_stock_alloc.
    METHODS defaults_to_simulation FOR TESTING RAISING zcx_stock_alloc.
    METHODS preserves_sap_errors FOR TESTING.
    METHODS requires_document_number FOR TESTING.
    METHODS rejects_invalid_results FOR TESTING.
    METHODS skips_zero_allocations FOR TESTING RAISING zcx_stock_alloc.
    METHODS standard_stub_fails_closed FOR TESTING.
ENDCLASS.

CLASS ltcl_reservation IMPLEMENTATION.
  METHOD setup.
    gateway = NEW #( ).
    writer = gateway.
    gateway->response-reservation = '0000000123'.
    allocations = VALUE #( ( request_id = 'A' material = 'MAT1' plant = '1000' storage = '0001'
                             unit = 'EA' required_date = '20260906'
                             requested = 10 allocated = 4 shortage = 6 status = 'PARTIAL' ) ).
  ENDMETHOD.

  METHOD maps_allocated_quantity.
    DATA(result) = writer->create( allocations = allocations
                                  cost_center  = '0000001000'
                                  base_date    = '20260905'
                                  test_run     = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = result-reservation
                                        exp = '0000000123' ).
    cl_abap_unit_assert=>assert_equals( act = gateway->captured_items[ 1 ]-entry_qnt
                                        exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = gateway->captured_header-move_type
                                        exp = '201' ).
    cl_abap_unit_assert=>assert_equals( act = gateway->captured_header-cost_ctr
                                        exp = '0000001000' ).
    cl_abap_unit_assert=>assert_equals( act = gateway->captured_items[ 1 ]-req_date
                                        exp = '20260906' ).
  ENDMETHOD.

  METHOD defaults_to_simulation.
    DATA(result) = writer->create( allocations = allocations
                                  cost_center  = '0000001000'
                                  base_date    = '20260905' ).
    cl_abap_unit_assert=>assert_true( result-simulated ).
    cl_abap_unit_assert=>assert_true( gateway->captured_test ).
    cl_abap_unit_assert=>assert_initial( result-reservation ).
  ENDMETHOD.

  METHOD preserves_sap_errors.
    gateway->response-messages = VALUE #( ( type = 'W' message = 'Warning' )
                                          ( type = 'E' id = 'M7' number = '001' message = 'No stock' ) ).
    TRY.
        writer->create( allocations = allocations
                        cost_center = '0000001000'
                        base_date   = '20260905' ).
        cl_abap_unit_assert=>fail( 'SAP error was ignored' ).
      CATCH zcx_stock_alloc INTO DATA(error).
        cl_abap_unit_assert=>assert_equals( act = lines( error->messages )
                                            exp = 2 ).
    ENDTRY.
  ENDMETHOD.

  METHOD requires_document_number.
    CLEAR gateway->response.
    TRY.
        writer->create( allocations = allocations
                        cost_center = '0000001000'
                        base_date   = '20260905'
                        test_run    = abap_false ).
        cl_abap_unit_assert=>fail( 'Missing document number accepted' ).
      CATCH zcx_stock_alloc.
    ENDTRY.
  ENDMETHOD.

  METHOD rejects_invalid_results.
    allocations[ 1 ]-allocated = 11.
    TRY.
        writer->create( allocations = allocations
                        cost_center = '0000001000'
                        base_date   = '20260905' ).
        cl_abap_unit_assert=>fail( 'Invalid allocation accepted' ).
      CATCH zcx_stock_alloc.
        cl_abap_unit_assert=>assert_equals( act = gateway->calls
                                            exp = 0 ).
    ENDTRY.
  ENDMETHOD.

  METHOD skips_zero_allocations.
    APPEND VALUE #( request_id = 'B' material = 'MAT2' plant = '1000' storage = '0001'
                    unit = 'EA' required_date = '20260906' requested = 3 shortage = 3 ) TO allocations.
    writer->create( allocations = allocations
                    cost_center = '0000001000'
                    base_date   = '20260905' ).
    cl_abap_unit_assert=>assert_equals( act = lines( gateway->captured_items )
                                        exp = 1 ).
  ENDMETHOD.

  METHOD standard_stub_fails_closed.
    writer = NEW zcl_stock_reservation_sap( ).
    TRY.
        writer->create( allocations = allocations
                        cost_center = '0000001000'
                        base_date   = '20260905' ).
        cl_abap_unit_assert=>fail( 'Local standard stub pretended to reserve stock' ).
      CATCH zcx_stock_alloc INTO DATA(error).
        cl_abap_unit_assert=>assert_equals( act = error->messages[ 1 ]-type
                                            exp = 'E' ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
