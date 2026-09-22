CLASS lcl_boundary DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_reservation_source.
    INTERFACES zif_stock_reserved_issue.
    DATA requests TYPE zif_stock_alloc_types=>ty_requests.
    DATA captured_keys TYPE zif_stock_reservation_source=>ty_references.
    DATA captured_allocations TYPE zif_stock_alloc_types=>ty_allocations.
    DATA captured_posting TYPE d.
    DATA captured_document TYPE d.
    DATA captured_test TYPE abap_bool.
    DATA response TYPE zif_stock_reserved_issue=>ty_result.
    DATA reads TYPE i.
    DATA writes TYPE i.
    DATA fail_read TYPE abap_bool.
    DATA fail_write TYPE abap_bool.
ENDCLASS.

CLASS lcl_boundary IMPLEMENTATION.
  METHOD zif_stock_reservation_source~read.
    reads = reads + 1.
    captured_keys = references.
    IF fail_read = abap_true.
      RAISE EXCEPTION TYPE zcx_stock_alloc EXPORTING reason = 'Read failed'.
    ENDIF.
    requests = me->requests.
  ENDMETHOD.
  METHOD zif_stock_reserved_issue~create.
    writes = writes + 1.
    captured_allocations = allocations.
    captured_posting = posting_date.
    captured_document = document_date.
    captured_test = test_run.
    IF fail_write = abap_true.
      RAISE EXCEPTION TYPE zcx_stock_alloc
        EXPORTING reason   = 'Write failed'
                  messages = response-messages.
    ENDIF.
    result = response.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_checked DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA boundary TYPE REF TO lcl_boundary.
    DATA checked TYPE REF TO zif_stock_reserved_issue.
    DATA allocations TYPE zif_stock_alloc_types=>ty_allocations.
    METHODS setup RAISING zcx_stock_alloc.
    METHODS forwards_checked_issue FOR TESTING RAISING zcx_stock_alloc.
    METHODS refreshes_each_call FOR TESTING RAISING zcx_stock_alloc.
    METHODS rejects_changed_identity FOR TESTING.
    METHODS checks_all_items_before_write FOR TESTING.
    METHODS checks_remaining_demand FOR TESTING RAISING zcx_stock_alloc.
    METHODS rejects_source_key_errors FOR TESTING.
    METHODS validates_before_read FOR TESTING.
    METHODS validates_header FOR TESTING.
    METHODS propagates_failures FOR TESTING.
    METHODS requires_dependencies FOR TESTING.
    METHODS assert_rejected.
ENDCLASS.

CLASS ltcl_checked IMPLEMENTATION.
  METHOD setup.
    boundary = NEW #( ).
    checked = NEW zcl_stock_reserved_checked( source = boundary writer = boundary ).
    allocations = VALUE #( ( request_id = 'ORIGINAL' material = 'MAT1' plant = '1000'
      storage = '0001' unit = 'EA' required_date = '20260906' requested = 8 allocated = 5 shortage = 3
      origin = VALUE #( order_id = '000000001000' reservation = '0000000100' reservation_item = '0001' ) )
      ( request_id = 'ZERO' material = 'MAT1' plant = '1000' storage = '0001' unit = 'EA'
        required_date = '20260907' requested = 6 shortage = 6
        origin = VALUE #( order_id = '000000001000' reservation = '0000000100' reservation_item = '0002' ) ) ).
    boundary->requests = VALUE #( ( request_id = 'CURRENT' material = 'MAT1' plant = '1000'
      storage = '0001' unit = 'EA' required_date = '20260906' quantity = 8 origin = allocations[ 1 ]-origin ) ).
    boundary->response = VALUE #( material_document = '4900000123' document_year = '2026'
                                  messages = VALUE #( ( type = 'W' message = 'Review before commit' ) ) ).
  ENDMETHOD.

  METHOD forwards_checked_issue.
    DATA(result) = checked->create( allocations   = allocations
                                    posting_date  = '20260922'
                                    document_date = '20260921'
                                    test_run      = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = boundary->captured_allocations exp = allocations ).
    cl_abap_unit_assert=>assert_equals( act = lines( boundary->captured_keys ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = boundary->captured_keys[ 1 ] exp = allocations[ 1 ]-origin ).
    cl_abap_unit_assert=>assert_equals( act = boundary->captured_posting exp = '20260922' ).
    cl_abap_unit_assert=>assert_equals( act = boundary->captured_document exp = '20260921' ).
    cl_abap_unit_assert=>assert_false( boundary->captured_test ).
    cl_abap_unit_assert=>assert_equals( act = result exp = boundary->response ).
    result = checked->create( allocations   = allocations
                              posting_date  = '20260922'
                              document_date = '20260921' ).
    cl_abap_unit_assert=>assert_true( boundary->captured_test ).
  ENDMETHOD.

  METHOD refreshes_each_call.
    checked->create( allocations = allocations posting_date = '20260922' document_date = '20260921' ).
    CLEAR boundary->requests.
    TRY.
        checked->create( allocations = allocations posting_date = '20260922' document_date = '20260921' ).
        cl_abap_unit_assert=>fail( 'Disappeared reservation was issued' ).
      CATCH zcx_stock_alloc.
        cl_abap_unit_assert=>assert_equals( act = boundary->reads exp = 2 ).
        cl_abap_unit_assert=>assert_equals( act = boundary->writes exp = 1 ).
    ENDTRY.
  ENDMETHOD.

  METHOD rejects_changed_identity.
    DATA(original) = boundary->requests.
    DO 6 TIMES.
      boundary->requests = original.
      CASE sy-index.
        WHEN 1.
          boundary->requests[ 1 ]-material = 'OTHER'.
        WHEN 2.
          boundary->requests[ 1 ]-plant = '2000'.
        WHEN 3.
          boundary->requests[ 1 ]-storage = '0002'.
        WHEN 4.
          boundary->requests[ 1 ]-unit = 'KG'.
        WHEN 5.
          boundary->requests[ 1 ]-required_date = '20260907'.
        WHEN 6.
          boundary->requests[ 1 ]-origin-order_id = '000000002000'.
      ENDCASE.
      assert_rejected( ).
    ENDDO.
  ENDMETHOD.

  METHOD checks_all_items_before_write.
    allocations[ 2 ]-allocated = 1.
    allocations[ 2 ]-shortage = 5.
    APPEND VALUE #( request_id = 'SECOND-CURRENT' material = 'CHANGED' plant = '1000'
      storage = '0001' unit = 'EA' required_date = '20260907' quantity = 6
      origin = allocations[ 2 ]-origin ) TO boundary->requests.
    assert_rejected( ).
  ENDMETHOD.

  METHOD checks_remaining_demand.
    allocations[ 1 ]-requested = '0.300'.
    allocations[ 1 ]-allocated = '0.100'.
    allocations[ 1 ]-shortage = '0.200'.
    boundary->requests[ 1 ]-quantity = '0.099'.
    assert_rejected( ).
    boundary->requests[ 1 ]-quantity = '0.100'.
    checked->create( allocations = allocations posting_date = '20260922' document_date = '20260921' ).
    cl_abap_unit_assert=>assert_equals( act = boundary->writes exp = 1 ).
  ENDMETHOD.

  METHOD rejects_source_key_errors.
    DATA(original) = boundary->requests.
    APPEND boundary->requests[ 1 ] TO boundary->requests.
    boundary->requests[ 2 ]-request_id = 'DUPLICATE-KEY'.
    assert_rejected( ).
    boundary->requests[ 2 ]-origin-reservation_item = '0099'.
    assert_rejected( ).
    boundary->requests = original.
    boundary->requests[ 1 ]-origin-reservation_type = '1'.
    assert_rejected( ).
    boundary->requests = original.
    CLEAR boundary->requests[ 1 ]-origin.
    assert_rejected( ).
    boundary->requests = original.
    boundary->requests[ 1 ]-quantity = 0.
    assert_rejected( ).
  ENDMETHOD.

  METHOD validates_before_read.
    DATA(original) = allocations.
    allocations[ 2 ]-origin = allocations[ 1 ]-origin.
    assert_rejected( ).
    allocations = original.
    CLEAR allocations[ 2 ]-origin.
    assert_rejected( ).
    allocations = original.
    allocations[ 1 ]-shortage = 0.
    assert_rejected( ).
    allocations = original.
    DELETE allocations INDEX 1.
    assert_rejected( ).
    CLEAR allocations.
    assert_rejected( ).
    cl_abap_unit_assert=>assert_initial( boundary->reads ).
  ENDMETHOD.

  METHOD validates_header.
    TRY.
        checked->create( allocations = allocations posting_date = '20260229' document_date = '20260921' ).
        cl_abap_unit_assert=>fail( 'Invalid posting date accepted' ).
      CATCH zcx_stock_alloc.
    ENDTRY.
    TRY.
        checked->create( allocations = allocations posting_date = '20260922' document_date = '00000000' ).
        cl_abap_unit_assert=>fail( 'Invalid document date accepted' ).
      CATCH zcx_stock_alloc.
    ENDTRY.
    TRY.
        checked->create( allocations = allocations posting_date = '20260922'
                         document_date = '20260921' test_run = 'Y' ).
        cl_abap_unit_assert=>fail( 'Invalid test mode accepted' ).
      CATCH zcx_stock_alloc.
    ENDTRY.
    cl_abap_unit_assert=>assert_initial( boundary->reads ).
    cl_abap_unit_assert=>assert_initial( boundary->writes ).
  ENDMETHOD.

  METHOD propagates_failures.
    boundary->fail_read = abap_true.
    TRY.
        checked->create( allocations = allocations posting_date = '20260922' document_date = '20260921' ).
        cl_abap_unit_assert=>fail( 'Source failure ignored' ).
      CATCH zcx_stock_alloc INTO DATA(error).
        cl_abap_unit_assert=>assert_equals( act = error->reason exp = 'Read failed' ).
        cl_abap_unit_assert=>assert_initial( boundary->writes ).
    ENDTRY.
    boundary->fail_read = abap_false.
    boundary->fail_write = abap_true.
    TRY.
        checked->create( allocations = allocations posting_date = '20260922' document_date = '20260921' ).
        cl_abap_unit_assert=>fail( 'Writer failure ignored' ).
      CATCH zcx_stock_alloc INTO error.
        cl_abap_unit_assert=>assert_equals( act = error->reason exp = 'Write failed' ).
        cl_abap_unit_assert=>assert_equals( act = error->messages exp = boundary->response-messages ).
    ENDTRY.
  ENDMETHOD.

  METHOD requires_dependencies.
    DATA no_source TYPE REF TO zif_stock_reservation_source.
    DATA no_writer TYPE REF TO zif_stock_reserved_issue.
    TRY.
        DATA(invalid) = NEW zcl_stock_reserved_checked( source = no_source writer = boundary ).
        cl_abap_unit_assert=>fail( 'Missing source accepted' ).
      CATCH zcx_stock_alloc.
    ENDTRY.
    TRY.
        invalid = NEW #( source = boundary writer = no_writer ).
        cl_abap_unit_assert=>fail( 'Missing writer accepted' ).
      CATCH zcx_stock_alloc.
    ENDTRY.
  ENDMETHOD.

  METHOD assert_rejected.
    TRY.
        checked->create( allocations = allocations posting_date = '20260922' document_date = '20260921' ).
        cl_abap_unit_assert=>fail( 'Unverified issue accepted' ).
      CATCH zcx_stock_alloc.
        cl_abap_unit_assert=>assert_initial( boundary->writes ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
