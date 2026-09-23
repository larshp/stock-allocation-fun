CLASS lcl_res_issue_reader DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_so_reservation_reader.
    METHODS set_result
      IMPORTING
        is_result TYPE zif_so_reservation_reader=>ty_result.
    METHODS get_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
  PRIVATE SECTION.
    DATA ms_result TYPE zif_so_reservation_reader=>ty_result.
    DATA mv_read_count TYPE i.
ENDCLASS.

CLASS lcl_res_issue_reader IMPLEMENTATION.
  METHOD set_result.
    ms_result = is_result.
  ENDMETHOD.

  METHOD get_read_count.
    rv_count = mv_read_count.
  ENDMETHOD.

  METHOD zif_so_reservation_reader~read_reservation.
    ADD 1 TO mv_read_count.
    rs_result = ms_result.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_res_issue_gm_api DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_goods_movement_api.
    METHODS set_create_result
      IMPORTING
        is_result TYPE zif_goods_movement_api=>ty_result.
    METHODS set_commit_result
      IMPORTING
        is_result TYPE zif_goods_movement_api=>ty_commit_result.
    METHODS get_items
      RETURNING
        VALUE(rt_items) TYPE zif_goods_movement_api=>ty_items.
    METHODS get_gm_code
      RETURNING
        VALUE(rv_code) TYPE zif_goods_movement_api=>ty_gm_code.
    METHODS get_create_count
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
    DATA ms_create_result TYPE zif_goods_movement_api=>ty_result.
    DATA ms_commit_result TYPE zif_goods_movement_api=>ty_commit_result.
    DATA mt_items TYPE zif_goods_movement_api=>ty_items.
    DATA mv_gm_code TYPE zif_goods_movement_api=>ty_gm_code.
    DATA mv_create_count TYPE i.
    DATA mv_commit_count TYPE i.
    DATA mv_rollback_count TYPE i.
    DATA mv_test_run TYPE abap_bool.
ENDCLASS.

CLASS lcl_res_issue_gm_api IMPLEMENTATION.
  METHOD set_create_result.
    ms_create_result = is_result.
  ENDMETHOD.

  METHOD set_commit_result.
    ms_commit_result = is_result.
  ENDMETHOD.

  METHOD get_items.
    rt_items = mt_items.
  ENDMETHOD.

  METHOD get_gm_code.
    rv_code = mv_gm_code.
  ENDMETHOD.

  METHOD get_create_count.
    rv_count = mv_create_count.
  ENDMETHOD.

  METHOD get_commit_count.
    rv_count = mv_commit_count.
  ENDMETHOD.

  METHOD get_rollback_count.
    rv_count = mv_rollback_count.
  ENDMETHOD.

  METHOD was_test_run.
    rv_test_run = mv_test_run.
  ENDMETHOD.

  METHOD zif_goods_movement_api~create_movement.
    ADD 1 TO mv_create_count.
    mv_gm_code = iv_gm_code.
    mt_items = it_items.
    mv_test_run = iv_test_run.
    rs_result = ms_create_result.
  ENDMETHOD.

  METHOD zif_goods_movement_api~cancel_movement.
  ENDMETHOD.

  METHOD zif_goods_movement_api~commit.
    ADD 1 TO mv_commit_count.
    rs_result = ms_commit_result.
  ENDMETHOD.

  METHOD zif_goods_movement_api~rollback.
    ADD 1 TO mv_rollback_count.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_reservation_issue DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_reader TYPE REF TO lcl_res_issue_reader.
    DATA mo_goods_api TYPE REF TO lcl_res_issue_gm_api.
    DATA mo_cut TYPE REF TO zcl_reservation_issue_service.
    METHODS setup.
    METHODS posts_by_reservation FOR TESTING.
    METHODS simulates_without_commit FOR TESTING.
    METHODS read_error_stops_posting FOR TESTING.
    METHODS uses_unplanned_location_batch FOR TESTING.
    METHODS rejects_over_issue FOR TESTING.
    METHODS rejects_closed_item FOR TESTING.
    METHODS rejects_duplicate_item FOR TESTING.
ENDCLASS.

CLASS ltcl_reservation_issue IMPLEMENTATION.
  METHOD setup.
    mo_reader = NEW lcl_res_issue_reader( ).
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful = abap_true
        items         = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            record_type        = space
            movement_allowed   = abap_true
            material           = 'MAT-1'
            plant              = '1000'
            storage_location   = '0001'
            required_quantity  = '5.000'
            withdrawn_quantity = '2.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' ) ) ) ).

    mo_goods_api = NEW lcl_res_issue_gm_api( ).
    mo_goods_api->set_create_result(
      is_result = VALUE #(
        material_document = '4900000001'
        fiscal_year       = '2026'
        is_successful     = abap_true ) ).
    mo_goods_api->set_commit_result(
      is_result = VALUE #( is_successful = abap_true ) ).
    mo_cut = NEW zcl_reservation_issue_service(
      io_reservation_reader = mo_reader
      io_goods_movement_api = mo_goods_api ).
  ENDMETHOD.

  METHOD posts_by_reservation.
    DATA(ls_result) = mo_cut->post_goods_issue(
      is_header   = VALUE #(
        posting_date  = '20260922'
        document_date = '20260922' )
      it_requests = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          base_quantity      = '2.000' ) ) ).
    DATA(lt_items) = mo_goods_api->get_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4900000001'
      act = ls_result-material_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = '03'
      act = mo_goods_api->get_gm_code( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '9000000001'
      act = lt_items[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_items[ 1 ]-reservation_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_items[ 1 ]-entry_unit_iso ).
    cl_abap_unit_assert=>assert_initial( lt_items[ 1 ]-material ).
    cl_abap_unit_assert=>assert_initial( lt_items[ 1 ]-plant ).
    cl_abap_unit_assert=>assert_initial( lt_items[ 1 ]-movement_type ).
    cl_abap_unit_assert=>assert_initial( lt_items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD simulates_without_commit.
    DATA(ls_result) = mo_cut->post_goods_issue(
      is_header   = VALUE #(
        posting_date  = '20260922'
        document_date = '20260922' )
      it_requests = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          base_quantity      = '1.000' ) )
      iv_test_run = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = mo_goods_api->was_test_run( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD read_error_stops_posting.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful = abap_false
        messages      = VALUE #(
          ( type = 'E' message = 'Reservation not found' ) ) ) ).

    DATA(ls_result) = mo_cut->post_goods_issue(
      is_header   = VALUE #(
        posting_date  = '20260922'
        document_date = '20260922' )
      it_requests = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          base_quantity      = '1.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD uses_unplanned_location_batch.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful = abap_true
        items         = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            movement_allowed   = abap_true
            required_quantity  = '5.000'
            withdrawn_quantity = '2.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' ) ) ) ).

    DATA(ls_result) = mo_cut->post_goods_issue(
      is_header   = VALUE #(
        posting_date  = '20260922'
        document_date = '20260922' )
      it_requests = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          base_quantity      = '1.000'
          storage_location   = '0002'
          batch              = 'LOT-1' ) ) ).
    DATA(lt_items) = mo_goods_api->get_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'LOT-1'
      act = lt_items[ 1 ]-batch ).
  ENDMETHOD.

  METHOD rejects_over_issue.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->post_goods_issue(
          is_header   = VALUE #(
            posting_date  = '20260922'
            document_date = '20260922' )
          it_requests = VALUE #(
            ( reservation_number = '9000000001'
              reservation_item   = '0001'
              base_quantity      = '4.000' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_closed_item.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful = abap_true
        items         = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            movement_allowed   = abap_false
            base_unit          = 'EA'
            base_unit_iso      = 'EA'
            required_quantity  = '5.000'
            withdrawn_quantity = '2.000' ) ) ) ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->post_goods_issue(
          is_header   = VALUE #(
            posting_date  = '20260922'
            document_date = '20260922' )
          it_requests = VALUE #(
            ( reservation_number = '9000000001'
              reservation_item   = '0001'
              base_quantity      = '1.000' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_duplicate_item.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->post_goods_issue(
          is_header   = VALUE #(
            posting_date  = '20260922'
            document_date = '20260922' )
          it_requests = VALUE #(
            ( reservation_number = '9000000001'
              reservation_item   = '0001'
              base_quantity      = '1.000' )
            ( reservation_number = '9000000001'
              reservation_item   = '0001'
              base_quantity      = '1.000' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_create_count( ) ).
  ENDMETHOD.
ENDCLASS.
