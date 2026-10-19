CLASS lcl_sales_order_api_double DEFINITION FINAL.
  PUBLIC SECTION.
    TYPES ty_write_results TYPE STANDARD TABLE OF
      zif_sales_order_api=>ty_write_result WITH EMPTY KEY.
    INTERFACES zif_sales_order_api.
    METHODS set_read_result
      IMPORTING
        is_result TYPE zif_sales_order_api=>ty_read_result.
    METHODS set_write_result
      IMPORTING
        is_result TYPE zif_sales_order_api=>ty_write_result.
    METHODS set_create_results
      IMPORTING
        it_results TYPE ty_write_results.
    METHODS set_change_results
      IMPORTING
        it_results TYPE ty_write_results.
    METHODS set_reject_results
      IMPORTING
        it_results TYPE ty_write_results.
    METHODS get_last_rejections
      RETURNING
        VALUE(rt_rejections) TYPE zif_sales_order_api=>ty_item_rejections.
    METHODS set_commit_result
      IMPORTING
        is_result TYPE zif_sales_order_api=>ty_commit_result.
    METHODS get_create_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_bulk_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_change_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_reject_count
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
    DATA mt_create_results TYPE ty_write_results.
    DATA mt_change_results TYPE ty_write_results.
    DATA mt_reject_results TYPE ty_write_results.
    DATA mt_last_rejections TYPE zif_sales_order_api=>ty_item_rejections.
    DATA mv_create_count TYPE i.
    DATA mv_read_count TYPE i.
    DATA mv_bulk_read_count TYPE i.
    DATA mv_change_count TYPE i.
    DATA mv_reject_count TYPE i.
    DATA mv_delete_count TYPE i.
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

  METHOD set_create_results.
    mt_create_results = it_results.
  ENDMETHOD.

  METHOD set_change_results.
    mt_change_results = it_results.
  ENDMETHOD.

  METHOD set_reject_results.
    mt_reject_results = it_results.
  ENDMETHOD.

  METHOD get_last_rejections.
    rt_rejections = mt_last_rejections.
  ENDMETHOD.

  METHOD set_commit_result.
    ms_commit_result = is_result.
  ENDMETHOD.

  METHOD get_create_count.
    rv_count = mv_create_count.
  ENDMETHOD.

  METHOD get_read_count.
    rv_count = mv_read_count.
  ENDMETHOD.

  METHOD get_bulk_read_count.
    rv_count = mv_bulk_read_count.
  ENDMETHOD.

  METHOD get_commit_count.
    rv_count = mv_commit_count.
  ENDMETHOD.

  METHOD get_change_count.
    rv_count = mv_change_count.
  ENDMETHOD.

  METHOD get_reject_count.
    rv_count = mv_reject_count.
  ENDMETHOD.

  METHOD get_rollback_count.
    rv_count = mv_rollback_count.
  ENDMETHOD.

  METHOD was_test_run.
    rv_test_run = mv_test_run.
  ENDMETHOD.

  METHOD zif_sales_order_api~read_order.
    ADD 1 TO mv_read_count.
    rs_result = ms_read_result.
    IF rs_result-order-sales_document IS INITIAL.
      rs_result-order-sales_document = iv_sales_document.
    ENDIF.
  ENDMETHOD.

  METHOD zif_sales_order_api~read_orders.
    ADD 1 TO mv_bulk_read_count.
    LOOP AT it_sales_documents INTO DATA(lv_sales_document).
      ADD 1 TO mv_read_count.
      DATA(ls_read_result) = ms_read_result.
      IF ls_read_result-order-sales_document IS INITIAL.
        ls_read_result-order-sales_document = lv_sales_document.
      ENDIF.
      APPEND VALUE #(
        sales_document = lv_sales_document
        read_result    = ls_read_result )
        TO rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_sales_order_api~create_order.
    ADD 1 TO mv_create_count.
    mv_test_run = iv_test_run.
    READ TABLE mt_create_results INDEX mv_create_count INTO rs_result.
    IF sy-subrc <> 0.
      rs_result = ms_write_result.
    ENDIF.
  ENDMETHOD.

  METHOD zif_sales_order_api~change_order.
    ADD 1 TO mv_change_count.
    mv_test_run = iv_test_run.
    READ TABLE mt_change_results INDEX mv_change_count INTO rs_result.
    IF sy-subrc <> 0.
      rs_result = ms_write_result.
    ENDIF.
    IF rs_result-sales_document IS INITIAL.
      rs_result-sales_document = iv_sales_document.
    ENDIF.
  ENDMETHOD.

  METHOD zif_sales_order_api~reject_order_items.
    ADD 1 TO mv_reject_count.
    mv_test_run = iv_test_run.
    mt_last_rejections = it_item_rejections.
    READ TABLE mt_reject_results INDEX mv_reject_count INTO rs_result.
    IF sy-subrc <> 0.
      rs_result = ms_write_result.
    ENDIF.
    IF rs_result-sales_document IS INITIAL.
      rs_result-sales_document = iv_sales_document.
    ENDIF.
  ENDMETHOD.

  METHOD zif_sales_order_api~delete_order_items.
    ADD 1 TO mv_delete_count.
    mv_test_run = iv_test_run.
    rs_result = ms_write_result.
    rs_result-sales_document = iv_sales_document.
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
    METHODS reads_rejected_only_order FOR TESTING.
    METHODS reads_multiple_orders FOR TESTING.
    METHODS rejects_bad_order_read_keys FOR TESTING.
    METHODS empty_order_read_skips_api FOR TESTING.
    METHODS creates_and_commits FOR TESTING.
    METHODS creates_orders_atomically FOR TESTING.
    METHODS creates_orders_in_bulk FOR TESTING.
    METHODS simulates_bulk_order_creates FOR TESTING.
    METHODS checks_bulk_create_input FOR TESTING.
    METHODS simulates_atomic_order_creates FOR TESTING.
    METHODS rolls_back_atomic_create_error FOR TESTING.
    METHODS rejects_create_missing_doc FOR TESTING.
    METHODS rejects_invalid_atomic_orders FOR TESTING.
    METHODS simulates_without_commit FOR TESTING.
    METHODS rolls_back_create_error FOR TESTING.
    METHODS reports_generic_write_error FOR TESTING.
    METHODS rejects_duplicate_items FOR TESTING.
    METHODS rolls_back_commit_error FOR TESTING.
    METHODS rejects_commit_error_message FOR TESTING.
    METHODS changes_and_commits FOR TESTING.
    METHODS simulates_order_change FOR TESTING.
    METHODS rolls_back_change_error FOR TESTING.
    METHODS rejects_empty_order_change FOR TESTING.
    METHODS rejects_invalid_test_run FOR TESTING.
    METHODS changes_orders_atomically FOR TESTING.
    METHODS changes_orders_in_bulk FOR TESTING.
    METHODS checks_bulk_change_input FOR TESTING.
    METHODS simulates_atomic_order_changes FOR TESTING.
    METHODS rolls_back_atomic_order_error FOR TESTING.
    METHODS rolls_back_atomic_commit_error FOR TESTING.
    METHODS rejects_invalid_atomic_changes FOR TESTING.
    METHODS rejects_and_commits_items FOR TESTING.
    METHODS simulates_item_rejection FOR TESTING.
    METHODS rejects_invalid_rejections FOR TESTING.
    METHODS rejects_orders_in_bulk FOR TESTING.
    METHODS rejects_orders_atomically FOR TESTING.
    METHODS rolls_back_atomic_reject_error FOR TESTING.
    METHODS clears_order_item_rejections FOR TESTING.
    METHODS clears_rejections_in_bulk FOR TESTING.
    METHODS clears_rejections_atomically FOR TESTING.
    METHODS rejects_bad_rejection_clears FOR TESTING.
    METHODS rolls_back_atomic_clear_error FOR TESTING.
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
              base_unit          = 'EA' ) )
          rejected_items = VALUE #(
            ( item_number            = '000020'
              material               = 'MAT-2'
              plant                  = '1000'
              sales_quantity         = '3.000'
              sales_unit             = 'EA'
              sales_unit_numerator   = 1
              sales_unit_denominator = 1
              base_quantity          = '3.000'
              base_unit              = 'EA'
              rejection_reason       = '01' ) ) ) ) ).

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
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-order-rejected_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '000020'
      act = ls_result-order-rejected_items[ 1 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '01'
      act = ls_result-order-rejected_items[ 1 ]-rejection_reason ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV bapisdit-req_qty( '3.000' )
      act = ls_result-order-rejected_items[ 1 ]-sales_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_result-order-rejected_items[ 1 ]-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_result-order-rejected_items[ 1 ]-base_unit ).
  ENDMETHOD.

  METHOD reads_rejected_only_order.
    mo_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        order         = VALUE #(
          sales_document = '0000004711'
          rejected_items = VALUE #(
            ( item_number      = '000010'
              material         = 'MAT-1'
              plant            = '1000'
              sales_quantity   = '2.000'
              sales_unit       = 'EA'
              rejection_reason = '02' ) ) ) ) ).

    DATA(ls_result) = mo_cut->read_order( '0000004711' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-order-items ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-order-rejected_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '02'
      act = ls_result-order-rejected_items[ 1 ]-rejection_reason ).
  ENDMETHOD.

  METHOD reads_multiple_orders.
    DATA lt_sales_documents TYPE zcl_sales_order_service=>ty_sales_documents.
    DATA lt_results TYPE zcl_sales_order_service=>ty_order_reads.
    mo_api->set_read_result(
      is_result = VALUE #( is_successful = abap_true ) ).
    APPEND '0000004712' TO lt_sales_documents.
    APPEND '0000004711' TO lt_sales_documents.

    lt_results = mo_cut->read_orders(
      it_sales_documents = lt_sales_documents ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004712'
      act = lt_results[ 1 ]-sales_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004712'
      act = lt_results[ 1 ]-read_result-order-sales_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711'
      act = lt_results[ 2 ]-sales_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_results[ 2 ]-read_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_bulk_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_order_read_keys.
    DATA lt_sales_documents TYPE zcl_sales_order_service=>ty_sales_documents.
    DATA lv_exception_raised TYPE abap_bool.

    APPEND space TO lt_sales_documents.
    TRY.
        mo_cut->read_orders(
          it_sales_documents = lt_sales_documents ).
      CATCH zcx_invalid_sales_order.
        lv_exception_raised = abap_true.
    ENDTRY.
    CLEAR lt_sales_documents.

    APPEND '0000004711' TO lt_sales_documents.
    APPEND '0000004711' TO lt_sales_documents.
    TRY.
        mo_cut->read_orders(
          it_sales_documents = lt_sales_documents ).
      CATCH zcx_invalid_sales_order.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_bulk_read_count( ) ).
  ENDMETHOD.

  METHOD empty_order_read_skips_api.
    DATA(lt_results) = mo_cut->read_orders(
      it_sales_documents = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_bulk_read_count( ) ).
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

  METHOD creates_orders_atomically.
    mo_api->set_write_result(
      is_result = VALUE #(
        is_successful  = abap_true
        sales_document = '0000004712' ) ).
    DATA(ls_order) = build_order( ).
    DATA(ls_result) = mo_cut->create_orders_atomic(
      it_orders = VALUE #( ( ls_order ) ( ls_order ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-order_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004712'
      act = ls_result-order_results[ 1 ]-sales_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-order_results[ 1 ]-write_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD creates_orders_in_bulk.
    mo_api->set_create_results( it_results = VALUE #(
      ( is_successful  = abap_true
        sales_document = '0000004712' )
      ( sales_document = '0000004713'
        messages       = VALUE #( (
          type    = 'E'
          message = 'Second order rejected' ) ) )
      ( is_successful  = abap_true
        sales_document = '0000004714' ) ) ).
    DATA(ls_order) = build_order( ).

    DATA(ls_result) = mo_cut->create_orders_bulk(
      it_orders = VALUE #( ( ls_order ) ( ls_order ) ( ls_order ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-order_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-order_results[ 1 ]-write_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 2 ]-write_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Second order rejected'
      act = ls_result-order_results[ 2 ]-write_result-messages[ 1 ]-message ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-order_results[ 2 ]-sales_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004714'
      act = ls_result-order_results[ 3 ]-sales_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-order_results[ 3 ]-write_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = mo_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD simulates_bulk_order_creates.
    mo_api->set_create_results( it_results = VALUE #(
      ( is_successful = abap_true )
      ( is_successful = abap_true ) ) ).
    DATA(ls_order) = build_order( ).

    DATA(ls_result) = mo_cut->create_orders_bulk(
      it_orders   = VALUE #( ( ls_order ) ( ls_order ) )
      iv_test_run = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-order_results[ 1 ]-write_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 1 ]-write_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD checks_bulk_create_input.
    DATA(ls_order) = build_order( ).
    DATA(ls_invalid_order) = ls_order.
    CLEAR ls_invalid_order-sold_to_party.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->create_orders_bulk(
          it_orders = VALUE #( ( ls_order ) ( ls_invalid_order ) ) ).
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

  METHOD simulates_atomic_order_creates.
    mo_api->set_write_result(
      is_result = VALUE #( is_successful = abap_true ) ).
    DATA(ls_order) = build_order( ).
    DATA(ls_result) = mo_cut->create_orders_atomic(
      it_orders   = VALUE #( ( ls_order ) )
      iv_test_run = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-order_results[ 1 ]-write_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 1 ]-write_result-is_committed ).
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

  METHOD rolls_back_atomic_create_error.
    mo_api->set_create_results( it_results = VALUE #(
      ( is_successful  = abap_true
        sales_document = '0000004712' )
      ( messages = VALUE #( (
        type    = 'E'
        message = 'Sales order create rejected' ) ) ) ) ).
    DATA(ls_order) = build_order( ).
    DATA(ls_result) = mo_cut->create_orders_atomic(
      it_orders = VALUE #( ( ls_order ) ( ls_order ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-order_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 1 ]-write_result-is_successful ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-order_results[ 1 ]-sales_document ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-order_results[ 1 ]-write_result-sales_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 2 ]-write_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rejects_create_missing_doc.
    mo_api->set_write_result(
      is_result = VALUE #( is_successful = abap_true ) ).
    DATA(ls_order) = build_order( ).
    DATA(ls_result) = mo_cut->create_orders_atomic(
      it_orders = VALUE #( ( ls_order ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'E'
      act = ls_result-order_results[ 1 ]-write_result-messages[ 1 ]-type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rejects_invalid_atomic_orders.
    DATA(ls_order) = build_order( ).
    DATA(ls_bad_order) = ls_order.
    CLEAR ls_bad_order-sold_to_party.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->create_orders_atomic(
          it_orders = VALUE #( ( ls_order ) ( ls_bad_order ) ) ).
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
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_committed ).
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

  METHOD reports_generic_write_error.
    DATA(ls_result) = mo_cut->create_order( is_order = build_order( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'E'
      act = ls_result-messages[ 1 ]-type ).
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

  METHOD rejects_commit_error_message.
    mo_api->set_write_result(
      is_result = VALUE #(
        is_successful  = abap_true
        sales_document = '0000004712' ) ).
    mo_api->set_commit_result(
      is_result = VALUE #(
        is_successful = abap_true
        message       = VALUE #(
          type    = 'E'
          message = 'Commit returned an error message' ) ) ).

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
      exp = abap_false
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
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
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_committed ).
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

  METHOD rejects_invalid_test_run.
    DATA(ls_order) = build_order( ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->create_order(
          is_order    = ls_order
          iv_test_run = 'Y' ).
      CATCH zcx_invalid_sales_order.
        lv_exception_raised = abap_true.
    ENDTRY.
    TRY.
        mo_cut->change_order(
          iv_sales_document = '0000004711'
          it_items          = ls_order-items
          iv_test_run       = 'Y' ).
      CATCH zcx_invalid_sales_order.
        lv_exception_raised = abap_true.
    ENDTRY.
    TRY.
        mo_cut->reject_order_items(
          iv_sales_document  = '0000004711'
          it_item_rejections = VALUE #(
            ( item_number = '000010' rejection_reason = '01' ) )
          iv_test_run        = 'Y' ).
      CATCH zcx_invalid_sales_order.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_change_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_reject_count( ) ).
  ENDMETHOD.

  METHOD changes_orders_atomically.
    mo_api->set_write_result(
      is_result = VALUE #( is_successful = abap_true ) ).
    DATA(ls_order) = build_order( ).
    DATA(ls_result) = mo_cut->change_orders_atomic(
      it_changes = VALUE #(
        ( sales_document = '0000004711' items = ls_order-items )
        ( sales_document = '0000004712' items = ls_order-items ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-order_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711'
      act = ls_result-order_results[ 1 ]-sales_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004712'
      act = ls_result-order_results[ 2 ]-write_result-sales_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->get_change_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD changes_orders_in_bulk.
    mo_api->set_change_results( it_results = VALUE #(
      ( is_successful = abap_true )
      ( messages = VALUE #( (
        type    = 'E'
        message = 'Second order change rejected' ) ) )
      ( is_successful = abap_true ) ) ).
    DATA(ls_order) = build_order( ).

    DATA(ls_result) = mo_cut->change_orders_bulk(
      it_changes = VALUE #(
        ( sales_document = '0000004711' items = ls_order-items )
        ( sales_document = '0000004712' items = ls_order-items )
        ( sales_document = '0000004713' items = ls_order-items ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-order_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-order_results[ 1 ]-write_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004712'
      act = ls_result-order_results[ 2 ]-sales_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 2 ]-write_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-order_results[ 3 ]-write_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = mo_api->get_change_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD checks_bulk_change_input.
    DATA(ls_order) = build_order( ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->change_orders_bulk(
          it_changes = VALUE #(
            ( sales_document = '0000004711' items = ls_order-items )
            ( sales_document = '0000004711' items = ls_order-items ) ) ).
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

  METHOD simulates_atomic_order_changes.
    mo_api->set_write_result(
      is_result = VALUE #( is_successful = abap_true ) ).
    DATA(ls_order) = build_order( ).
    DATA(ls_result) = mo_cut->change_orders_atomic(
      it_changes  = VALUE #(
        ( sales_document = '0000004711' items = ls_order-items ) )
      iv_test_run = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-order_results[ 1 ]-write_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 1 ]-write_result-is_committed ).
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

  METHOD rolls_back_atomic_order_error.
    mo_api->set_write_result(
      is_result = VALUE #(
        messages = VALUE #(
          ( type = 'E' message = 'Sales order change rejected' ) ) ) ).
    DATA(ls_order) = build_order( ).
    DATA(ls_result) = mo_cut->change_orders_atomic(
      it_changes = VALUE #(
        ( sales_document = '0000004711' items = ls_order-items )
        ( sales_document = '0000004712' items = ls_order-items ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-order_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 1 ]-write_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 2 ]-write_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 1 ]-write_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_atomic_commit_error.
    mo_api->set_write_result(
      is_result = VALUE #( is_successful = abap_true ) ).
    mo_api->set_commit_result(
      is_result = VALUE #(
        is_successful = abap_true
        message       = VALUE #(
          type    = 'E'
          message = 'Commit failed' ) ) ).
    DATA(ls_order) = build_order( ).
    DATA(ls_result) = mo_cut->change_orders_atomic(
      it_changes = VALUE #(
        ( sales_document = '0000004711' items = ls_order-items ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Commit failed'
      act = ls_result-commit_result-message-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 1 ]-write_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 1 ]-write_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rejects_invalid_atomic_changes.
    DATA(ls_order) = build_order( ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->change_orders_atomic(
          it_changes = VALUE #(
            ( sales_document = '0000004711' items = ls_order-items )
            ( sales_document = '0000004711' items = ls_order-items ) ) ).
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

  METHOD rejects_and_commits_items.
    mo_api->set_write_result(
      is_result = VALUE #( is_successful = abap_true ) ).
    DATA(ls_result) = mo_cut->reject_order_items(
      iv_sales_document  = '0000004711'
      it_item_rejections = VALUE #(
        ( item_number = '000010' rejection_reason = '01' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711'
      act = ls_result-sales_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_reject_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_invalid_rejections.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->reject_order_items(
          iv_sales_document  = '0000004711'
          it_item_rejections = VALUE #(
            ( item_number = '000010' rejection_reason = '01' )
            ( item_number = '000010' rejection_reason = '02' ) ) ).
      CATCH zcx_invalid_sales_order.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_reject_count( ) ).
  ENDMETHOD.

  METHOD simulates_item_rejection.
    mo_api->set_write_result(
      is_result = VALUE #( is_successful = abap_true ) ).
    DATA(ls_result) = mo_cut->reject_order_items(
      iv_sales_document  = '0000004711'
      it_item_rejections = VALUE #(
        ( item_number = '000010' rejection_reason = '01' ) )
      iv_test_run        = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = mo_api->was_test_run( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_orders_in_bulk.
    mo_api->set_reject_results( it_results = VALUE #(
      ( is_successful = abap_true )
      ( messages = VALUE #( (
        type    = 'E'
        message = 'Second order rejection update failed' ) ) )
      ( is_successful = abap_true ) ) ).
    DATA(ls_order_rejection) = VALUE zcl_sales_order_service=>ty_order_rejection(
      item_rejections = VALUE #(
        ( item_number = '000010' rejection_reason = '01' ) ) ).

    DATA(ls_result) = mo_cut->reject_orders_bulk(
      it_rejections = VALUE #(
        ( sales_document  = '0000004711'
          item_rejections = ls_order_rejection-item_rejections )
        ( sales_document  = '0000004712'
          item_rejections = ls_order_rejection-item_rejections )
        ( sales_document  = '0000004713'
          item_rejections = ls_order_rejection-item_rejections ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-order_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-order_results[ 1 ]-write_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 2 ]-write_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-order_results[ 3 ]-write_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = mo_api->get_reject_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rejects_orders_atomically.
    mo_api->set_write_result(
      is_result = VALUE #( is_successful = abap_true ) ).
    DATA(lt_item_rejections) = VALUE zif_sales_order_api=>ty_item_rejections(
      ( item_number = '000010' rejection_reason = '01' ) ).

    DATA(ls_result) = mo_cut->reject_orders_atomic(
      it_rejections = VALUE #(
        ( sales_document  = '0000004711'
          item_rejections = lt_item_rejections )
        ( sales_document  = '0000004712'
          item_rejections = lt_item_rejections ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-order_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->get_reject_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_atomic_reject_error.
    mo_api->set_reject_results( it_results = VALUE #(
      ( is_successful = abap_true )
      ( messages = VALUE #( (
        type    = 'E'
        message = 'Second rejection update failed' ) ) ) ) ).
    DATA(lt_item_rejections) = VALUE zif_sales_order_api=>ty_item_rejections(
      ( item_number = '000010' rejection_reason = '01' ) ).

    DATA(ls_result) = mo_cut->reject_orders_atomic(
      it_rejections = VALUE #(
        ( sales_document  = '0000004711'
          item_rejections = lt_item_rejections )
        ( sales_document  = '0000004712'
          item_rejections = lt_item_rejections ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-order_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 1 ]-write_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 1 ]-write_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD clears_order_item_rejections.
    mo_api->set_write_result(
      is_result = VALUE #( is_successful = abap_true ) ).
    DATA(ls_result) = mo_cut->clear_order_item_rejections(
      iv_sales_document = '0000004711'
      it_item_numbers   = VALUE #(
        ( '000010' )
        ( '000020' ) ) ).
    DATA(lt_submitted) = mo_api->get_last_rejections( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_submitted ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '000010'
      act = lt_submitted[ 1 ]-item_number ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_submitted[ 1 ]-rejection_reason ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_submitted[ 2 ]-rejection_reason ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD clears_rejections_in_bulk.
    mo_api->set_reject_results( it_results = VALUE #(
      ( is_successful = abap_true )
      ( messages = VALUE #( (
        type    = 'E'
        message = 'Second order rejection clear failed' ) ) ) ) ).
    DATA(lt_item_numbers) = VALUE zcl_sales_order_service=>ty_item_numbers(
      ( '000010' ) ).

    DATA(ls_result) = mo_cut->clear_order_rejections_bulk(
      it_clears = VALUE #(
        ( sales_document = '0000004711'
          item_numbers   = lt_item_numbers )
        ( sales_document = '0000004712'
          item_numbers   = lt_item_numbers ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-order_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-order_results[ 1 ]-write_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 2 ]-write_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD clears_rejections_atomically.
    mo_api->set_write_result(
      is_result = VALUE #( is_successful = abap_true ) ).
    DATA(lt_item_numbers) = VALUE zcl_sales_order_service=>ty_item_numbers(
      ( '000010' ) ).
    DATA(lt_more_item_numbers) =
      VALUE zcl_sales_order_service=>ty_item_numbers(
        ( '000020' )
        ( '000030' ) ).

    DATA(ls_result) = mo_cut->clear_order_rejections_atomic(
      it_clears = VALUE #(
        ( sales_document = '0000004711'
          item_numbers   = lt_item_numbers )
        ( sales_document = '0000004712'
          item_numbers   = lt_more_item_numbers ) ) ).
    DATA(lt_submitted) = mo_api->get_last_rejections( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-order_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->get_reject_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_submitted ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '000030'
      act = lt_submitted[ 2 ]-item_number ).
  ENDMETHOD.

  METHOD rejects_bad_rejection_clears.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->clear_order_item_rejections(
          iv_sales_document = '0000004711'
          it_item_numbers   = VALUE #(
            ( '000010' )
            ( '000010' ) ) ).
      CATCH zcx_invalid_sales_order.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_reject_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_atomic_clear_error.
    mo_api->set_reject_results( it_results = VALUE #(
      ( is_successful = abap_true )
      ( messages = VALUE #( (
        type    = 'E'
        message = 'Second rejection clear failed' ) ) ) ) ).
    DATA(lt_item_numbers) = VALUE zcl_sales_order_service=>ty_item_numbers(
      ( '000010' ) ).

    DATA(ls_result) = mo_cut->clear_order_rejections_atomic(
      it_clears = VALUE #(
        ( sales_document = '0000004711'
          item_numbers   = lt_item_numbers )
        ( sales_document = '0000004712'
          item_numbers   = lt_item_numbers ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 1 ]-write_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.
ENDCLASS.
