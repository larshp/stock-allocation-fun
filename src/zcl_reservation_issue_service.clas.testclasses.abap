CLASS lcl_res_issue_reader DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_so_reservation_reader.
    TYPES ty_results TYPE STANDARD TABLE OF
      zif_so_reservation_reader=>ty_result WITH EMPTY KEY.
    TYPES ty_reservation_numbers TYPE STANDARD TABLE OF
      bapi2093_res_key-reserv_no WITH EMPTY KEY.
    METHODS set_result
      IMPORTING
        is_result TYPE zif_so_reservation_reader=>ty_result.
    METHODS set_results
      IMPORTING
        it_results TYPE ty_results.
    METHODS get_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_read_numbers
      RETURNING
        VALUE(rt_numbers) TYPE ty_reservation_numbers.
  PRIVATE SECTION.
    DATA ms_result TYPE zif_so_reservation_reader=>ty_result.
    DATA mt_results TYPE ty_results.
    DATA mt_read_numbers TYPE ty_reservation_numbers.
    DATA mv_read_count TYPE i.
ENDCLASS.

CLASS lcl_res_issue_reader IMPLEMENTATION.
  METHOD set_result.
    ms_result = is_result.
    CLEAR mt_results.
  ENDMETHOD.

  METHOD set_results.
    mt_results = it_results.
  ENDMETHOD.

  METHOD get_read_count.
    rv_count = mv_read_count.
  ENDMETHOD.

  METHOD get_read_numbers.
    rt_numbers = mt_read_numbers.
  ENDMETHOD.

  METHOD zif_so_reservation_reader~read_reservation.
    ADD 1 TO mv_read_count.
    APPEND iv_reservation_number TO mt_read_numbers.
    IF mt_results IS INITIAL.
      rs_result = ms_result.
    ELSE.
      READ TABLE mt_results INTO rs_result INDEX mv_read_count.
      IF sy-subrc <> 0.
        rs_result = ms_result.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_res_issue_cc_repo DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_cc_reservation_read_repo.
    METHODS set_reservations
      IMPORTING
        it_reservations TYPE zif_cc_reservation_read_repo=>ty_reservations.
    METHODS get_scope_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_open_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS fail_scope_on_call
      IMPORTING
        iv_call TYPE i.
  PRIVATE SECTION.
    DATA mt_reservations TYPE zif_cc_reservation_read_repo=>ty_reservations.
    DATA mv_scope_read_count TYPE i.
    DATA mv_open_read_count TYPE i.
    DATA mv_scope_failure_call TYPE i.
ENDCLASS.

CLASS lcl_res_issue_cc_repo IMPLEMENTATION.
  METHOD set_reservations.
    mt_reservations = it_reservations.
  ENDMETHOD.

  METHOD get_scope_read_count.
    rv_count = mv_scope_read_count.
  ENDMETHOD.

  METHOD get_open_read_count.
    rv_count = mv_open_read_count.
  ENDMETHOD.

  METHOD fail_scope_on_call.
    mv_scope_failure_call = iv_call.
  ENDMETHOD.

  METHOD zif_cc_reservation_read_repo~get_open_reservations.
    ADD 1 TO mv_open_read_count.
    LOOP AT mt_reservations INTO DATA(ls_reservation)
        WHERE cost_center = iv_cost_center.
      APPEND ls_reservation TO rt_reservations.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_cc_reservation_read_repo~get_open_reservations_bulk.
    ADD 1 TO mv_open_read_count.
    LOOP AT mt_reservations INTO DATA(ls_reservation).
      IF line_exists( it_cost_centers[
          table_line = ls_reservation-cost_center ] ).
        APPEND ls_reservation TO rt_reservations.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_cc_reservation_read_repo~get_reservation_item_scopes.
    ADD 1 TO mv_scope_read_count.
    IF mv_scope_failure_call > 0
        AND mv_scope_read_count >= mv_scope_failure_call.
      RETURN.
    ENDIF.
    LOOP AT mt_reservations INTO DATA(ls_reservation).
      IF ls_reservation-cost_center <> iv_cost_center.
        CONTINUE.
      ENDIF.
      LOOP AT it_item_keys INTO DATA(ls_item_key)
          WHERE reservation_number = ls_reservation-reservation_number
            AND reservation_item = ls_reservation-reservation_item.
        APPEND VALUE #(
          cost_center        = ls_reservation-cost_center
          reservation_number = ls_reservation-reservation_number
          reservation_item   = ls_reservation-reservation_item )
          TO rt_scopes.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_res_issue_uom_repo DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_material_uom_repository.
    METHODS set_base_unit
      IMPORTING
        iv_unit TYPE mara-meins.
    METHODS set_alt_unit_ratio
      IMPORTING
        iv_unit        TYPE marm-meinh
        iv_numerator   TYPE marm-umrez
        iv_denominator TYPE marm-umren.
  PRIVATE SECTION.
    DATA mv_base_unit TYPE mara-meins.
    DATA mv_alt_unit TYPE marm-meinh.
    DATA mv_numerator TYPE marm-umrez.
    DATA mv_denominator TYPE marm-umren.
ENDCLASS.

CLASS lcl_res_issue_uom_repo IMPLEMENTATION.
  METHOD set_base_unit.
    mv_base_unit = iv_unit.
  ENDMETHOD.

  METHOD set_alt_unit_ratio.
    mv_alt_unit = iv_unit.
    mv_numerator = iv_numerator.
    mv_denominator = iv_denominator.
  ENDMETHOD.

  METHOD zif_material_uom_repository~get_base_unit.
    rv_base_unit = mv_base_unit.
  ENDMETHOD.

  METHOD zif_material_uom_repository~get_alt_unit_ratio.
    IF iv_alternative_unit = mv_alt_unit.
      rs_ratio-numerator = mv_numerator.
      rs_ratio-denominator = mv_denominator.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_res_issue_gm_api DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_goods_movement_api.
    TYPES ty_create_results TYPE STANDARD TABLE OF
      zif_goods_movement_api=>ty_result WITH EMPTY KEY.
    TYPES ty_commit_results TYPE STANDARD TABLE OF
      zif_goods_movement_api=>ty_commit_result WITH EMPTY KEY.
    METHODS set_create_result
      IMPORTING
        is_result TYPE zif_goods_movement_api=>ty_result.
    METHODS set_create_results
      IMPORTING
        it_results TYPE ty_create_results.
    METHODS set_commit_result
      IMPORTING
        is_result TYPE zif_goods_movement_api=>ty_commit_result.
    METHODS set_commit_results
      IMPORTING
        it_results TYPE ty_commit_results.
    METHODS get_items
      RETURNING
        VALUE(rt_items) TYPE zif_goods_movement_api=>ty_items.
    METHODS get_all_items
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
    DATA mt_create_results TYPE ty_create_results.
    DATA ms_commit_result TYPE zif_goods_movement_api=>ty_commit_result.
    DATA mt_commit_results TYPE ty_commit_results.
    DATA mt_items TYPE zif_goods_movement_api=>ty_items.
    DATA mt_all_items TYPE zif_goods_movement_api=>ty_items.
    DATA mv_gm_code TYPE zif_goods_movement_api=>ty_gm_code.
    DATA mv_create_count TYPE i.
    DATA mv_commit_count TYPE i.
    DATA mv_rollback_count TYPE i.
    DATA mv_test_run TYPE abap_bool.
ENDCLASS.

CLASS lcl_res_issue_gm_api IMPLEMENTATION.
  METHOD set_create_result.
    ms_create_result = is_result.
    CLEAR mt_create_results.
  ENDMETHOD.

  METHOD set_create_results.
    mt_create_results = it_results.
  ENDMETHOD.

  METHOD set_commit_result.
    ms_commit_result = is_result.
    CLEAR mt_commit_results.
  ENDMETHOD.

  METHOD set_commit_results.
    mt_commit_results = it_results.
  ENDMETHOD.

  METHOD get_items.
    rt_items = mt_items.
  ENDMETHOD.

  METHOD get_all_items.
    rt_items = mt_all_items.
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
    APPEND LINES OF it_items TO mt_all_items.
    mv_test_run = iv_test_run.
    IF mt_create_results IS INITIAL.
      rs_result = ms_create_result.
    ELSE.
      READ TABLE mt_create_results INTO rs_result INDEX mv_create_count.
      IF sy-subrc <> 0.
        rs_result = ms_create_result.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD zif_goods_movement_api~cancel_movement.
  ENDMETHOD.

  METHOD zif_goods_movement_api~commit.
    ADD 1 TO mv_commit_count.
    IF mt_commit_results IS INITIAL.
      rs_result = ms_commit_result.
    ELSE.
      READ TABLE mt_commit_results INTO rs_result INDEX mv_commit_count.
      IF sy-subrc <> 0.
        rs_result = ms_commit_result.
      ENDIF.
    ENDIF.
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
    DATA mo_cc_reader TYPE REF TO lcl_res_issue_cc_repo.
    DATA mo_uom_repo TYPE REF TO lcl_res_issue_uom_repo.
    DATA mo_goods_api TYPE REF TO lcl_res_issue_gm_api.
    DATA mo_cut TYPE REF TO zcl_reservation_issue_service.
    METHODS setup.
    METHODS posts_by_reservation FOR TESTING.
    METHODS posts_so_reservation FOR TESTING.
    METHODS posts_so_reservation_uom FOR TESTING.
    METHODS posts_so_bulk_issue FOR TESTING.
    METHODS previews_remaining_so_issue FOR TESTING.
    METHODS rejects_missing_rem_iso FOR TESTING.
    METHODS rejects_bad_rem_issue_flag FOR TESTING.
    METHODS posts_remaining_so_issue FOR TESTING.
    METHODS posts_remaining_issue_atomic FOR TESTING.
    METHODS previews_so_issue_rem_items FOR TESTING.
    METHODS posts_so_issue_rem_item_bulk FOR TESTING.
    METHODS posts_so_issue_rem_item_atomic FOR TESTING.
    METHODS rejects_missing_so_issue FOR TESTING.
    METHODS rejects_dup_so_issue_item FOR TESTING.
    METHODS previews_remaining_so_reversal FOR TESTING.
    METHODS rejects_bad_so_rev_rem_balance FOR TESTING.
    METHODS posts_remaining_so_rev_bulk FOR TESTING.
    METHODS posts_remaining_so_rev_atomic FOR TESTING.
    METHODS rejects_so_rev_rem_scope FOR TESTING.
    METHODS previews_so_rev_rem_items FOR TESTING.
    METHODS posts_so_rev_rem_item_bulk FOR TESTING.
    METHODS posts_so_rev_rem_item_atomic FOR TESTING.
    METHODS rejects_missing_so_rev_item FOR TESTING.
    METHODS rejects_duplicate_so_rev_item FOR TESTING.
    METHODS rolls_back_remaining_scope FOR TESTING.
    METHODS rejects_wrong_scope_rem_issue FOR TESTING.
    METHODS skips_full_withdrawn_rem_issue FOR TESTING.
    METHODS posts_so_bulk_issue_uom FOR TESTING.
    METHODS posts_so_reversal FOR TESTING.
    METHODS posts_so_reversal_uom FOR TESTING.
    METHODS posts_so_bulk_reversal FOR TESTING.
    METHODS posts_so_bulk_rev_uom FOR TESTING.
    METHODS continues_so_bulk_scope FOR TESTING.
    METHODS rejects_wrong_so_reversal FOR TESTING.
    METHODS rejects_wrong_so_res_scope FOR TESTING.
    METHODS rejects_non_231_so_res FOR TESTING.
    METHODS returns_partial_quantity FOR TESTING.
    METHODS rejects_over_return FOR TESTING.
    METHODS simulates_without_commit FOR TESTING.
    METHODS read_error_stops_posting FOR TESTING.
    METHODS uses_unplanned_location_batch FOR TESTING.
    METHODS rejects_over_issue FOR TESTING.
    METHODS rejects_closed_item FOR TESTING.
    METHODS rejects_duplicate_item FOR TESTING.
    METHODS prevalidates_all_requests FOR TESTING.
    METHODS posts_multiple_reservations FOR TESTING.
    METHODS posts_issue_bulk_by_res FOR TESTING.
    METHODS continues_issue_bulk_read_fail FOR TESTING.
    METHODS continues_issue_bulk_commit FOR TESTING.
    METHODS simulates_issue_bulk FOR TESTING.
    METHODS posts_reversal_bulk FOR TESTING.
    METHODS validates_issue_bulk_first FOR TESTING.
    METHODS empty_issue_bulk FOR TESTING.
    METHODS posts_issue_in_unit FOR TESTING.
    METHODS posts_reversal_in_unit FOR TESTING.
    METHODS posts_issue_bulk_unit FOR TESTING.
    METHODS posts_reversal_bulk_unit FOR TESTING.
    METHODS rejects_unknown_issue_unit FOR TESTING.
    METHODS rejects_issue_unit_mismatch FOR TESTING.
    METHODS posts_cc_issue FOR TESTING.
    METHODS stops_cc_issue_bulk_failure FOR TESTING.
    METHODS rejects_bad_cc_bulk_stop_flags FOR TESTING.
    METHODS previews_cc_remaining_issue FOR TESTING.
    METHODS posts_cc_remaining_issue FOR TESTING.
    METHODS posts_cc_remaining_atomic FOR TESTING.
    METHODS previews_cc_remaining_items FOR TESTING.
    METHODS posts_cc_item_atomic FOR TESTING.
    METHODS posts_cc_remaining_item_bulk FOR TESTING.
    METHODS rejects_duplicate_cc_item_keys FOR TESTING.
    METHODS rejects_wrong_cc_issue FOR TESTING.
    METHODS posts_cc_issue_in_unit FOR TESTING.
    METHODS posts_cc_issue_rev FOR TESTING.
    METHODS rejects_wrong_cc_rev FOR TESTING.
    METHODS stops_cc_reversal_bulk_failure FOR TESTING.
    METHODS posts_cc_rev_bulk_unit FOR TESTING.
    METHODS posts_cc_rev_atomic FOR TESTING.
    METHODS rejects_bad_cc_rev_atomic_flag FOR TESTING.
    METHODS previews_cc_rev_remaining FOR TESTING.
    METHODS posts_cc_rev_remaining_atomic FOR TESTING.
    METHODS posts_cc_rev_remaining_bulk FOR TESTING.
    METHODS rolls_back_cc_rev_scope_change FOR TESTING.
    METHODS rejects_duplicate_cc_rev_keys FOR TESTING.
ENDCLASS.

CLASS ltcl_reservation_issue IMPLEMENTATION.
  METHOD setup.
    mo_reader = NEW lcl_res_issue_reader( ).
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful       = abap_true
        movement_type       = '231'
        sales_document      = '4711'
        sales_document_item = '000010'
        items               = VALUE #(
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

    mo_cc_reader = NEW lcl_res_issue_cc_repo( ).
    mo_cc_reader->set_reservations(
      it_reservations = VALUE #(
        ( cost_center        = 'COST-100'
          reservation_number = '9000000001'
          reservation_item   = '0001'
          material           = 'MAT-1'
          plant              = '1000'
          unit               = 'EA'
          required_quantity  = '5.000'
          withdrawn_quantity = '2.000'
          open_quantity      = '3.000' ) ) ).

    mo_uom_repo = NEW lcl_res_issue_uom_repo( ).
    mo_uom_repo->set_base_unit( iv_unit = 'EA' ).
    mo_uom_repo->set_alt_unit_ratio(
      iv_unit        = 'BOX'
      iv_numerator   = 2
      iv_denominator = 1 ).
    mo_goods_api = NEW lcl_res_issue_gm_api( ).
    mo_goods_api->set_create_result(
      is_result = VALUE #(
        material_document = '4900000001'
        fiscal_year       = '2026'
        is_successful     = abap_true ) ).
    mo_goods_api->set_commit_result(
      is_result = VALUE #( is_successful = abap_true ) ).
    mo_cut = NEW zcl_reservation_issue_service(
      io_reservation_reader    = mo_reader
      io_goods_movement_api    = mo_goods_api
      io_uom_repository        = mo_uom_repo
      io_cc_reservation_reader = mo_cc_reader ).
  ENDMETHOD.

  METHOD posts_cc_issue.
    DATA(ls_result) = mo_cut->post_cc_goods_issue(
      iv_cost_center = 'COST-100'
      is_header      = VALUE #(
        posting_date  = '20261013'
        document_date = '20261013' )
      it_requests    = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          base_quantity      = '1.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reader->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD stops_cc_issue_bulk_failure.
    mo_cc_reader->set_reservations(
      it_reservations = VALUE #(
        ( cost_center        = 'COST-100'
          reservation_number = '9000000001'
          reservation_item   = '0001'
          material           = 'MAT-1'
          plant              = '1000'
          unit               = 'EA'
          required_quantity  = '5.000'
          withdrawn_quantity = '2.000'
          open_quantity      = '3.000' )
        ( cost_center        = 'COST-100'
          reservation_number = '9000000002'
          reservation_item   = '0001'
          material           = 'MAT-2'
          plant              = '1000'
          unit               = 'EA'
          required_quantity  = '6.000'
          withdrawn_quantity = '2.000'
          open_quantity      = '4.000' )
        ( cost_center        = 'COST-100'
          reservation_number = '9000000003'
          reservation_item   = '0001'
          material           = 'MAT-3'
          plant              = '1000'
          unit               = 'EA'
          required_quantity  = '3.000'
          withdrawn_quantity = '1.000'
          open_quantity      = '2.000' ) ) ).
    mo_reader->set_results(
      it_results = VALUE #(
        ( is_successful = abap_true
          movement_type = '201'
          items         = VALUE #(
            ( reservation_number = '9000000001'
              item_number        = '0001'
              record_type        = '1'
              movement_allowed   = abap_true
              material           = 'MAT-1'
              plant              = '1000'
              required_quantity  = '5.000'
              withdrawn_quantity = '2.000'
              base_unit          = 'EA'
              base_unit_iso      = 'EA' ) ) )
        ( is_successful = abap_true
          movement_type = '201'
          items         = VALUE #(
            ( reservation_number = '9000000002'
              item_number        = '0001'
              record_type        = '1'
              movement_allowed   = abap_true
              material           = 'MAT-2'
              plant              = '1000'
              required_quantity  = '6.000'
              withdrawn_quantity = '2.000'
              base_unit          = 'EA'
              base_unit_iso      = 'EA' ) ) )
        ( is_successful = abap_true
          movement_type = '201'
          items         = VALUE #(
            ( reservation_number = '9000000003'
              item_number        = '0001'
              record_type        = '1'
              movement_allowed   = abap_true
              material           = 'MAT-3'
              plant              = '1000'
              required_quantity  = '3.000'
              withdrawn_quantity = '1.000'
              base_unit          = 'EA'
              base_unit_iso      = 'EA' ) ) ) ) ).
    mo_goods_api->set_create_results(
      it_results = VALUE #(
        ( material_document = '4900000001'
          fiscal_year       = '2026'
          is_successful     = abap_true )
        ( messages      = VALUE #(
            ( type = 'E' message = 'Second cost-center issue failed' ) )
          is_successful = abap_false )
        ( material_document = '4900000003'
          fiscal_year       = '2026'
          is_successful     = abap_true ) ) ).

    DATA(ls_result) = mo_cut->post_cc_goods_issue_bulk(
      iv_cost_center     = 'COST-100'
      is_header          = VALUE #(
        posting_date  = '20261014'
        document_date = '20261014' )
      it_requests        = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          base_quantity      = '1.000' )
        ( reservation_number = '9000000002'
          reservation_item   = '0001'
          base_quantity      = '1.000' )
        ( reservation_number = '9000000003'
          reservation_item   = '0001'
          base_quantity      = '1.000' ) )
      iv_stop_on_failure = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-stopped_on_failure ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-skipped_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-is_attempted ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 1 ]-is_skipped ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_attempted ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 2 ]-is_skipped ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 2 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '9000000003'
      act = ls_result-items[ 3 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 3 ]-is_skipped ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_goods_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_reader->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_cc_bulk_stop_flags.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->post_cc_goods_issue_bulk(
          iv_cost_center     = 'COST-100'
          is_header          = VALUE #(
            posting_date  = '20261014'
            document_date = '20261014' )
          it_requests        = VALUE #(
            ( reservation_number = '9000000001'
              reservation_item   = '0001'
              base_quantity      = '1.000' ) )
          iv_stop_on_failure = 'Y' ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        mo_cut->post_cc_goods_issue_bulk_unit(
          iv_cost_center     = 'COST-100'
          is_header          = VALUE #(
            posting_date  = '20261014'
            document_date = '20261014' )
          it_requests        = VALUE #(
            ( reservation_number = '9000000001'
              reservation_item   = '0001'
              quantity           = '1.000'
              unit               = 'NO-SUCH-UNIT' ) )
          iv_stop_on_failure = 'Y' ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        mo_cut->post_cc_issue_rev_bulk(
          iv_cost_center     = 'COST-100'
          is_header          = VALUE #(
            posting_date  = '20261014'
            document_date = '20261014' )
          it_requests        = VALUE #(
            ( reservation_number = '9000000001'
              reservation_item   = '0001'
              base_quantity      = '1.000' ) )
          iv_stop_on_failure = 'Y' ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        mo_cut->post_cc_issue_rev_bulk_unit(
          iv_cost_center     = 'COST-100'
          is_header          = VALUE #(
            posting_date  = '20261014'
            document_date = '20261014' )
          it_requests        = VALUE #(
            ( reservation_number = '9000000001'
              reservation_item   = '0001'
              quantity           = '1.000'
              unit               = 'NO-SUCH-UNIT' ) )
          iv_stop_on_failure = 'Y' ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        mo_cut->post_cc_rev_remaining_bulk(
          iv_cost_center     = 'COST-100'
          is_header          = VALUE #(
            posting_date  = '20261014'
            document_date = '20261014' )
          it_item_keys       = VALUE #(
            ( reservation_number = '9000000001'
              reservation_item   = '0001' ) )
          iv_stop_on_failure = 'Y' ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        mo_cut->post_cc_issue_remaining(
          iv_cost_center         = 'COST-100'
          is_header              = VALUE #(
            posting_date  = '20261014'
            document_date = '20261014' )
          it_reservation_numbers = VALUE #( ( '9000000001' ) )
          iv_stop_on_failure     = 'Y' ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    CLEAR lv_rejected.
    TRY.
        mo_cut->post_cc_remaining_items(
          iv_cost_center     = 'COST-100'
          is_header          = VALUE #(
            posting_date  = '20261014'
            document_date = '20261014' )
          it_item_keys       = VALUE #(
            ( reservation_number = '9000000001'
              reservation_item   = '0001' ) )
          iv_stop_on_failure = 'Y' ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_cc_reader->get_open_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_cc_reader->get_scope_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reader->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD previews_cc_remaining_issue.
    mo_cc_reader->set_reservations(
      it_reservations = VALUE #(
        ( cost_center        = 'COST-100'
          reservation_number = '9000000001'
          reservation_item   = '0001'
          material           = 'MAT-1'
          plant              = '1000'
          unit               = 'EA'
          required_quantity  = '5.000'
          withdrawn_quantity = '2.000'
          open_quantity      = '3.000' )
        ( cost_center        = 'COST-100'
          reservation_number = '9000000002'
          reservation_item   = '0001'
          material           = 'MAT-2'
          plant              = '1000'
          unit               = 'EA'
          required_quantity  = '4.000'
          withdrawn_quantity = '1.000'
          open_quantity      = '3.000' ) ) ).
    DATA(lt_preview) = mo_cut->preview_cc_issue_remaining(
      iv_cost_center         = 'COST-100'
      it_reservation_numbers = VALUE #(
        ( '9000000001' ) ) ).
    DATA(lt_all_preview) = mo_cut->preview_cc_issue_remaining(
      iv_cost_center = 'COST-100' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_preview ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '9000000001'
      act = lt_preview[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_preview[ 1 ]-reservation_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_preview[ 1 ]-open_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_preview[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_all_preview ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '9000000002'
      act = lt_all_preview[ 2 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD posts_cc_remaining_issue.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful = abap_true
        movement_type = '201'
        items         = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            movement_allowed   = abap_true
            material           = 'MAT-1'
            plant              = '1000'
            storage_location   = '0001'
            required_quantity  = '5.000'
            withdrawn_quantity = '2.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' ) ) ) ).

    DATA(ls_result) = mo_cut->post_cc_issue_remaining(
      iv_cost_center         = 'COST-100'
      is_header              = VALUE #(
        posting_date  = '20261014'
        document_date = '20261014' )
      it_reservation_numbers = VALUE #(
        ( '9000000001' ) ) ).
    DATA(lt_items) = mo_goods_api->get_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD posts_cc_remaining_atomic.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful = abap_true
        movement_type = '201'
        items         = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            movement_allowed   = abap_true
            material           = 'MAT-1'
            plant              = '1000'
            storage_location   = '0001'
            required_quantity  = '5.000'
            withdrawn_quantity = '2.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' ) ) ) ).

    DATA(ls_result) = mo_cut->post_cc_issue_remaining_atomic(
      iv_cost_center         = 'COST-100'
      is_header              = VALUE #(
        posting_date  = '20261014'
        document_date = '20261014' )
      it_reservation_numbers = VALUE #(
        ( '9000000001' ) ) ).
    DATA(lt_items) = mo_goods_api->get_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD previews_cc_remaining_items.
    mo_cc_reader->set_reservations(
      it_reservations = VALUE #(
        ( cost_center        = 'COST-100'
          reservation_number = '9000000001'
          reservation_item   = '0001'
          material           = 'MAT-1'
          plant              = '1000'
          unit               = 'EA'
          required_quantity  = '5.000'
          withdrawn_quantity = '2.000'
          open_quantity      = '3.000' )
        ( cost_center        = 'COST-100'
          reservation_number = '9000000001'
          reservation_item   = '0002'
          material           = 'MAT-2'
          plant              = '1000'
          unit               = 'EA'
          required_quantity  = '6.000'
          withdrawn_quantity = '2.000'
          open_quantity      = '4.000' ) ) ).

    DATA(lt_reservations) = mo_cut->preview_cc_remaining_items(
      iv_cost_center = 'COST-100'
      it_item_keys   = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0002' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_reservations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_reservations[ 1 ]-reservation_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '4.000' )
      act = lt_reservations[ 1 ]-open_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_cc_reader->get_open_read_count( ) ).
  ENDMETHOD.

  METHOD posts_cc_item_atomic.
    mo_cc_reader->set_reservations(
      it_reservations = VALUE #(
        ( cost_center        = 'COST-100'
          reservation_number = '9000000001'
          reservation_item   = '0001'
          material           = 'MAT-1'
          plant              = '1000'
          unit               = 'EA'
          required_quantity  = '5.000'
          withdrawn_quantity = '2.000'
          open_quantity      = '3.000' )
        ( cost_center        = 'COST-100'
          reservation_number = '9000000001'
          reservation_item   = '0002'
          material           = 'MAT-2'
          plant              = '1000'
          unit               = 'EA'
          required_quantity  = '6.000'
          withdrawn_quantity = '2.000'
          open_quantity      = '4.000' ) ) ).
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful = abap_true
        movement_type = '201'
        items         = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            record_type        = '1'
            movement_allowed   = abap_true
            material           = 'MAT-1'
            required_quantity  = '5.000'
            withdrawn_quantity = '2.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' )
          ( reservation_number = '9000000001'
            item_number        = '0002'
            record_type        = '1'
            movement_allowed   = abap_true
            material           = 'MAT-2'
            required_quantity  = '6.000'
            withdrawn_quantity = '2.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' ) ) ) ).

    DATA(ls_result) = mo_cut->post_cc_remaining_items_atomic(
      iv_cost_center = 'COST-100'
      is_header      = VALUE #(
        posting_date  = '20261014'
        document_date = '20261014' )
      it_item_keys   = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0002' ) ) ).
    DATA(lt_items) = mo_goods_api->get_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_items[ 1 ]-reservation_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_cc_reader->get_open_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD posts_cc_remaining_item_bulk.
    mo_cc_reader->set_reservations(
      it_reservations = VALUE #(
        ( cost_center        = 'COST-100'
          reservation_number = '9000000001'
          reservation_item   = '0001'
          material           = 'MAT-1'
          plant              = '1000'
          unit               = 'EA'
          required_quantity  = '5.000'
          withdrawn_quantity = '2.000'
          open_quantity      = '3.000' )
        ( cost_center        = 'COST-100'
          reservation_number = '9000000001'
          reservation_item   = '0002'
          material           = 'MAT-2'
          plant              = '1000'
          unit               = 'EA'
          required_quantity  = '6.000'
          withdrawn_quantity = '2.000'
          open_quantity      = '4.000' ) ) ).
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful = abap_true
        movement_type = '201'
        items         = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            record_type        = '1'
            movement_allowed   = abap_true
            material           = 'MAT-1'
            required_quantity  = '5.000'
            withdrawn_quantity = '2.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' )
          ( reservation_number = '9000000001'
            item_number        = '0002'
            record_type        = '1'
            movement_allowed   = abap_true
            material           = 'MAT-2'
            required_quantity  = '6.000'
            withdrawn_quantity = '2.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' ) ) ) ).

    DATA(ls_result) = mo_cut->post_cc_remaining_items(
      iv_cost_center = 'COST-100'
      is_header      = VALUE #(
        posting_date  = '20261014'
        document_date = '20261014' )
      it_item_keys   = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0002' ) ) ).
    DATA(lt_items) = mo_goods_api->get_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_items[ 1 ]-reservation_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_duplicate_cc_item_keys.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->preview_cc_remaining_items(
          iv_cost_center = 'COST-100'
          it_item_keys   = VALUE #(
            ( reservation_number = '9000000001'
              reservation_item   = '0001' )
            ( reservation_number = '9000000001'
              reservation_item   = '0001' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_cc_reader->get_open_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_wrong_cc_issue.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->post_cc_goods_issue(
          iv_cost_center = 'COST-200'
          is_header      = VALUE #(
            posting_date  = '20261013'
            document_date = '20261013' )
          it_requests    = VALUE #(
            ( reservation_number = '9000000001'
              reservation_item   = '0001'
              base_quantity      = '1.000' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reader->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD posts_cc_issue_in_unit.
    DATA(ls_result) = mo_cut->post_cc_goods_issue_bulk_unit(
      iv_cost_center = 'COST-100'
      is_header      = VALUE #(
        posting_date  = '20261013'
        document_date = '20261013' )
      it_requests    = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          quantity           = '1.000'
          unit               = 'BOX' ) ) ).
    DATA(lt_items) = mo_goods_api->get_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_commit_count( ) ).
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
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD posts_so_reservation.
    DATA(ls_result) = mo_cut->post_sales_order_issue(
      iv_sales_document = '4711'
      iv_item_number    = '000010'
      is_header         = VALUE #(
        posting_date  = '20260922'
        document_date = '20260922' )
      it_requests       = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          base_quantity      = '2.000' ) ) ).
    DATA(lt_items) = mo_goods_api->get_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reader->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '9000000001'
      act = lt_items[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD posts_so_reservation_uom.
    DATA(ls_result) = mo_cut->post_sales_order_issue_uom(
      iv_sales_document = '4711'
      iv_item_number    = '000010'
      is_header         = VALUE #(
        posting_date  = '20260922'
        document_date = '20260922' )
      it_requests       = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          quantity           = '1.000'
          unit               = 'BOX' ) ) ).
    DATA(lt_items) = mo_goods_api->get_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reader->get_read_count( ) ).
  ENDMETHOD.

  METHOD posts_so_bulk_issue.
    DATA(ls_result) = mo_cut->post_so_issue_bulk(
      iv_sales_document = '4711'
      iv_item_number    = '000010'
      is_header         = VALUE #(
        posting_date  = '20260922'
        document_date = '20260922' )
      it_requests       = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          base_quantity      = '1.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD previews_remaining_so_issue.
    DATA(lt_preview) = mo_cut->preview_so_issue_remaining(
      iv_sales_document      = '4711'
      iv_item_number         = '000010'
      it_reservation_numbers = VALUE #(
        ( '9000000001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_preview ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '9000000001'
      act = lt_preview[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_preview[ 1 ]-reservation_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_preview[ 1 ]-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_preview[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_preview[ 1 ]-base_unit_iso ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_preview[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reader->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_missing_rem_iso.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful       = abap_true
        movement_type       = '231'
        sales_document      = '4711'
        sales_document_item = '000010'
        items               = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            movement_allowed   = abap_true
            required_quantity  = '5.000'
            withdrawn_quantity = '2.000'
            base_unit          = 'EA' ) ) ) ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->preview_so_issue_remaining(
          iv_sales_document      = '4711'
          iv_item_number         = '000010'
          it_reservation_numbers = VALUE #(
            ( '9000000001' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reader->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_rem_issue_flag.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->post_so_issue_remaining(
          iv_sales_document      = '4711'
          iv_item_number         = '000010'
          is_header              = VALUE #(
            posting_date  = '20261014'
            document_date = '20261014' )
          it_reservation_numbers = VALUE #(
            ( '9000000001' ) )
          iv_test_run            = 'Y' ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reader->get_read_count( ) ).
  ENDMETHOD.

  METHOD posts_remaining_so_issue.
    DATA(ls_result) = mo_cut->post_so_issue_remaining(
      iv_sales_document      = '4711'
      iv_item_number         = '000010'
      is_header              = VALUE #(
        posting_date  = '20261014'
        document_date = '20261014' )
      it_reservation_numbers = VALUE #(
        ( '9000000001' ) ) ).
    DATA(lt_items) = mo_goods_api->get_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_reader->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD posts_remaining_issue_atomic.
    DATA(ls_first_read) = VALUE zif_so_reservation_reader=>ty_result(
      is_successful       = abap_true
      movement_type       = '231'
      sales_document      = '4711'
      sales_document_item = '000010'
      items               = VALUE #(
        ( reservation_number = '9000000001'
          item_number        = '0001'
          movement_allowed   = abap_true
          material           = 'MAT-1'
          required_quantity  = '5.000'
          withdrawn_quantity = '2.000'
          base_unit          = 'EA'
          base_unit_iso      = 'EA' ) ) ).
    DATA(ls_second_read) = ls_first_read.
    ls_second_read-items[ 1 ]-reservation_number = '9000000002'.
    mo_reader->set_results(
      it_results = VALUE #(
        ( ls_first_read )
        ( ls_second_read )
        ( ls_first_read )
        ( ls_second_read ) ) ).

    DATA(ls_result) = mo_cut->post_so_issue_remaining_atomic(
      iv_sales_document      = '4711'
      iv_item_number         = '000010'
      is_header              = VALUE #(
        posting_date  = '20261014'
        document_date = '20261014' )
      it_reservation_numbers = VALUE #(
        ( '9000000001' )
        ( '9000000002' ) ) ).
    DATA(lt_items) = mo_goods_api->get_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_goods_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = mo_reader->get_read_count( ) ).
  ENDMETHOD.

  METHOD previews_so_issue_rem_items.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful       = abap_true
        movement_type       = '231'
        sales_document      = '4711'
        sales_document_item = '000010'
        items               = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            movement_allowed   = abap_true
            required_quantity  = '5.000'
            withdrawn_quantity = '2.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' )
          ( reservation_number = '9000000001'
            item_number        = '0002'
            movement_allowed   = abap_true
            required_quantity  = '6.000'
            withdrawn_quantity = '3.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' ) ) ) ).

    DATA(lt_preview) = mo_cut->preview_so_issue_rem_items(
      iv_sales_document = '4711'
      iv_item_number    = '000010'
      it_item_keys      = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0002' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_preview ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_preview[ 1 ]-reservation_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_preview[ 1 ]-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reader->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD posts_so_issue_rem_item_bulk.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful       = abap_true
        movement_type       = '231'
        sales_document      = '4711'
        sales_document_item = '000010'
        items               = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            material           = 'MAT-1'
            movement_allowed   = abap_true
            required_quantity  = '5.000'
            withdrawn_quantity = '2.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' )
          ( reservation_number = '9000000001'
            item_number        = '0002'
            material           = 'MAT-1'
            movement_allowed   = abap_true
            required_quantity  = '6.000'
            withdrawn_quantity = '3.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' ) ) ) ).

    DATA(ls_result) = mo_cut->post_so_issue_rem_items_bulk(
      iv_sales_document = '4711'
      iv_item_number    = '000010'
      is_header         = VALUE #(
        posting_date  = '20261014'
        document_date = '20261014' )
      it_item_keys      = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0002' ) ) ).
    DATA(lt_items) = mo_goods_api->get_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_items[ 1 ]-reservation_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '03'
      act = mo_goods_api->get_gm_code( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD posts_so_issue_rem_item_atomic.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful       = abap_true
        movement_type       = '231'
        sales_document      = '4711'
        sales_document_item = '000010'
        items               = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            material           = 'MAT-1'
            movement_allowed   = abap_true
            required_quantity  = '5.000'
            withdrawn_quantity = '2.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' )
          ( reservation_number = '9000000001'
            item_number        = '0002'
            material           = 'MAT-1'
            movement_allowed   = abap_true
            required_quantity  = '6.000'
            withdrawn_quantity = '3.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' ) ) ) ).

    DATA(ls_result) = mo_cut->post_so_issue_rem_items_atomic(
      iv_sales_document = '4711'
      iv_item_number    = '000010'
      is_header         = VALUE #(
        posting_date  = '20261014'
        document_date = '20261014' )
      it_item_keys      = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0002' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_missing_so_issue.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->preview_so_issue_rem_items(
          iv_sales_document = '4711'
          iv_item_number    = '000010'
          it_item_keys      = VALUE #(
            ( reservation_number = '9000000001'
              reservation_item   = '0002' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reader->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_dup_so_issue_item.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->preview_so_issue_rem_items(
          iv_sales_document = '4711'
          iv_item_number    = '000010'
          it_item_keys      = VALUE #(
            ( reservation_number = '9000000001'
              reservation_item   = '0001' )
            ( reservation_number = '9000000001'
              reservation_item   = '0001' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reader->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD previews_remaining_so_reversal.
    DATA(lt_preview) = mo_cut->preview_so_rev_remaining(
      iv_sales_document      = '4711'
      iv_item_number         = '000010'
      it_reservation_numbers = VALUE #(
        ( '9000000001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_preview ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '9000000001'
      act = lt_preview[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_preview[ 1 ]-reservation_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_preview[ 1 ]-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_preview[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_preview[ 1 ]-base_unit_iso ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reader->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_so_rev_rem_balance.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful       = abap_true
        movement_type       = '231'
        sales_document      = '4711'
        sales_document_item = '000010'
        items               = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            material           = 'MAT-1'
            required_quantity  = '5.000'
            withdrawn_quantity = '-1.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' ) ) ) ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->preview_so_rev_remaining(
          iv_sales_document      = '4711'
          iv_item_number         = '000010'
          it_reservation_numbers = VALUE #(
            ( '9000000001' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD posts_remaining_so_rev_bulk.
    DATA(ls_first_read) = VALUE zif_so_reservation_reader=>ty_result(
      is_successful       = abap_true
      movement_type       = '231'
      sales_document      = '4711'
      sales_document_item = '000010'
      items               = VALUE #(
        ( reservation_number = '9000000001'
          item_number        = '0001'
          material           = 'MAT-1'
          required_quantity  = '5.000'
          withdrawn_quantity = '2.000'
          base_unit          = 'EA'
          base_unit_iso      = 'EA' ) ) ).
    DATA(ls_second_read) = ls_first_read.
    ls_second_read-items[ 1 ]-reservation_number = '9000000002'.
    ls_second_read-items[ 1 ]-material = 'MAT-2'.
    ls_second_read-items[ 1 ]-required_quantity = '6.000'.
    ls_second_read-items[ 1 ]-withdrawn_quantity = '3.000'.
    mo_reader->set_results(
      it_results = VALUE #(
        ( ls_first_read )
        ( ls_second_read )
        ( ls_first_read )
        ( ls_second_read ) ) ).

    DATA(ls_result) = mo_cut->post_so_rev_remaining_bulk(
      iv_sales_document      = '4711'
      iv_item_number         = '000010'
      is_header              = VALUE #(
        posting_date  = '20261014'
        document_date = '20261014' )
      it_reservation_numbers = VALUE #(
        ( '9000000001' )
        ( '9000000002' ) ) ).
    DATA(lt_items) = mo_goods_api->get_all_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_items[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '06'
      act = mo_goods_api->get_gm_code( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_goods_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_goods_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD posts_remaining_so_rev_atomic.
    DATA(ls_first_read) = VALUE zif_so_reservation_reader=>ty_result(
      is_successful       = abap_true
      movement_type       = '231'
      sales_document      = '4711'
      sales_document_item = '000010'
      items               = VALUE #(
        ( reservation_number = '9000000001'
          item_number        = '0001'
          material           = 'MAT-1'
          required_quantity  = '5.000'
          withdrawn_quantity = '2.000'
          base_unit          = 'EA'
          base_unit_iso      = 'EA' ) ) ).
    DATA(ls_second_read) = ls_first_read.
    ls_second_read-items[ 1 ]-reservation_number = '9000000002'.
    ls_second_read-items[ 1 ]-material = 'MAT-2'.
    ls_second_read-items[ 1 ]-required_quantity = '6.000'.
    ls_second_read-items[ 1 ]-withdrawn_quantity = '3.000'.
    mo_reader->set_results(
      it_results = VALUE #(
        ( ls_first_read )
        ( ls_second_read )
        ( ls_first_read )
        ( ls_second_read ) ) ).

    DATA(ls_result) = mo_cut->post_so_rev_remaining_atomic(
      iv_sales_document      = '4711'
      iv_item_number         = '000010'
      is_header              = VALUE #(
        posting_date  = '20261014'
        document_date = '20261014' )
      it_reservation_numbers = VALUE #(
        ( '9000000001' )
        ( '9000000002' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_goods_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = mo_reader->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_so_rev_rem_scope.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->post_so_rev_remaining_bulk(
          iv_sales_document      = '9999'
          iv_item_number         = '000010'
          is_header              = VALUE #(
            posting_date  = '20261014'
            document_date = '20261014' )
          it_reservation_numbers = VALUE #(
            ( '9000000001' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reader->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD previews_so_rev_rem_items.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful       = abap_true
        movement_type       = '231'
        sales_document      = '4711'
        sales_document_item = '000010'
        items               = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            required_quantity  = '5.000'
            withdrawn_quantity = '2.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' )
          ( reservation_number = '9000000001'
            item_number        = '0002'
            required_quantity  = '6.000'
            withdrawn_quantity = '3.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' ) ) ) ).

    DATA(lt_preview) = mo_cut->preview_so_rev_remaining_items(
      iv_sales_document = '4711'
      iv_item_number    = '000010'
      it_item_keys      = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0002' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_preview ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_preview[ 1 ]-reservation_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_preview[ 1 ]-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reader->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD posts_so_rev_rem_item_bulk.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful       = abap_true
        movement_type       = '231'
        sales_document      = '4711'
        sales_document_item = '000010'
        items               = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            material           = 'MAT-1'
            required_quantity  = '5.000'
            withdrawn_quantity = '2.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' )
          ( reservation_number = '9000000001'
            item_number        = '0002'
            material           = 'MAT-1'
            required_quantity  = '6.000'
            withdrawn_quantity = '3.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' ) ) ) ).

    DATA(ls_result) = mo_cut->post_so_rev_rem_items_bulk(
      iv_sales_document = '4711'
      iv_item_number    = '000010'
      is_header         = VALUE #(
        posting_date  = '20261014'
        document_date = '20261014' )
      it_item_keys      = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0002' ) ) ).
    DATA(lt_items) = mo_goods_api->get_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_items[ 1 ]-reservation_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD posts_so_rev_rem_item_atomic.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful       = abap_true
        movement_type       = '231'
        sales_document      = '4711'
        sales_document_item = '000010'
        items               = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            material           = 'MAT-1'
            required_quantity  = '5.000'
            withdrawn_quantity = '2.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' )
          ( reservation_number = '9000000001'
            item_number        = '0002'
            material           = 'MAT-1'
            required_quantity  = '6.000'
            withdrawn_quantity = '3.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' ) ) ) ).

    DATA(ls_result) = mo_cut->post_so_rev_rem_items_atomic(
      iv_sales_document = '4711'
      iv_item_number    = '000010'
      is_header         = VALUE #(
        posting_date  = '20261014'
        document_date = '20261014' )
      it_item_keys      = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0002' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_missing_so_rev_item.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->preview_so_rev_remaining_items(
          iv_sales_document = '4711'
          iv_item_number    = '000010'
          it_item_keys      = VALUE #(
            ( reservation_number = '9000000001'
              reservation_item   = '0002' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reader->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_duplicate_so_rev_item.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->preview_so_rev_remaining_items(
          iv_sales_document = '4711'
          iv_item_number    = '000010'
          it_item_keys      = VALUE #(
            ( reservation_number = '9000000001'
              reservation_item   = '0001' )
            ( reservation_number = '9000000001'
              reservation_item   = '0001' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reader->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_remaining_scope.
    DATA(ls_valid_read) = VALUE zif_so_reservation_reader=>ty_result(
      is_successful       = abap_true
      movement_type       = '231'
      sales_document      = '4711'
      sales_document_item = '000010'
      items               = VALUE #(
        ( reservation_number = '9000000001'
          item_number        = '0001'
          movement_allowed   = abap_true
          material           = 'MAT-1'
          required_quantity  = '5.000'
          withdrawn_quantity = '2.000'
          base_unit          = 'EA'
          base_unit_iso      = 'EA' ) ) ).
    DATA(ls_wrong_read) = ls_valid_read.
    ls_wrong_read-sales_document = '9999'.
    mo_reader->set_results(
      it_results = VALUE #(
        ( ls_valid_read )
        ( ls_wrong_read ) ) ).

    DATA(ls_result) = mo_cut->post_so_issue_remaining_atomic(
      iv_sales_document      = '4711'
      iv_item_number         = '000010'
      is_header              = VALUE #(
        posting_date  = '20261014'
        document_date = '20261014' )
      it_reservation_numbers = VALUE #(
        ( '9000000001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rejects_wrong_scope_rem_issue.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->post_so_issue_remaining(
          iv_sales_document      = '9999'
          iv_item_number         = '000010'
          is_header              = VALUE #(
            posting_date  = '20261014'
            document_date = '20261014' )
          it_reservation_numbers = VALUE #(
            ( '9000000001' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reader->get_read_count( ) ).
  ENDMETHOD.

  METHOD skips_full_withdrawn_rem_issue.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful       = abap_true
        movement_type       = '231'
        sales_document      = '4711'
        sales_document_item = '000010'
        items               = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            movement_allowed   = abap_true
            required_quantity  = '5.000'
            withdrawn_quantity = '5.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' ) ) ) ).

    DATA(ls_result) = mo_cut->post_so_issue_remaining(
      iv_sales_document      = '4711'
      iv_item_number         = '000010'
      is_header              = VALUE #(
        posting_date  = '20261014'
        document_date = '20261014' )
      it_reservation_numbers = VALUE #(
        ( '9000000001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reader->get_read_count( ) ).
  ENDMETHOD.

  METHOD posts_so_bulk_issue_uom.
    DATA(ls_result) = mo_cut->post_so_issue_bulk_uom(
      iv_sales_document = '4711'
      iv_item_number    = '000010'
      is_header         = VALUE #(
        posting_date  = '20260922'
        document_date = '20260922' )
      it_requests       = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          quantity           = '1.000'
          unit               = 'BOX' ) ) ).
    DATA(lt_items) = mo_goods_api->get_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_items[ 1 ]-quantity ).
  ENDMETHOD.

  METHOD posts_so_reversal.
    DATA(ls_result) = mo_cut->post_sales_order_reversal(
      iv_sales_document = '4711'
      iv_item_number    = '000010'
      is_header         = VALUE #(
        posting_date  = '20260922'
        document_date = '20260922' )
      it_requests       = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          base_quantity      = '1.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '06'
      act = mo_goods_api->get_gm_code( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD posts_so_reversal_uom.
    DATA(ls_result) = mo_cut->post_sales_order_reversal_uom(
      iv_sales_document = '4711'
      iv_item_number    = '000010'
      is_header         = VALUE #(
        posting_date  = '20260922'
        document_date = '20260922' )
      it_requests       = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          quantity           = '1.000'
          unit               = 'BOX' ) ) ).
    DATA(lt_items) = mo_goods_api->get_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '06'
      act = mo_goods_api->get_gm_code( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_items[ 1 ]-quantity ).
  ENDMETHOD.

  METHOD posts_so_bulk_reversal.
    DATA(ls_result) = mo_cut->post_so_reversal_bulk(
      iv_sales_document = '4711'
      iv_item_number    = '000010'
      is_header         = VALUE #(
        posting_date  = '20260923'
        document_date = '20260923' )
      it_requests       = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          base_quantity      = '1.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '06'
      act = mo_goods_api->get_gm_code( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-successful_count ).
  ENDMETHOD.

  METHOD posts_so_bulk_rev_uom.
    DATA(ls_result) = mo_cut->post_so_reversal_bulk_uom(
      iv_sales_document = '4711'
      iv_item_number    = '000010'
      is_header         = VALUE #(
        posting_date  = '20260923'
        document_date = '20260923' )
      it_requests       = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          quantity           = '1.000'
          unit               = 'BOX' ) ) ).
    DATA(lt_items) = mo_goods_api->get_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '06'
      act = mo_goods_api->get_gm_code( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_items[ 1 ]-quantity ).
  ENDMETHOD.

  METHOD continues_so_bulk_scope.
    mo_reader->set_results(
      it_results = VALUE #(
        ( is_successful       = abap_true
          movement_type       = '231'
          sales_document      = '4712'
          sales_document_item = '000010'
          items               = VALUE #(
            ( reservation_number = '9000000002'
              item_number        = '0002'
              movement_allowed   = abap_true
              material           = 'MAT-2'
              plant              = '2000'
              storage_location   = '0002'
              required_quantity  = '5.000'
              base_unit          = 'EA'
              base_unit_iso      = 'EA' ) ) )
        ( is_successful       = abap_true
          movement_type       = '231'
          sales_document      = '4711'
          sales_document_item = '000010'
          items               = VALUE #(
            ( reservation_number = '9000000001'
              item_number        = '0001'
              movement_allowed   = abap_true
              material           = 'MAT-1'
              plant              = '1000'
              storage_location   = '0001'
              required_quantity  = '5.000'
              base_unit          = 'EA'
              base_unit_iso      = 'EA' ) ) ) ) ).

    DATA(ls_result) = mo_cut->post_so_issue_bulk(
      iv_sales_document = '4711'
      iv_item_number    = '000010'
      is_header         = VALUE #(
        posting_date  = '20260922'
        document_date = '20260922' )
      it_requests       = VALUE #(
        ( reservation_number = '9000000002'
          reservation_item   = '0002'
          base_quantity      = '1.000' )
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          base_quantity      = '1.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_wrong_so_reversal.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful       = abap_true
        movement_type       = '231'
        sales_document      = '4712'
        sales_document_item = '000010'
        items               = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            movement_allowed   = abap_true
            material           = 'MAT-1'
            plant              = '1000'
            storage_location   = '0001'
            required_quantity  = '5.000'
            withdrawn_quantity = '2.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' ) ) ) ).

    DATA(ls_result) = mo_cut->post_sales_order_reversal(
      iv_sales_document = '4711'
      iv_item_number    = '000010'
      is_header         = VALUE #(
        posting_date  = '20260922'
        document_date = '20260922' )
      it_requests       = VALUE #(
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

  METHOD rejects_wrong_so_res_scope.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful       = abap_true
        movement_type       = '231'
        sales_document      = '4712'
        sales_document_item = '000010'
        items               = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            movement_allowed   = abap_true
            material           = 'MAT-1'
            plant              = '1000'
            storage_location   = '0001'
            required_quantity  = '5.000'
            withdrawn_quantity = '2.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' ) ) ) ).

    DATA(ls_result) = mo_cut->post_sales_order_issue(
      iv_sales_document = '4711'
      iv_item_number    = '000010'
      is_header         = VALUE #(
        posting_date  = '20260922'
        document_date = '20260922' )
      it_requests       = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          base_quantity      = '1.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'E'
      act = ls_result-messages[ 1 ]-type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_non_231_so_res.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful       = abap_true
        movement_type       = '201'
        sales_document      = '4711'
        sales_document_item = '000010'
        items               = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            movement_allowed   = abap_true
            material           = 'MAT-1'
            plant              = '1000'
            storage_location   = '0001'
            required_quantity  = '5.000'
            withdrawn_quantity = '2.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' ) ) ) ).

    DATA(ls_result) = mo_cut->post_sales_order_issue(
      iv_sales_document = '4711'
      iv_item_number    = '000010'
      is_header         = VALUE #(
        posting_date  = '20260922'
        document_date = '20260922' )
      it_requests       = VALUE #(
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

  METHOD returns_partial_quantity.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful = abap_true
        items         = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            is_final_issue     = abap_true
            movement_allowed   = abap_false
            required_quantity  = '5.000'
            withdrawn_quantity = '2.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' ) ) ) ).

    DATA(ls_result) = mo_cut->post_goods_issue_reversal(
      is_header   = VALUE #(
        posting_date  = '20260923'
        document_date = '20260923' )
      it_requests = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          base_quantity      = '1.250'
          storage_location   = '0002' ) ) ).
    DATA(lt_items) = mo_goods_api->get_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '06'
      act = mo_goods_api->get_gm_code( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_items[ 1 ]-is_reversal ).
    cl_abap_unit_assert=>assert_initial(
      lt_items[ 1 ]-movement_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.250' )
      act = lt_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_over_return.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->post_goods_issue_reversal(
          is_header   = VALUE #(
            posting_date  = '20260923'
            document_date = '20260923' )
          it_requests = VALUE #(
            ( reservation_number = '9000000001'
              reservation_item   = '0001'
              base_quantity      = '2.001' ) ) ).
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
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reader->get_read_count( ) ).
  ENDMETHOD.

  METHOD prevalidates_all_requests.
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
              reservation_item   = '0002'
              base_quantity      = '0.000' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reader->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD posts_multiple_reservations.
    mo_reader->set_results(
      it_results = VALUE #(
        ( is_successful = abap_true
          items         = VALUE #(
            ( reservation_number = '9000000002'
              item_number        = '0002'
              movement_allowed   = abap_true
              material           = 'MAT-2'
              plant              = '2000'
              storage_location   = '0002'
              required_quantity  = '4.000'
              base_unit          = 'EA'
              base_unit_iso      = 'EA' ) ) )
        ( is_successful = abap_true
          items         = VALUE #(
            ( reservation_number = '9000000001'
              item_number        = '0001'
              movement_allowed   = abap_true
              material           = 'MAT-1'
              plant              = '1000'
              storage_location   = '0001'
              required_quantity  = '5.000'
              base_unit          = 'EA'
              base_unit_iso      = 'EA' ) ) ) ) ).

    DATA(ls_result) = mo_cut->post_goods_issue(
      is_header   = VALUE #(
        posting_date  = '20260922'
        document_date = '20260922' )
      it_requests = VALUE #(
        ( reservation_number = '9000000002'
          reservation_item   = '0002'
          base_quantity      = '1.000' )
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          base_quantity      = '2.000' ) ) ).
    DATA(lt_items) = mo_goods_api->get_items( ).
    DATA(lt_read_numbers) = mo_reader->get_read_numbers( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '9000000002'
      act = lt_items[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_items[ 1 ]-reservation_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = '9000000001'
      act = lt_items[ 2 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_items[ 2 ]-reservation_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = VALUE lcl_res_issue_reader=>ty_reservation_numbers(
        ( '9000000002' )
        ( '9000000001' ) )
      act = lt_read_numbers ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_reader->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD posts_issue_bulk_by_res.
    mo_reader->set_results(
      it_results = VALUE #(
        ( is_successful = abap_true
          items         = VALUE #(
            ( reservation_number = '9000000002'
              item_number        = '0002'
              movement_allowed   = abap_true
              required_quantity  = '4.000'
              base_unit          = 'EA'
              base_unit_iso      = 'EA' )
            ( reservation_number = '9000000002'
              item_number        = '0003'
              movement_allowed   = abap_true
              required_quantity  = '3.000'
              base_unit          = 'EA'
              base_unit_iso      = 'EA' ) ) )
        ( is_successful = abap_true
          items         = VALUE #(
            ( reservation_number = '9000000001'
              item_number        = '0001'
              movement_allowed   = abap_true
              required_quantity  = '5.000'
              base_unit          = 'EA'
              base_unit_iso      = 'EA' ) ) ) ) ).

    DATA(ls_result) = mo_cut->post_goods_issue_bulk(
      is_header   = VALUE #(
        posting_date  = '20260922'
        document_date = '20260922' )
      it_requests = VALUE #(
        ( reservation_number = '9000000002'
          reservation_item   = '0002'
          base_quantity      = '1.000' )
        ( reservation_number = '9000000002'
          reservation_item   = '0003'
          base_quantity      = '1.500' )
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          base_quantity      = '2.000' ) ) ).
    DATA(lt_read_numbers) = mo_reader->get_read_numbers( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '9000000002'
      act = ls_result-items[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '9000000001'
      act = ls_result-items[ 2 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = VALUE lcl_res_issue_reader=>ty_reservation_numbers(
        ( '9000000002' )
        ( '9000000001' ) )
      act = lt_read_numbers ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_goods_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_goods_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD continues_issue_bulk_read_fail.
    mo_reader->set_results(
      it_results = VALUE #(
        ( is_successful = abap_false
          messages      = VALUE #(
            ( type = 'E' message = 'Reservation not found' ) ) )
        ( is_successful = abap_true
          items         = VALUE #(
            ( reservation_number = '9000000002'
              item_number        = '0002'
              movement_allowed   = abap_true
              required_quantity  = '4.000'
              base_unit          = 'EA'
              base_unit_iso      = 'EA' ) ) ) ) ).

    DATA(ls_result) = mo_cut->post_goods_issue_bulk(
      is_header   = VALUE #(
        posting_date  = '20260922'
        document_date = '20260922' )
      it_requests = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          base_quantity      = '1.000' )
        ( reservation_number = '9000000002'
          reservation_item   = '0002'
          base_quantity      = '1.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Reservation not found'
      act = ls_result-items[ 1 ]-movement_result-messages[ 1 ]-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD continues_issue_bulk_commit.
    mo_reader->set_results(
      it_results = VALUE #(
        ( is_successful = abap_true
          items         = VALUE #(
            ( reservation_number = '9000000001'
              item_number        = '0001'
              movement_allowed   = abap_true
              required_quantity  = '5.000'
              base_unit          = 'EA'
              base_unit_iso      = 'EA' ) ) )
        ( is_successful = abap_true
          items         = VALUE #(
            ( reservation_number = '9000000002'
              item_number        = '0002'
              movement_allowed   = abap_true
              required_quantity  = '4.000'
              base_unit          = 'EA'
              base_unit_iso      = 'EA' ) ) ) ) ).
    mo_goods_api->set_create_results(
      it_results = VALUE #(
        ( material_document = '4900000001'
          fiscal_year       = '2026'
          is_successful     = abap_true )
        ( material_document = '4900000002'
          fiscal_year       = '2026'
          is_successful     = abap_true ) ) ).
    mo_goods_api->set_commit_results(
      it_results = VALUE #(
        ( is_successful = abap_false
          message       = VALUE #(
            type    = 'E'
            message = 'Commit failed' ) )
        ( is_successful = abap_true ) ) ).

    DATA(ls_result) = mo_cut->post_goods_issue_bulk(
      is_header   = VALUE #(
        posting_date  = '20260922'
        document_date = '20260922' )
      it_requests = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          base_quantity      = '1.000' )
        ( reservation_number = '9000000002'
          reservation_item   = '0002'
          base_quantity      = '1.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 1 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_goods_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_goods_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD simulates_issue_bulk.
    DATA(ls_result) = mo_cut->post_goods_issue_bulk(
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
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD posts_reversal_bulk.
    DATA(ls_result) = mo_cut->post_goods_issue_reversal_bulk(
      is_header   = VALUE #(
        posting_date  = '20260923'
        document_date = '20260923' )
      it_requests = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          base_quantity      = '1.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '06'
      act = mo_goods_api->get_gm_code( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-is_committed ).
  ENDMETHOD.

  METHOD validates_issue_bulk_first.
    DATA lv_rejected TYPE abap_bool.
    TRY.
        mo_cut->post_goods_issue_bulk(
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
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reader->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD empty_issue_bulk.
    DATA(ls_result) = mo_cut->post_goods_issue_bulk(
      is_header   = VALUE #(
        posting_date  = '20260922'
        document_date = '20260922' )
      it_requests = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-items ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reader->get_read_count( ) ).
  ENDMETHOD.

  METHOD posts_issue_in_unit.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful = abap_true
        items         = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            movement_allowed   = abap_true
            material           = 'MAT-1'
            required_quantity  = '5.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' ) ) ) ).

    DATA(ls_result) = mo_cut->post_goods_issue_in_unit(
      is_header   = VALUE #(
        posting_date  = '20260922'
        document_date = '20260922' )
      it_requests = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          quantity           = '1.500'
          unit               = 'BOX' ) ) ).
    DATA(lt_items) = mo_goods_api->get_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_items[ 1 ]-entry_unit ).
  ENDMETHOD.

  METHOD posts_reversal_in_unit.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful = abap_true
        items         = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            is_final_issue     = abap_true
            movement_allowed   = abap_false
            material           = 'MAT-1'
            required_quantity  = '5.000'
            withdrawn_quantity = '4.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' ) ) ) ).

    DATA(ls_result) = mo_cut->post_goods_issue_rev_in_unit(
      is_header   = VALUE #(
        posting_date  = '20260923'
        document_date = '20260923' )
      it_requests = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          quantity           = '2.000'
          unit               = 'BOX' ) ) ).
    DATA(lt_items) = mo_goods_api->get_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '06'
      act = mo_goods_api->get_gm_code( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_items[ 1 ]-quantity ).
  ENDMETHOD.

  METHOD posts_issue_bulk_unit.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful = abap_true
        items         = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            movement_allowed   = abap_true
            material           = 'MAT-1'
            required_quantity  = '5.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' )
          ( reservation_number = '9000000001'
            item_number        = '0002'
            movement_allowed   = abap_true
            material           = 'MAT-1'
            required_quantity  = '5.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' ) ) ) ).

    DATA(ls_result) = mo_cut->post_goods_issue_bulk_unit(
      is_header   = VALUE #(
        posting_date  = '20260922'
        document_date = '20260922' )
      it_requests = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          quantity           = '1.000'
          unit               = 'BOX' )
        ( reservation_number = '9000000001'
          reservation_item   = '0002'
          quantity           = '1.000'
          unit               = 'BOX' ) ) ).
    DATA(lt_items) = mo_goods_api->get_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_items[ 2 ]-quantity ).
  ENDMETHOD.

  METHOD rejects_unknown_issue_unit.
    DATA lv_rejected TYPE abap_bool.
    TRY.
        mo_cut->post_goods_issue_in_unit(
          is_header   = VALUE #(
            posting_date  = '20260922'
            document_date = '20260922' )
          it_requests = VALUE #(
            ( reservation_number = '9000000001'
              reservation_item   = '0001'
              quantity           = '1.000'
              unit               = 'PACK' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD posts_reversal_bulk_unit.
    DATA(ls_result) = mo_cut->post_goods_issue_rev_bulk_unit(
      is_header   = VALUE #(
        posting_date  = '20260923'
        document_date = '20260923' )
      it_requests = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          quantity           = '1.000'
          unit               = 'BOX' ) ) ).
    DATA(lt_items) = mo_goods_api->get_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '06'
      act = mo_goods_api->get_gm_code( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-is_committed ).
  ENDMETHOD.

  METHOD rejects_issue_unit_mismatch.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful = abap_true
        items         = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            movement_allowed   = abap_true
            material           = 'MAT-1'
            required_quantity  = '5.000'
            base_unit          = 'KG'
            base_unit_iso      = 'KG' ) ) ) ).
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->post_goods_issue_in_unit(
          is_header   = VALUE #(
            posting_date  = '20260922'
            document_date = '20260922' )
          it_requests = VALUE #(
            ( reservation_number = '9000000001'
              reservation_item   = '0001'
              quantity           = '1.000'
              unit               = 'BOX' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD posts_cc_issue_rev.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful = abap_true
        items         = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            is_final_issue     = abap_true
            withdrawn_quantity = '5.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' ) ) ) ).
    mo_cc_reader->set_reservations(
      it_reservations = VALUE #(
        ( cost_center        = 'COST-100'
          reservation_number = '9000000001'
          reservation_item   = '0001'
          material           = 'MAT-1'
          plant              = '1000'
          unit               = 'EA'
          required_quantity  = '5.000'
          withdrawn_quantity = '5.000'
          open_quantity      = '0.000' ) ) ).

    DATA(ls_result) = mo_cut->post_cc_issue_rev(
      iv_cost_center = 'COST-100'
      is_header      = VALUE #(
        posting_date  = '20261013'
        document_date = '20261013' )
      it_requests    = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          base_quantity      = '1.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '06'
      act = mo_goods_api->get_gm_code( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_wrong_cc_rev.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->post_cc_issue_rev(
          iv_cost_center = 'COST-200'
          is_header      = VALUE #(
            posting_date  = '20261013'
            document_date = '20261013' )
          it_requests    = VALUE #(
            ( reservation_number = '9000000001'
              reservation_item   = '0001'
              base_quantity      = '1.000' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reader->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD posts_cc_rev_bulk_unit.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful = abap_true
        items         = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            material           = 'MAT-1'
            withdrawn_quantity = '5.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' ) ) ) ).
    mo_cc_reader->set_reservations(
      it_reservations = VALUE #(
        ( cost_center        = 'COST-100'
          reservation_number = '9000000001'
          reservation_item   = '0001'
          material           = 'MAT-1'
          plant              = '1000'
          unit               = 'EA'
          required_quantity  = '5.000'
          withdrawn_quantity = '5.000'
          open_quantity      = '0.000' ) ) ).

    DATA(ls_result) = mo_cut->post_cc_issue_rev_bulk_unit(
      iv_cost_center = 'COST-100'
      is_header      = VALUE #(
        posting_date  = '20261013'
        document_date = '20261013' )
      it_requests    = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          quantity           = '1.000'
          unit               = 'BOX' ) ) ).
    DATA(lt_items) = mo_goods_api->get_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-is_committed ).
  ENDMETHOD.

  METHOD stops_cc_reversal_bulk_failure.
    mo_cc_reader->set_reservations(
      it_reservations = VALUE #(
        ( cost_center        = 'COST-100'
          reservation_number = '9000000001'
          reservation_item   = '0001'
          material           = 'MAT-1'
          plant              = '1000'
          unit               = 'EA'
          required_quantity  = '5.000'
          withdrawn_quantity = '2.000'
          open_quantity      = '0.000' )
        ( cost_center        = 'COST-100'
          reservation_number = '9000000002'
          reservation_item   = '0001'
          material           = 'MAT-2'
          plant              = '1000'
          unit               = 'EA'
          required_quantity  = '6.000'
          withdrawn_quantity = '3.000'
          open_quantity      = '0.000' )
        ( cost_center        = 'COST-100'
          reservation_number = '9000000003'
          reservation_item   = '0001'
          material           = 'MAT-3'
          plant              = '1000'
          unit               = 'EA'
          required_quantity  = '3.000'
          withdrawn_quantity = '4.000'
          open_quantity      = '0.000' ) ) ).
    mo_reader->set_results(
      it_results = VALUE #(
        ( is_successful = abap_true
          movement_type = '201'
          items         = VALUE #(
            ( reservation_number = '9000000001'
              item_number        = '0001'
              record_type        = '1'
              material           = 'MAT-1'
              plant              = '1000'
              required_quantity  = '5.000'
              withdrawn_quantity = '2.000'
              base_unit          = 'EA'
              base_unit_iso      = 'EA' ) ) )
        ( is_successful = abap_true
          movement_type = '201'
          items         = VALUE #(
            ( reservation_number = '9000000002'
              item_number        = '0001'
              record_type        = '1'
              material           = 'MAT-2'
              plant              = '1000'
              required_quantity  = '6.000'
              withdrawn_quantity = '3.000'
              base_unit          = 'EA'
              base_unit_iso      = 'EA' ) ) )
        ( is_successful = abap_true
          movement_type = '201'
          items         = VALUE #(
            ( reservation_number = '9000000003'
              item_number        = '0001'
              record_type        = '1'
              material           = 'MAT-3'
              plant              = '1000'
              required_quantity  = '3.000'
              withdrawn_quantity = '4.000'
              base_unit          = 'EA'
              base_unit_iso      = 'EA' ) ) ) ) ).
    mo_goods_api->set_create_results(
      it_results = VALUE #(
        ( material_document = '4900000001'
          fiscal_year       = '2026'
          is_successful     = abap_true )
        ( messages      = VALUE #(
            ( type = 'E' message = 'Second cost-center reversal failed' ) )
          is_successful = abap_false )
        ( material_document = '4900000003'
          fiscal_year       = '2026'
          is_successful     = abap_true ) ) ).

    DATA(ls_result) = mo_cut->post_cc_issue_rev_bulk(
      iv_cost_center     = 'COST-100'
      is_header          = VALUE #(
        posting_date  = '20261014'
        document_date = '20261014' )
      it_requests        = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          base_quantity      = '1.000' )
        ( reservation_number = '9000000002'
          reservation_item   = '0001'
          base_quantity      = '1.000' )
        ( reservation_number = '9000000003'
          reservation_item   = '0001'
          base_quantity      = '1.000' ) )
      iv_stop_on_failure = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-stopped_on_failure ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-skipped_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-is_attempted ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 1 ]-is_skipped ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_attempted ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 2 ]-is_skipped ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 2 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '9000000003'
      act = ls_result-items[ 3 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 3 ]-is_skipped ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_goods_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_reader->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_cc_reader->get_scope_read_count( ) ).
  ENDMETHOD.

  METHOD posts_cc_rev_atomic.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful = abap_true
        items         = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            material           = 'MAT-1'
            withdrawn_quantity = '5.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' ) ) ) ).
    mo_cc_reader->set_reservations(
      it_reservations = VALUE #(
        ( cost_center        = 'COST-100'
          reservation_number = '9000000001'
          reservation_item   = '0001'
          material           = 'MAT-1'
          plant              = '1000'
          unit               = 'EA'
          required_quantity  = '5.000'
          withdrawn_quantity = '5.000'
          open_quantity      = '0.000' ) ) ).

    DATA(ls_result) = mo_cut->post_cc_issue_rev_atomic(
      iv_cost_center = 'COST-100'
      is_header      = VALUE #(
        posting_date  = '20261013'
        document_date = '20261013' )
      it_requests    = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001'
          quantity           = '1.000'
          unit               = 'BOX' ) ) ).
    DATA(lt_items) = mo_goods_api->get_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '06'
      act = mo_goods_api->get_gm_code( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_cc_rev_atomic_flag.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->post_cc_issue_rev_atomic(
          iv_cost_center = 'COST-100'
          is_header      = VALUE #(
            posting_date  = '20261013'
            document_date = '20261013' )
          it_requests    = VALUE #(
            ( reservation_number = '9000000001'
              reservation_item   = '0001'
              quantity           = '1.000'
              unit               = 'EA' ) )
          iv_test_run    = '2' ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_cc_reader->get_scope_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD previews_cc_rev_remaining.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful = abap_true
        movement_type = '201'
        items         = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            material           = 'MAT-1'
            required_quantity  = '5.000'
            withdrawn_quantity = '2.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA'
            storage_location   = '0001'
            batch              = 'BATCH-1' ) ) ) ).

    DATA(lt_requests) = mo_cut->preview_cc_rev_remaining(
      iv_cost_center = 'COST-100'
      it_item_keys   = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_requests[ 1 ]-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_requests[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BATCH-1'
      act = lt_requests[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_cc_reader->get_scope_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_reader->get_read_count( ) ).
  ENDMETHOD.

  METHOD posts_cc_rev_remaining_atomic.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful = abap_true
        movement_type = '201'
        items         = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            material           = 'MAT-1'
            required_quantity  = '5.000'
            withdrawn_quantity = '2.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA'
            storage_location   = '0001'
            batch              = 'BATCH-1' ) ) ) ).

    DATA(ls_result) = mo_cut->post_cc_rev_remaining_atomic(
      iv_cost_center = 'COST-100'
      is_header      = VALUE #(
        posting_date  = '20261014'
        document_date = '20261014' )
      it_item_keys   = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001' ) ) ).
    DATA(lt_items) = mo_goods_api->get_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '06'
      act = mo_goods_api->get_gm_code( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_cc_reader->get_scope_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD posts_cc_rev_remaining_bulk.
    mo_cc_reader->set_reservations(
      it_reservations = VALUE #(
        ( cost_center        = 'COST-100'
          reservation_number = '9000000001'
          reservation_item   = '0001'
          material           = 'MAT-1'
          plant              = '1000'
          unit               = 'EA'
          required_quantity  = '5.000'
          withdrawn_quantity = '2.000'
          open_quantity      = '3.000' )
        ( cost_center        = 'COST-100'
          reservation_number = '9000000002'
          reservation_item   = '0001'
          material           = 'MAT-2'
          plant              = '1000'
          unit               = 'EA'
          required_quantity  = '6.000'
          withdrawn_quantity = '3.000'
          open_quantity      = '3.000' ) ) ).
    mo_reader->set_results(
      it_results = VALUE #(
        ( is_successful = abap_true
          movement_type = '201'
          items         = VALUE #(
            ( reservation_number = '9000000001'
              item_number        = '0001'
              material           = 'MAT-1'
              required_quantity  = '5.000'
              withdrawn_quantity = '2.000'
              base_unit          = 'EA'
              base_unit_iso      = 'EA' ) ) )
        ( is_successful = abap_true
          movement_type = '201'
          items         = VALUE #(
            ( reservation_number = '9000000002'
              item_number        = '0001'
              material           = 'MAT-2'
              required_quantity  = '6.000'
              withdrawn_quantity = '3.000'
              base_unit          = 'EA'
              base_unit_iso      = 'EA' ) ) )
        ( is_successful = abap_true
          movement_type = '201'
          items         = VALUE #(
            ( reservation_number = '9000000001'
              item_number        = '0001'
              material           = 'MAT-1'
              required_quantity  = '5.000'
              withdrawn_quantity = '2.000'
              base_unit          = 'EA'
              base_unit_iso      = 'EA' ) ) )
        ( is_successful = abap_true
          movement_type = '201'
          items         = VALUE #(
            ( reservation_number = '9000000002'
              item_number        = '0001'
              material           = 'MAT-2'
              required_quantity  = '6.000'
              withdrawn_quantity = '3.000'
              base_unit          = 'EA'
              base_unit_iso      = 'EA' ) ) ) ) ).

    DATA(ls_result) = mo_cut->post_cc_rev_remaining_bulk(
      iv_cost_center = 'COST-100'
      is_header      = VALUE #(
        posting_date  = '20261014'
        document_date = '20261014' )
      it_item_keys   = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001' )
        ( reservation_number = '9000000002'
          reservation_item   = '0001' ) ) ).
    DATA(lt_items) = mo_goods_api->get_all_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_items[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_goods_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_goods_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_cc_rev_scope_change.
    mo_reader->set_result(
      is_result = VALUE #(
        is_successful = abap_true
        movement_type = '201'
        items         = VALUE #(
          ( reservation_number = '9000000001'
            item_number        = '0001'
            material           = 'MAT-1'
            required_quantity  = '5.000'
            withdrawn_quantity = '2.000'
            base_unit          = 'EA'
            base_unit_iso      = 'EA' ) ) ) ).
    mo_cc_reader->fail_scope_on_call( iv_call = 2 ).

    DATA(ls_result) = mo_cut->post_cc_rev_remaining_atomic(
      iv_cost_center = 'COST-100'
      is_header      = VALUE #(
        posting_date  = '20261014'
        document_date = '20261014' )
      it_item_keys   = VALUE #(
        ( reservation_number = '9000000001'
          reservation_item   = '0001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_cc_reader->get_scope_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_duplicate_cc_rev_keys.
    DATA lv_rejected TYPE abap_bool.

    TRY.
        mo_cut->preview_cc_rev_remaining(
          iv_cost_center = 'COST-100'
          it_item_keys   = VALUE #(
            ( reservation_number = '9000000001'
              reservation_item   = '0001' )
            ( reservation_number = '9000000001'
              reservation_item   = '0001' ) ) ).
      CATCH zcx_invalid_goods_movement.
        lv_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_cc_reader->get_scope_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_reader->get_read_count( ) ).
  ENDMETHOD.
ENDCLASS.
