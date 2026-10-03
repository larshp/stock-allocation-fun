CLASS lcl_sales_order_api_double DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_sales_order_api.
    METHODS set_read_result
      IMPORTING
        is_result TYPE zif_sales_order_api=>ty_read_result.
    METHODS set_write_result
      IMPORTING
        is_result TYPE zif_sales_order_api=>ty_write_result.
    METHODS set_commit_result
      IMPORTING
        is_result TYPE zif_sales_order_api=>ty_commit_result.
    METHODS get_create_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_change_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_commit_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_rollback_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS was_test_run
      RETURNING
        VALUE(rv_test_run) TYPE abap_bool.
  PRIVATE SECTION.
    DATA ms_read_result TYPE zif_sales_order_api=>ty_read_result.
    DATA ms_write_result TYPE zif_sales_order_api=>ty_write_result.
    DATA ms_commit_result TYPE zif_sales_order_api=>ty_commit_result.
    DATA mv_create_count TYPE i.
    DATA mv_change_count TYPE i.
    DATA mv_commit_count TYPE i.
    DATA mv_rollback_count TYPE i.
    DATA mv_test_run TYPE abap_bool.
ENDCLASS.

CLASS lcl_sales_order_api_double IMPLEMENTATION.
  METHOD set_read_result.
    ms_read_result = is_result.
  ENDMETHOD.

  METHOD set_write_result.
    ms_write_result = is_result.
  ENDMETHOD.

  METHOD set_commit_result.
    ms_commit_result = is_result.
  ENDMETHOD.

  METHOD get_create_count.
    rv_count = mv_create_count.
  ENDMETHOD.

  METHOD get_commit_count.
    rv_count = mv_commit_count.
  ENDMETHOD.

  METHOD get_change_count.
    rv_count = mv_change_count.
  ENDMETHOD.

  METHOD get_rollback_count.
    rv_count = mv_rollback_count.
  ENDMETHOD.

  METHOD was_test_run.
    rv_test_run = mv_test_run.
  ENDMETHOD.

  METHOD zif_sales_order_api~read_order.
    rs_result = ms_read_result.
    IF rs_result-order-sales_document IS INITIAL.
      rs_result-order-sales_document = iv_sales_document.
    ENDIF.
  ENDMETHOD.

  METHOD zif_sales_order_api~create_order.
    ADD 1 TO mv_create_count.
    mv_test_run = iv_test_run.
    rs_result = ms_write_result.
  ENDMETHOD.

  METHOD zif_sales_order_api~change_order.
    ADD 1 TO mv_change_count.
    mv_test_run = iv_test_run.
    rs_result = ms_write_result.
    IF rs_result-sales_document IS INITIAL.
      rs_result-sales_document = iv_sales_document.
    ENDIF.
  ENDMETHOD.

  METHOD zif_sales_order_api~commit.
    ADD 1 TO mv_commit_count.
    rs_result = ms_commit_result.
  ENDMETHOD.

  METHOD zif_sales_order_api~rollback.
    ADD 1 TO mv_rollback_count.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_sales_order_service DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_api TYPE REF TO lcl_sales_order_api_double.
    DATA mo_cut TYPE REF TO zcl_sales_order_service.
    METHODS setup.
    METHODS build_order
      RETURNING
        VALUE(rs_order) TYPE zif_sales_order_api=>ty_order.
    METHODS reads_order_items FOR TESTING.
    METHODS creates_and_commits FOR TESTING.
    METHODS simulates_without_commit FOR TESTING.
    METHODS rolls_back_create_error FOR TESTING.
    METHODS rejects_duplicate_items FOR TESTING.
    METHODS rolls_back_commit_error FOR TESTING.
    METHODS changes_and_commits FOR TESTING.
    METHODS simulates_order_change FOR TESTING.
    METHODS rolls_back_change_error FOR TESTING.
    METHODS rejects_empty_order_change FOR TESTING.
ENDCLASS.

CLASS ltcl_sales_order_service IMPLEMENTATION.
  METHOD setup.
    mo_api = NEW lcl_sales_order_api_double( ).
    mo_api->set_commit_result(
      is_result = VALUE #( is_successful = abap_true ) ).
    mo_cut = NEW zcl_sales_order_service( io_api = mo_api ).
  ENDMETHOD.

  METHOD build_order.
    rs_order = VALUE #(
      order_type              = 'OR'
      sales_organization      = '1000'
      distribution_channel    = '10'
      division                = '00'
      sold_to_party           = '0000001000'
      customer_purchase_order = 'PO-100'
      document_date           = '20260922'
      items                   = VALUE #(
        ( item_number    = '000010'
          schedule_line  = '0001'
          material       = 'MAT-1'
          plant          = '1000'
          quantity       = '2.000'
          entry_unit     = 'EA'
          requested_date = '20261001' ) ) ).
  ENDMETHOD.

  METHOD reads_order_items.
    mo_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          sales_document = '0000004711'
          items          = VALUE #(
            ( item_number        = '000010'
              material           = 'MAT-1'
              plant              = '1000'
              quantity           = '2.000'
              entry_unit         = 'BOX'
              delivered_quantity = '1.000'
              open_quantity      = '1.000'
              base_quantity      = '24.000'
              open_base_quantity = '12.000'
              base_unit          = 'EA' ) ) ) ) ).

    DATA(ls_result) = mo_cut->read_order( '0000004711' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MAT-1'
      act = ls_result-order-items[ 1 ]-material ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-order-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-order-items[ 1 ]-delivered_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-order-items[ 1 ]-open_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '24.000' )
      act = ls_result-order-items[ 1 ]-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = ls_result-order-items[ 1 ]-open_base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-order-items[ 1 ]-base_unit ).
  ENDMETHOD.

  METHOD creates_and_commits.
    mo_api->set_write_result(
      is_result = VALUE #(
        is_successful  = abap_true
        sales_document = '0000004712' ) ).

    DATA(ls_result) = mo_cut->create_order( is_order = build_order( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004712'
      act = ls_result-sales_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD simulates_without_commit.
    mo_api->set_write_result(
      is_result = VALUE #( is_successful = abap_true ) ).

    DATA(ls_result) = mo_cut->create_order(
      is_order    = build_order( )
      iv_test_run = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = mo_api->was_test_run( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_create_error.
    mo_api->set_write_result(
      is_result = VALUE #(
        messages = VALUE #(
          ( type = 'E' message = 'Sales order rejected' ) ) ) ).

    DATA(ls_result) = mo_cut->create_order( is_order = build_order( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rejects_duplicate_items.
    DATA(ls_order) = build_order( ).
    APPEND ls_order-items[ 1 ] TO ls_order-items.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->create_order( is_order = ls_order ).
      CATCH zcx_invalid_sales_order.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_commit_error.
    mo_api->set_write_result(
      is_result = VALUE #(
        is_successful  = abap_true
        sales_document = '0000004712' ) ).
    mo_api->set_commit_result(
      is_result = VALUE #(
        is_successful = abap_false
        message       = VALUE #(
          type    = 'E'
          message = 'Commit failed' ) ) ).

    DATA(ls_result) = mo_cut->create_order( is_order = build_order( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD changes_and_commits.
    mo_api->set_write_result(
      is_result = VALUE #( is_successful = abap_true ) ).
    DATA(ls_order) = build_order( ).

    DATA(ls_result) = mo_cut->change_order(
      iv_sales_document = '0000004711'
      it_items          = ls_order-items ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711'
      act = ls_result-sales_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_change_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD simulates_order_change.
    mo_api->set_write_result(
      is_result = VALUE #( is_successful = abap_true ) ).
    DATA(ls_order) = build_order( ).

    DATA(ls_result) = mo_cut->change_order(
      iv_sales_document = '0000004711'
      it_items          = ls_order-items
      iv_test_run       = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = mo_api->was_test_run( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_change_error.
    mo_api->set_write_result(
      is_result = VALUE #(
        messages = VALUE #(
          ( type = 'E' message = 'Sales order change rejected' ) ) ) ).
    DATA(ls_order) = build_order( ).

    DATA(ls_result) = mo_cut->change_order(
      iv_sales_document = '0000004711'
      it_items          = ls_order-items ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_empty_order_change.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->change_order(
          iv_sales_document = '0000004711'
          it_items          = VALUE #( ) ).
      CATCH zcx_invalid_sales_order.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_change_count( ) ).
  ENDMETHOD.
ENDCLASS.
