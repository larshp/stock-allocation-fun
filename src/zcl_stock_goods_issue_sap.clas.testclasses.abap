CLASS lcl_gateway DEFINITION FINAL INHERITING FROM zcl_stock_goods_issue_sap.
  PUBLIC SECTION.
    DATA response TYPE zif_stock_goods_issue=>ty_result.
    DATA captured_header TYPE bapi2017_gm_head_01.
    DATA captured_code TYPE bapi2017_gm_code.
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
    captured_code = code.
    captured_items = items.
    captured_test = test_run.
    result = response.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_goods_issue DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA gateway TYPE REF TO lcl_gateway.
    DATA writer TYPE REF TO zif_stock_goods_issue.
    DATA allocations TYPE zif_stock_alloc_types=>ty_allocations.
    METHODS setup.
    METHODS maps_cost_center_issue FOR TESTING RAISING zcx_stock_alloc.
    METHODS defaults_to_test_mode FOR TESTING RAISING zcx_stock_alloc.
    METHODS preserves_sap_errors FOR TESTING.
    METHODS preserves_warnings FOR TESTING RAISING zcx_stock_alloc.
    METHODS rejects_invalid_allocations FOR TESTING.
    METHODS rejects_invalid_header FOR TESTING.
    METHODS requires_document_key FOR TESTING.
    METHODS standard_stub_fails_closed FOR TESTING.
    METHODS rejects_referenced_demand FOR TESTING.
    METHODS assert_rejected_before_call
      IMPORTING posting_date  TYPE d DEFAULT '20260906'
                document_date TYPE d DEFAULT '20260905'
                cost_center   TYPE bapi2017_gm_item_create-costcenter DEFAULT '0000001000'
                test_run      TYPE abap_bool DEFAULT abap_true.
ENDCLASS.

CLASS ltcl_goods_issue IMPLEMENTATION.
  METHOD setup.
    gateway = NEW #( ).
    writer = gateway.
    gateway->response-material_document = '4900000123'.
    gateway->response-document_year = '2026'.
    allocations = VALUE #( ( request_id = 'A' material = 'MAT1' plant = '1000' storage = '0001'
      unit = 'EA' required_date = '20260906' requested = '0.300' allocated = '0.100' shortage = '0.200' )
      ( request_id = 'B' material = 'MAT1' plant = '1000' storage = '0001'
      unit = 'EA' required_date = '20260906' requested = 2 shortage = 2 ) ).
  ENDMETHOD.

  METHOD maps_cost_center_issue.
    DATA(result) = writer->create( allocations  = allocations
                                  cost_center   = '0000001000'
                                  posting_date  = '20260906'
                                  document_date = '20260905'
                                  test_run      = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = result-material_document
                                      exp   = '4900000123' ).
    cl_abap_unit_assert=>assert_equals( act = result-document_year
                                      exp   = '2026' ).
    cl_abap_unit_assert=>assert_false( result-simulated ).
    cl_abap_unit_assert=>assert_equals( act = gateway->captured_header-pstng_date
                                      exp   = '20260906' ).
    cl_abap_unit_assert=>assert_equals( act = gateway->captured_header-doc_date
                                      exp   = '20260905' ).
    cl_abap_unit_assert=>assert_equals( act = gateway->captured_code-gm_code
                                      exp   = '03' ).
    cl_abap_unit_assert=>assert_equals( act = lines( gateway->captured_items )
                                      exp   = 1 ).
    cl_abap_unit_assert=>assert_equals( act = gateway->captured_items[ 1 ]-material
                                      exp   = 'MAT1' ).
    cl_abap_unit_assert=>assert_equals( act = gateway->captured_items[ 1 ]-plant
                                      exp   = '1000' ).
    cl_abap_unit_assert=>assert_equals( act = gateway->captured_items[ 1 ]-stge_loc
                                      exp   = '0001' ).
    cl_abap_unit_assert=>assert_equals( act = gateway->captured_items[ 1 ]-move_type
                                      exp   = '201' ).
    cl_abap_unit_assert=>assert_equals( act = gateway->captured_items[ 1 ]-entry_qnt
                                      exp   = '0.100' ).
    cl_abap_unit_assert=>assert_equals( act = gateway->captured_items[ 1 ]-entry_uom
                                      exp   = 'EA' ).
    cl_abap_unit_assert=>assert_equals( act = gateway->captured_items[ 1 ]-costcenter
                                      exp   = '0000001000' ).
    cl_abap_unit_assert=>assert_initial( gateway->captured_items[ 1 ]-mvt_ind ).
  ENDMETHOD.

  METHOD defaults_to_test_mode.
    DATA(result) = writer->create( allocations  = allocations
                                  cost_center   = '0000001000'
                                  posting_date  = '20260906'
                                  document_date = '20260905' ).
    cl_abap_unit_assert=>assert_true( result-simulated ).
    cl_abap_unit_assert=>assert_true( gateway->captured_test ).
    cl_abap_unit_assert=>assert_initial( result-material_document ).
    cl_abap_unit_assert=>assert_initial( result-document_year ).
  ENDMETHOD.

  METHOD preserves_sap_errors.
    TYPES ty_message_type TYPE c LENGTH 1.
    DATA types TYPE STANDARD TABLE OF ty_message_type WITH DEFAULT KEY.
    types = VALUE #( ( 'E' ) ( 'A' ) ( 'X' ) ).
    LOOP AT types INTO DATA(message_type).
      gateway->response-messages = VALUE #( ( type = 'W' message = 'Review stock' )
        ( type = message_type id = 'M7' number = '001' message = 'Issue rejected' ) ).
      TRY.
          writer->create( allocations   = allocations
                          cost_center   = '0000001000'
                          posting_date  = '20260906'
                          document_date = '20260905'
                          test_run      = abap_false ).
          cl_abap_unit_assert=>fail( 'SAP failure was ignored' ).
        CATCH zcx_stock_alloc INTO DATA(error).
          cl_abap_unit_assert=>assert_equals( act = error->messages
                                            exp   = gateway->response-messages ).
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD preserves_warnings.
    gateway->response-messages = VALUE #( ( type = 'W' message = 'Review before commit' ) ).
    DATA(result) = writer->create( allocations  = allocations
                                  cost_center   = '0000001000'
                                  posting_date  = '20260906'
                                  document_date = '20260905'
                                  test_run      = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = result-messages
                                      exp   = gateway->response-messages ).
  ENDMETHOD.

  METHOD assert_rejected_before_call.
    TRY.
        writer->create( allocations   = allocations
                        cost_center   = cost_center
                        posting_date  = posting_date
                        document_date = document_date
                        test_run      = test_run ).
        cl_abap_unit_assert=>fail( 'Invalid goods issue input accepted' ).
      CATCH zcx_stock_alloc.
        cl_abap_unit_assert=>assert_initial( gateway->calls ).
    ENDTRY.
  ENDMETHOD.

  METHOD rejects_invalid_allocations.
    APPEND allocations[ 1 ] TO allocations.
    assert_rejected_before_call( ).
    DELETE allocations INDEX 3.
    allocations[ 1 ]-shortage = '0.100'.
    assert_rejected_before_call( ).
    DELETE allocations INDEX 1.
    assert_rejected_before_call( ).
    CLEAR allocations.
    assert_rejected_before_call( ).
  ENDMETHOD.

  METHOD rejects_invalid_header.
    assert_rejected_before_call( posting_date = '20260229' ).
    assert_rejected_before_call( document_date = '20260431' ).
    assert_rejected_before_call( cost_center = space ).
    assert_rejected_before_call( test_run = 'Y' ).
  ENDMETHOD.

  METHOD requires_document_key.
    DO 2 TIMES.
      IF sy-index = 1.
        CLEAR gateway->response-material_document.
      ELSE.
        gateway->response-material_document = '4900000123'.
        CLEAR gateway->response-document_year.
      ENDIF.
      TRY.
          writer->create( allocations   = allocations
                          cost_center   = '0000001000'
                          posting_date  = '20260906'
                          document_date = '20260905'
                          test_run      = abap_false ).
          cl_abap_unit_assert=>fail( 'Missing document key accepted' ).
        CATCH zcx_stock_alloc INTO DATA(error).
          cl_abap_unit_assert=>assert_equals( act = error->reason
                                            exp   = 'SAP returned no complete material document key' ).
      ENDTRY.
    ENDDO.
  ENDMETHOD.

  METHOD standard_stub_fails_closed.
    writer = NEW zcl_stock_goods_issue_sap( ).
    TRY.
        writer->create( allocations   = allocations
                        cost_center   = '0000001000'
                        posting_date  = '20260906'
                        document_date = '20260905' ).
        cl_abap_unit_assert=>fail( 'Local stub pretended to issue stock' ).
      CATCH zcx_stock_alloc INTO DATA(error).
        cl_abap_unit_assert=>assert_equals( act = error->messages[ 1 ]-type
                                          exp   = 'E' ).
    ENDTRY.
  ENDMETHOD.

  METHOD rejects_referenced_demand.
    allocations[ 1 ]-origin-order_id = '000000001000'.
    assert_rejected_before_call( ).
    allocations[ 1 ]-origin = VALUE #( reservation = '0000000100' reservation_item = '0001' ).
    assert_rejected_before_call( ).
  ENDMETHOD.
ENDCLASS.
