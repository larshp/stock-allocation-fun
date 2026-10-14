CLASS lcl_replenishment_req_api DEFINITION FINAL.
  PUBLIC SECTION.
    TYPES ty_results TYPE STANDARD TABLE OF
      zif_purchase_requisition_api=>ty_result WITH EMPTY KEY.
    INTERFACES zif_purchase_requisition_api.
    METHODS set_write_result
      IMPORTING
        is_result TYPE zif_purchase_requisition_api=>ty_result.
    METHODS set_commit_result
      IMPORTING
        is_result TYPE zif_purchase_requisition_api=>ty_commit_result.
    METHODS set_delete_results
      IMPORTING
        it_results TYPE ty_results.
    METHODS set_create_results
      IMPORTING
        it_results TYPE ty_results.
    METHODS set_change_results
      IMPORTING
        it_results TYPE ty_results.
    METHODS set_read_result
      IMPORTING
        is_result TYPE zif_purchase_requisition_api=>ty_result.
    METHODS set_read_results
      IMPORTING
        it_results TYPE ty_results.
    METHODS get_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_read_requisition
      RETURNING
        VALUE(rv_requisition) TYPE zif_purchase_requisition_api=>ty_requisition_number.
    METHODS get_create_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_commit_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_rollback_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_delete_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_deleted_requisition
      RETURNING
        VALUE(rv_requisition) TYPE zif_purchase_requisition_api=>ty_requisition_number.
    METHODS get_deleted_items
      RETURNING
        VALUE(rt_items) TYPE zif_purchase_requisition_api=>ty_requisition_item_numbers.
    METHODS was_delete_test_run
      RETURNING
        VALUE(rv_test_run) TYPE abap_bool.
    METHODS get_change_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_item_updates
      RETURNING
        VALUE(rt_updates) TYPE zif_purchase_requisition_api=>ty_item_updates.
    METHODS get_changed_requisition
      RETURNING
        VALUE(rv_requisition) TYPE zif_purchase_requisition_api=>ty_requisition_number.
    METHODS was_change_test_run
      RETURNING
        VALUE(rv_test_run) TYPE abap_bool.
    DATA ms_request TYPE zif_purchase_requisition_api=>ty_request.
  PRIVATE SECTION.
    DATA ms_write_result TYPE zif_purchase_requisition_api=>ty_result.
    DATA ms_commit_result TYPE zif_purchase_requisition_api=>ty_commit_result.
    DATA mt_create_results TYPE ty_results.
    DATA mt_change_results TYPE ty_results.
    DATA mt_delete_results TYPE ty_results.
    DATA mv_create_count TYPE i.
    DATA mv_commit_count TYPE i.
    DATA mv_rollback_count TYPE i.
    DATA mv_delete_count TYPE i.
    DATA mv_change_count TYPE i.
    DATA mv_deleted_requisition TYPE c LENGTH 10.
    DATA mt_deleted_items TYPE zif_purchase_requisition_api=>ty_requisition_item_numbers.
    DATA mv_delete_test_run TYPE abap_bool.
    DATA mv_changed_requisition TYPE c LENGTH 10.
    DATA mt_item_updates TYPE zif_purchase_requisition_api=>ty_item_updates.
    DATA mv_change_test_run TYPE abap_bool.
    DATA ms_read_result TYPE zif_purchase_requisition_api=>ty_result.
    DATA mt_read_results TYPE ty_results.
    DATA mv_read_count TYPE i.
    DATA mv_read_requisition TYPE c LENGTH 10.
ENDCLASS.

CLASS lcl_replenishment_req_api IMPLEMENTATION.
  METHOD set_write_result.
    ms_write_result = is_result.
  ENDMETHOD.

  METHOD set_commit_result.
    ms_commit_result = is_result.
  ENDMETHOD.

  METHOD set_delete_results.
    mt_delete_results = it_results.
  ENDMETHOD.

  METHOD set_create_results.
    mt_create_results = it_results.
  ENDMETHOD.

  METHOD set_change_results.
    mt_change_results = it_results.
  ENDMETHOD.

  METHOD set_read_result.
    ms_read_result = is_result.
  ENDMETHOD.

  METHOD set_read_results.
    mt_read_results = it_results.
  ENDMETHOD.

  METHOD get_read_count.
    rv_count = mv_read_count.
  ENDMETHOD.

  METHOD get_read_requisition.
    rv_requisition = mv_read_requisition.
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

  METHOD get_delete_count.
    rv_count = mv_delete_count.
  ENDMETHOD.

  METHOD get_deleted_requisition.
    rv_requisition = mv_deleted_requisition.
  ENDMETHOD.

  METHOD get_deleted_items.
    rt_items = mt_deleted_items.
  ENDMETHOD.

  METHOD was_delete_test_run.
    rv_test_run = mv_delete_test_run.
  ENDMETHOD.

  METHOD get_change_count.
    rv_count = mv_change_count.
  ENDMETHOD.

  METHOD get_item_updates.
    rt_updates = mt_item_updates.
  ENDMETHOD.

  METHOD get_changed_requisition.
    rv_requisition = mv_changed_requisition.
  ENDMETHOD.

  METHOD was_change_test_run.
    rv_test_run = mv_change_test_run.
  ENDMETHOD.

  METHOD zif_purchase_requisition_api~read_items.
    ADD 1 TO mv_read_count.
    mv_read_requisition = iv_requisition_number.
    READ TABLE mt_read_results INDEX mv_read_count INTO rs_result.
    IF sy-subrc <> 0.
      rs_result = ms_read_result.
    ENDIF.
    rs_result-requisition_number = iv_requisition_number.
    rs_result-bapi_was_called = abap_true.
  ENDMETHOD.

  METHOD zif_purchase_requisition_api~create_requisition.
    ADD 1 TO mv_create_count.
    ms_request = is_request.
    READ TABLE mt_create_results
      INDEX mv_create_count
      INTO rs_result.
    IF sy-subrc <> 0.
      rs_result = ms_write_result.
    ENDIF.
  ENDMETHOD.

  METHOD zif_purchase_requisition_api~mark_items_deleted.
    ADD 1 TO mv_delete_count.
    mv_deleted_requisition = iv_requisition_number.
    mt_deleted_items = it_item_numbers.
    mv_delete_test_run = iv_test_run.
    READ TABLE mt_delete_results
      INDEX mv_delete_count
      INTO rs_result.
    IF sy-subrc <> 0.
      rs_result = ms_write_result.
    ENDIF.
    rs_result-requisition_number = iv_requisition_number.
    rs_result-submitted_item_numbers = it_item_numbers.
    rs_result-is_test_run = iv_test_run.
    rs_result-bapi_was_called = abap_true.
  ENDMETHOD.

  METHOD zif_purchase_requisition_api~change_items.
    ADD 1 TO mv_change_count.
    mv_changed_requisition = iv_requisition_number.
    mt_item_updates = it_item_updates.
    mv_change_test_run = iv_test_run.
    READ TABLE mt_change_results
      INDEX mv_change_count
      INTO rs_result.
    IF sy-subrc <> 0.
      rs_result = ms_write_result.
    ENDIF.
    rs_result-requisition_number = iv_requisition_number.
    rs_result-submitted_item_updates = it_item_updates.
    rs_result-is_test_run = iv_test_run.
    rs_result-bapi_was_called = abap_true.
  ENDMETHOD.

  METHOD zif_purchase_requisition_api~commit.
    ADD 1 TO mv_commit_count.
    rs_result = ms_commit_result.
  ENDMETHOD.

  METHOD zif_purchase_requisition_api~rollback.
    ADD 1 TO mv_rollback_count.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_replenishment_req_service DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS creates_from_suggestions FOR TESTING.
    METHODS creates_project_stock_req FOR TESTING.
    METHODS rejects_bad_project_shortfall FOR TESTING.
    METHODS prepares_from_suggestions FOR TESTING.
    METHODS creates_from_selected_sources FOR TESTING.
    METHODS prepares_from_selected_sources FOR TESTING.
    METHODS creates_pr_from_quota_splits FOR TESTING.
    METHODS rejects_incomplete_quota_split FOR TESTING.
    METHODS creates_in_selected_order_unit FOR TESTING.
    METHODS creates_with_unit_control FOR TESTING.
    METHODS reads_pr_items FOR TESTING.
    METHODS rejects_bad_pr_read FOR TESTING.
    METHODS reads_pr_items_bulk FOR TESTING.
    METHODS rejects_bad_pr_read_batch FOR TESTING.
    METHODS deletes_all_active_pr_items FOR TESTING.
    METHODS skips_empty_pr_delete FOR TESTING.
    METHODS stops_pr_delete_on_read_error FOR TESTING.
    METHODS continues_bulk_pr_delete FOR TESTING.
    METHODS rejects_bad_bulk_pr_delete FOR TESTING.
    METHODS rejects_order_unit_ratio FOR TESTING.
    METHODS creates_from_agreement_source FOR TESTING.
    METHODS simulates_replenishment_req FOR TESTING.
    METHODS marks_pr_items_deleted FOR TESTING.
    METHODS updates_pr_items FOR TESTING.
    METHODS simulates_pr_item_update FOR TESTING.
    METHODS rejects_bad_pr_item_update FOR TESTING.
    METHODS rolls_back_pr_item_update FOR TESTING.
    METHODS bulk_updates_pr_items_ind FOR TESTING.
    METHODS updates_pr_items_atomically FOR TESTING.
    METHODS simulates_atomic_pr_updates FOR TESTING.
    METHODS rolls_back_atomic_pr_update FOR TESTING.
    METHODS fails_atomic_pr_update_commit FOR TESTING.
    METHODS rejects_bad_pr_update_batch FOR TESTING.
    METHODS simulates_pr_item_deletion FOR TESTING.
    METHODS rejects_bad_pr_deletion FOR TESTING.
    METHODS rolls_back_pr_item_deletion FOR TESTING.
    METHODS deletes_pr_items_atomically FOR TESTING.
    METHODS simulates_atomic_pr_deletion FOR TESTING.
    METHODS rolls_back_atomic_pr_deletion FOR TESTING.
    METHODS rolls_back_atomic_pr_commit FOR TESTING.
    METHODS rejects_bad_atomic_pr_delete FOR TESTING.
    METHODS bulk_deletes_pr_items_ind FOR TESTING.
    METHODS simulates_bulk_pr_delete FOR TESTING.
    METHODS rolls_back_pr_commit_message FOR TESTING.
    METHODS reports_pr_write_failures FOR TESTING.
    METHODS creates_multi_pr_atomically FOR TESTING.
    METHODS simulates_multi_pr_create FOR TESTING.
    METHODS rolls_back_multi_pr_error FOR TESTING.
    METHODS rolls_back_multi_pr_commit FOR TESTING.
    METHODS rolls_back_pr_without_number FOR TESTING.
    METHODS rejects_bad_atomic_pr_create FOR TESTING.
    METHODS bulk_creates_pr_ind FOR TESTING.
    METHODS simulates_bulk_pr_create FOR TESTING.
    METHODS rolls_back_replenishment_req FOR TESTING.
    METHODS handles_covered_suggestions FOR TESTING.
    METHODS rejects_bad_repl_req FOR TESTING.
ENDCLASS.

CLASS ltcl_replenishment_req_service IMPLEMENTATION.
  METHOD creates_project_stock_req.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_write_result( is_result = VALUE #(
      requisition_number = '0010004321'
      is_successful      = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->create_from_proj_shortfalls(
      it_shortfalls       = VALUE #(
        ( request_id    = 'PROJECT-REQ-1'
          wbs_element   = 'PRJ-100-001'
          material      = 'MAT-PROJECT-1'
          plant         = '1000'
          quantity      = '5.000'
          unit          = 'EA'
          delivery_date = '20261120' )
        ( request_id    = 'PROJECT-REQ-2'
          wbs_element   = 'PRJ-100-002'
          material      = 'MAT-PROJECT-2'
          plant         = '1000'
          quantity      = '3.000'
          unit          = 'KG'
          delivery_date = '20261125' ) )
      iv_purchasing_group = '001'
      iv_purchasing_org   = '2000' ).

    cl_abap_unit_assert=>assert_true(
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true(
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010004321'
      act = ls_result-requisition_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lo_api->ms_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00010'
      act = lo_api->ms_request-items[ 1 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Q'
      act = lo_api->ms_request-items[ 1 ]-account_assignment_category ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-100-001'
      act = lo_api->ms_request-items[ 1 ]-wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = '5.000'
      act = lo_api->ms_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00020'
      act = lo_api->ms_request-items[ 2 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-100-002'
      act = lo_api->ms_request-items[ 2 ]-wbs_element ).
  ENDMETHOD.

  METHOD rejects_bad_project_shortfall.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    TRY.
        lo_cut->create_from_proj_shortfalls(
          it_shortfalls = VALUE #(
            ( request_id    = 'PROJECT-REQ-1'
              material      = 'MAT-PROJECT-1'
              plant         = '1000'
              quantity      = '5.000'
              unit          = 'EA'
              delivery_date = '20261120' ) ) ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_invalid_stock_request.
        cl_abap_unit_assert=>assert_equals(
          exp = 0
          act = lo_api->get_create_count( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD creates_from_suggestions.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_write_result( is_result = VALUE #(
      requisition_number = '0010001234'
      is_successful      = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->create_from_suggestions(
      it_suggestions         = VALUE #(
        ( material                    = 'MAT-REQ-1'
          plant                       = '1000'
          base_unit                   = 'EA'
          required_date               = '20261115'
          procurement_type            = 'F'
          source_vendor               = '0000100001'
          source_purchasing_org       = '2000'
          source_info_record          = '0000001234'
          source_category             = '0'
          suggested_base_quantity     = '2.500'
          suggested_receipt_count     = 1
          final_receipt_base_quantity = '2.500' )
        ( material                    = 'MAT-REQ-2'
          plant                       = '1000'
          base_unit                   = 'EA'
          required_date               = '20261116'
          suggested_base_quantity     = '0.000'
          suggested_receipt_count     = 0
          final_receipt_base_quantity = '0.000' )
        ( material                    = 'MAT-REQ-3'
          plant                       = '2000'
          base_unit                   = 'KG'
          required_date               = '20261117'
          procurement_type            = 'F'
          suggested_base_quantity     = '4.000'
          suggested_receipt_count     = 1
          final_receipt_base_quantity = '4.000' )
        ( material                    = 'MAT-REQ-4'
          plant                       = '2000'
          base_unit                   = 'EA'
          required_date               = '20261118'
          procurement_type            = 'F'
          maximum_base_quantity       = '3.000'
          suggested_base_quantity     = '5.000'
          suggested_receipt_count     = 2
          final_receipt_base_quantity = '2.000' )
        ( material                    = 'MAT-REQ-5'
          plant                       = '2000'
          base_unit                   = 'EA'
          required_date               = '20261119'
          procurement_type            = 'F'
          fixed_base_quantity         = '3.000'
          rounding_profile            = 'R001'
          suggested_base_quantity     = '15.000'
          suggested_receipt_count     = 3
          final_receipt_base_quantity = '5.000' ) )
      iv_requisition_type    = 'ZNB'
      iv_purchasing_group    = '001'
      iv_purchasing_org      = '1000'
      it_purchasing_controls = VALUE #(
        ( source_suggestion_index = 1
          purchasing_group        = '005' )
        ( source_suggestion_index = 4
          purchasing_group        = '002'
          purchasing_org          = '2000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-bapi_was_called ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010001234'
      act = ls_result-requisition_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'ZNB'
      act = lo_api->ms_request-requisition_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 7
      act = lines( lo_api->ms_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 7
      act = lines( ls_result-submitted_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00010'
      act = lo_api->ms_request-items[ 1 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MAT-REQ-1'
      act = lo_api->ms_request-items[ 1 ]-material ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.500' )
      act = lo_api->ms_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '005'
      act = lo_api->ms_request-items[ 1 ]-purchasing_group ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = lo_api->ms_request-items[ 2 ]-purchasing_org ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = lo_api->ms_request-items[ 1 ]-purchasing_org ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lo_api->ms_request-items[ 1 ]-source_vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001234'
      act = lo_api->ms_request-items[ 1 ]-source_info_record ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261115' )
      act = lo_api->ms_request-items[ 1 ]-delivery_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-submitted_items[ 1 ]-source_suggestion_index ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00020'
      act = lo_api->ms_request-items[ 2 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'KG'
      act = lo_api->ms_request-items[ 2 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = '001'
      act = lo_api->ms_request-items[ 2 ]-purchasing_group ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = lo_api->ms_request-items[ 2 ]-purchasing_org ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MAT-REQ-4'
      act = lo_api->ms_request-items[ 3 ]-material ).
    cl_abap_unit_assert=>assert_equals(
      exp = '002'
      act = lo_api->ms_request-items[ 3 ]-purchasing_group ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = lo_api->ms_request-items[ 3 ]-purchasing_org ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lo_api->ms_request-items[ 3 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00040'
      act = lo_api->ms_request-items[ 4 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lo_api->ms_request-items[ 4 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = ls_result-submitted_items[ 4 ]-source_suggestion_index ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00050'
      act = lo_api->ms_request-items[ 5 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lo_api->ms_request-items[ 5 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lo_api->ms_request-items[ 6 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lo_api->ms_request-items[ 7 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = lo_api->ms_request-items[ 7 ]-source_suggestion_index ).
  ENDMETHOD.

  METHOD prepares_from_suggestions.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_request) = lo_cut->prepare_from_suggestions(
      it_suggestions         = VALUE #(
        ( material                    = 'MAT-PREP-1'
          plant                       = '1000'
          base_unit                   = 'EA'
          required_date               = '20261115'
          procurement_type            = 'F'
          source_vendor               = '0000100001'
          source_purchasing_org       = '1000'
          source_info_record          = '0000001234'
          source_category             = '0'
          maximum_base_quantity       = '4.000'
          suggested_base_quantity     = '6.000'
          suggested_receipt_count     = 2
          final_receipt_base_quantity = '2.000' )
        ( material                    = 'MAT-PREP-2'
          plant                       = '1000'
          base_unit                   = 'EA'
          required_date               = '20261116'
          suggested_base_quantity     = '0.000'
          suggested_receipt_count     = 0
          final_receipt_base_quantity = '0.000' ) )
      iv_requisition_type    = 'ZNB'
      iv_purchasing_group    = '001'
      iv_purchasing_org      = '1000'
      it_purchasing_controls = VALUE #(
        ( source_suggestion_index = 1
          purchasing_group        = '005'
          purchasing_org          = '2000'
          purchasing_unit         = 'CS'
          order_to_base_num       = 2
          order_to_base_den       = 1 ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'ZNB'
      act = ls_request-requisition_type ).
    cl_abap_unit_assert=>assert_false( ls_request-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00010'
      act = ls_request-items[ 1 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_request-items[ 1 ]-source_suggestion_index ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CS'
      act = ls_request-items[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = '005'
      act = ls_request-items[ 1 ]-purchasing_group ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = ls_request-items[ 1 ]-purchasing_org ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00020'
      act = ls_request-items[ 2 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_request-items[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD creates_from_selected_sources.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_write_result( is_result = VALUE #(
      requisition_number = '0010004321'
      is_successful      = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->create_from_selected_sources(
      it_suggestions             = VALUE #(
        ( material = 'MAT-SELECT-1' plant = '1000' base_unit = 'EA'
          required_date = '20261115' procurement_type = 'F'
          suggested_base_quantity = '2.000'
          suggested_receipt_count = 1
          final_receipt_base_quantity = '2.000' )
        ( material = 'MAT-SELECT-2' plant = '1000' base_unit = 'EA'
          required_date = '20261116' procurement_type = 'F'
          suggested_base_quantity = '3.000'
          suggested_receipt_count = 1
          final_receipt_base_quantity = '3.000' ) )
      it_selected_source_options = VALUE #(
        ( suggestion_index = 1 source_kind =
            zcl_repl_source_service=>c_suggestion_source_pir
          candidate_rank = 1
          pir_candidate = VALUE #(
            request_index = 1 candidate_rank = 1
            material = 'MAT-SELECT-1' plant = '1000'
            purchasing_org = '1000' delivery_date = '20261115'
            vendor = '0000100001' info_record = '0000001001'
            source_category = '0' ) )
        ( suggestion_index = 2 source_kind =
            zcl_repl_source_service=>c_suggestion_source_outline
          candidate_rank = 1
          outline_candidate = VALUE #(
            request_index = 2 candidate_rank = 1
            material = 'MAT-SELECT-2' plant = '1000'
            purchasing_org = '2000' delivery_date = '20261116'
            vendor = '0000100002' purchasing_document = '4500000099'
            purchasing_item = '00020' document_category = 'L' ) ) )
      iv_purchasing_org          = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010004321'
      act = ls_result-requisition_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lo_api->ms_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lo_api->ms_request-items[ 1 ]-source_vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001001'
      act = lo_api->ms_request-items[ 1 ]-source_info_record ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100002'
      act = lo_api->ms_request-items[ 2 ]-source_vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000099'
      act = lo_api->ms_request-items[ 2 ]-source_agreement ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00020'
      act = lo_api->ms_request-items[ 2 ]-source_agreement_item ).
    cl_abap_unit_assert=>assert_initial(
      act = lo_api->ms_request-items[ 2 ]-source_info_record ).
  ENDMETHOD.

  METHOD prepares_from_selected_sources.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_request) = lo_cut->prepare_from_selected_sources(
      it_suggestions             = VALUE #(
        ( material                    = 'MAT-SELECT-PREP'
          plant                       = '1000'
          base_unit                   = 'EA'
          required_date               = '20261115'
          procurement_type            = 'F'
          suggested_base_quantity     = '2.000'
          suggested_receipt_count     = 1
          final_receipt_base_quantity = '2.000' ) )
      it_selected_source_options = VALUE #(
        ( suggestion_index = 1
          source_kind      =
            zcl_repl_source_service=>c_suggestion_source_pir
          candidate_rank   = 1
          pir_candidate    = VALUE #(
            request_index       = 1
            candidate_rank      = 1
            material            = 'MAT-SELECT-PREP'
            plant               = '1000'
            purchasing_org      = '2000'
            delivery_date       = '20261115'
            vendor              = '0000100001'
            info_record         = '0000001001'
            source_category     = '0'
            purchase_order_unit = 'CS'
            order_to_base_num   = 2
            order_to_base_den   = 1 ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CS'
      act = ls_request-items[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = ls_request-items[ 1 ]-purchasing_org ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = ls_request-items[ 1 ]-source_vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001001'
      act = ls_request-items[ 1 ]-source_info_record ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_request-items[ 1 ]-source_suggestion_index ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD creates_pr_from_quota_splits.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_write_result( is_result = VALUE #(
      requisition_number = '0010004322'
      is_successful      = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).
    DATA(lt_suggestions) = VALUE zcl_prod_comp_service=>ty_comp_replenishments(
      ( material                    = 'MAT-QUOTA-1'
        plant                       = '1000'
        base_unit                   = 'EA'
        required_date               = '20261120'
        procurement_type            = 'F'
        suggested_base_quantity     = '10.000'
        suggested_receipt_count     = 1
        final_receipt_base_quantity = '10.000' ) ).
    DATA(ls_candidate_one) = VALUE zcl_repl_source_service=>ty_candidate(
      request_index       = 1
      candidate_rank      = 1
      material            = 'MAT-QUOTA-1'
      plant               = '1000'
      purchasing_org      = '2000'
      delivery_date       = '20261120'
      vendor              = '0000100001'
      info_record         = '0000001001'
      source_category     = '0'
      purchase_order_unit = 'BOX'
      order_to_base_num   = 2
      order_to_base_den   = 1
      base_unit           = 'EA'
      is_quota_assigned   = abap_true
      quota_number        = '00000001'
      quota_item          = '01'
      quota_value         = 2 ).
    DATA(ls_candidate_two) = VALUE zcl_repl_source_service=>ty_candidate(
      request_index       = 1
      candidate_rank      = 2
      material            = 'MAT-QUOTA-1'
      plant               = '1000'
      purchasing_org      = '2000'
      delivery_date       = '20261120'
      vendor              = '0000100002'
      info_record         = '0000001002'
      source_category     = '0'
      purchase_order_unit = 'BOX'
      order_to_base_num   = 2
      order_to_base_den   = 1
      base_unit           = 'EA'
      is_quota_assigned   = abap_true
      quota_number        = '00000001'
      quota_item          = '02'
      quota_value         = 1 ).
    DATA(lt_splits) = VALUE zcl_replenishment_req_service=>ty_quota_requisition_splits(
      ( source_suggestion_index = 1
        split                   = VALUE #(
          split_sequence     = 1
          allocated_quantity = '6.000'
          proposal_quantity  = '6.000'
          candidate          = ls_candidate_one ) )
      ( source_suggestion_index = 1
        split                   = VALUE #(
          split_sequence     = 2
          allocated_quantity = '4.000'
          proposal_quantity  = '4.000'
          candidate          = ls_candidate_two ) ) ).

    DATA(ls_request) = lo_cut->prepare_from_quota_splits(
      it_suggestions = lt_suggestions
      it_splits      = lt_splits ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = ls_request-items[ 1 ]-source_vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = ls_request-items[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100002'
      act = ls_request-items[ 2 ]-source_vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_request-items[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_request-items[ 1 ]-source_suggestion_index ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_create_count( ) ).

    DATA(ls_result) = lo_cut->create_from_quota_splits(
      it_suggestions = lt_suggestions
      it_splits      = lt_splits ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lo_api->ms_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lo_api->ms_request-items[ 1 ]-source_vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lo_api->ms_request-items[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lo_api->ms_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100002'
      act = lo_api->ms_request-items[ 2 ]-source_vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lo_api->ms_request-items[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-submitted_items[ 1 ]-source_suggestion_index ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-submitted_items[ 2 ]-source_suggestion_index ).
  ENDMETHOD.

  METHOD rejects_incomplete_quota_split.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).
    DATA(lv_exception_raised) = abap_false.

    TRY.
        lo_cut->create_from_quota_splits(
          it_suggestions = VALUE #(
            ( material                    = 'MAT-QUOTA-2'
              plant                       = '1000'
              base_unit                   = 'EA'
              required_date               = '20261120'
              procurement_type            = 'F'
              suggested_base_quantity     = '10.000'
              suggested_receipt_count     = 1
              final_receipt_base_quantity = '10.000' ) )
          it_splits      = VALUE #(
            ( source_suggestion_index = 1
              split                   = VALUE #(
                split_sequence     = 1
                allocated_quantity = '5.000'
                proposal_quantity  = '5.000'
                candidate          = VALUE #(
                  request_index     = 1
                  candidate_rank    = 1
                  material          = 'MAT-QUOTA-2'
                  plant             = '1000'
                  purchasing_org    = '2000'
                  delivery_date     = '20261120'
                  vendor            = '0000100001'
                  info_record       = '0000001001'
                  source_category   = '0'
                  base_unit         = 'EA'
                  is_quota_assigned = abap_true
                  quota_number      = '00000001'
                  quota_item        = '01'
                  quota_value       = 1 ) ) ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD creates_in_selected_order_unit.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_write_result( is_result = VALUE #(
      requisition_number = '0010009876'
      is_successful      = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).
    DATA lt_suggestions TYPE zcl_prod_comp_service=>ty_comp_replenishments.
    DATA ls_suggestion TYPE zcl_prod_comp_service=>ty_comp_replenishment.
    DATA lt_options TYPE zcl_repl_source_service=>ty_suggestion_source_options.
    DATA ls_option TYPE zcl_repl_source_service=>ty_suggestion_source_option.
    DATA ls_candidate TYPE zcl_repl_source_service=>ty_candidate.
    DATA ls_result TYPE zif_purchase_requisition_api=>ty_result.

    ls_suggestion-material = 'MAT-UNIT-1'.
    ls_suggestion-plant = '1000'.
    ls_suggestion-base_unit = 'EA'.
    ls_suggestion-required_date = '20261115'.
    ls_suggestion-procurement_type = 'F'.
    ls_suggestion-fixed_base_quantity = '12.000'.
    ls_suggestion-suggested_base_quantity = '24.000'.
    ls_suggestion-suggested_receipt_count = 2.
    ls_suggestion-final_receipt_base_quantity = '12.000'.
    APPEND ls_suggestion TO lt_suggestions.

    ls_candidate-request_index = 1.
    ls_candidate-candidate_rank = 1.
    ls_candidate-material = 'MAT-UNIT-1'.
    ls_candidate-plant = '1000'.
    ls_candidate-purchasing_org = '2000'.
    ls_candidate-delivery_date = '20261115'.
    ls_candidate-vendor = '0000100001'.
    ls_candidate-info_record = '0000001234'.
    ls_candidate-source_category = '0'.
    ls_candidate-purchase_order_unit = 'BOX'.
    ls_candidate-base_unit = 'EA'.
    ls_candidate-order_to_base_num = 12.
    ls_candidate-order_to_base_den = 1.
    ls_option-suggestion_index = 1.
    ls_option-source_kind =
      zcl_repl_source_service=>c_suggestion_source_pir.
    ls_option-candidate_rank = 1.
    ls_option-pir_candidate = ls_candidate.
    APPEND ls_option TO lt_options.

    ls_result = lo_cut->create_from_selected_sources(
      it_suggestions             = lt_suggestions
      it_selected_source_options = lt_options ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lo_api->ms_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lo_api->ms_request-items[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lo_api->ms_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = lo_api->ms_request-items[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = ls_result-submitted_items[ 2 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD creates_with_unit_control.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_write_result( is_result = VALUE #(
      requisition_number = '0010009877'
      is_successful      = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).
    DATA lt_suggestions TYPE zcl_prod_comp_service=>ty_comp_replenishments.
    DATA ls_suggestion TYPE zcl_prod_comp_service=>ty_comp_replenishment.
    DATA lt_controls TYPE zcl_replenishment_req_service=>ty_suggestion_purchasing_controls.
    DATA ls_control TYPE zcl_replenishment_req_service=>ty_suggestion_purchasing_control.

    ls_suggestion-material = 'MAT-UNIT-3'.
    ls_suggestion-plant = '1000'.
    ls_suggestion-base_unit = 'EA'.
    ls_suggestion-required_date = '20261115'.
    ls_suggestion-procurement_type = 'F'.
    ls_suggestion-suggested_base_quantity = '24.000'.
    ls_suggestion-suggested_receipt_count = 1.
    ls_suggestion-final_receipt_base_quantity = '24.000'.
    APPEND ls_suggestion TO lt_suggestions.
    ls_control-source_suggestion_index = 1.
    ls_control-purchasing_unit = 'BOX'.
    ls_control-order_to_base_num = 12.
    ls_control-order_to_base_den = 1.
    APPEND ls_control TO lt_controls.

    DATA(ls_result) = lo_cut->create_from_suggestions(
      it_suggestions         = lt_suggestions
      it_purchasing_controls = lt_controls ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lo_api->ms_request-items[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lo_api->ms_request-items[ 1 ]-quantity ).
  ENDMETHOD.

  METHOD reads_pr_items.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_read_result( is_result = VALUE #(
      is_successful     = abap_true
      requisition_items = VALUE #(
        ( item_number           = '00010'
          short_text            = 'Safety stock replenishment'
          material              = 'MAT-READ'
          plant                 = '1000'
          storage_location      = '0001'
          quantity              = '8.000'
          unit                  = 'EA'
          delivery_date         = '20261120'
          purchasing_group      = '007'
          purchasing_org        = '2000'
          source_vendor         = '0000100001'
          source_info_record    = '0000001234'
          source_agreement      = '4500000001'
          source_agreement_item = '00010'
          processing_status     = '05'
          release_indicator     = 'R'
          release_status        = 'X'
          ordered_quantity      = '3.000'
          po_number             = '4500000999'
          po_item               = '00010'
          is_fixed              = abap_true )
        ( item_number        = '00020'
          deletion_indicator = abap_true ) ) ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->read_pr_items(
      iv_requisition_number = '0012345678' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-bapi_was_called ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0012345678'
      act = lo_api->get_read_requisition( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-requisition_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MAT-READ'
      act = ls_result-requisition_items[ 1 ]-material ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000001'
      act = ls_result-requisition_items[ 1 ]-source_agreement ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000999'
      act = ls_result-requisition_items[ 1 ]-po_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-requisition_items[ 1 ]-is_fixed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-requisition_items[ 2 ]-deletion_indicator ).
  ENDMETHOD.

  METHOD rejects_bad_pr_read.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->read_pr_items( iv_requisition_number = space ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_read_count( ) ).
  ENDMETHOD.

  METHOD reads_pr_items_bulk.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_read_results( it_results = VALUE #(
      ( is_successful     = abap_true
        requisition_items = VALUE #( (
          item_number = '00010'
          material    = 'MAT-ONE' ) ) )
      ( is_successful = abap_false
        messages      = VALUE #( (
          type    = 'E'
          message = 'Requisition is unavailable' ) ) ) ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->read_pr_items_bulk(
      it_requisition_numbers = VALUE #(
        ( '0012345678' )
        ( '0012345679' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-requisition_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0012345678'
      act = ls_result-requisition_results[ 1 ]-requisition_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MAT-ONE'
      act = ls_result-requisition_results[ 1 ]-requisition_items[ 1 ]-material ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-requisition_results[ 2 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Requisition is unavailable'
      act = ls_result-requisition_results[ 2 ]-messages[ 1 ]-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_api->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_pr_read_batch.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).
    DATA lv_exception_raised TYPE abap_bool.

    DATA(ls_empty_result) = lo_cut->read_pr_items_bulk(
      it_requisition_numbers = VALUE #( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_empty_result-is_successful ).

    TRY.
        lo_cut->read_pr_items_bulk(
          it_requisition_numbers = VALUE #(
            ( '0012345678' )
            ( space ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).

    CLEAR lv_exception_raised.
    TRY.
        lo_cut->read_pr_items_bulk(
          it_requisition_numbers = VALUE #(
            ( '0012345678' )
            ( '0012345678' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_read_count( ) ).
  ENDMETHOD.

  METHOD deletes_all_active_pr_items.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_read_result( is_result = VALUE #(
      is_successful     = abap_true
      requisition_items = VALUE #(
        ( item_number = '00010' )
        ( item_number        = '00020'
          deletion_indicator = abap_true )
        ( item_number = '00030' ) ) ) ).
    lo_api->set_write_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->delete_all_pr_items(
      iv_requisition_number = '0012345678' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-submitted_item_numbers ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00010'
      act = ls_result-submitted_item_numbers[ 1 ] ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00030'
      act = ls_result-submitted_item_numbers[ 2 ] ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_delete_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-requisition_items ) ).
  ENDMETHOD.

  METHOD skips_empty_pr_delete.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_read_result( is_result = VALUE #(
      is_successful     = abap_true
      requisition_items = VALUE #( (
        item_number        = '00020'
        deletion_indicator = abap_true ) ) ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->delete_all_pr_items(
      iv_requisition_number = '0012345678' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_delete_count( ) ).
  ENDMETHOD.

  METHOD stops_pr_delete_on_read_error.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_read_result( is_result = VALUE #(
      is_successful = abap_false
      messages      = VALUE #( (
        type    = 'E'
        message = 'Requisition could not be read' ) ) ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->delete_all_pr_items(
      iv_requisition_number = '0012345678' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Requisition could not be read'
      act = ls_result-messages[ 1 ]-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_delete_count( ) ).
  ENDMETHOD.

  METHOD continues_bulk_pr_delete.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_read_results( it_results = VALUE #(
      ( is_successful = abap_false
        messages      = VALUE #( (
          type    = 'E'
          message = 'First requisition could not be read' ) ) )
      ( is_successful     = abap_true
        requisition_items = VALUE #( (
          item_number = '00010' ) ) ) ) ).
    lo_api->set_write_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->delete_all_pr_items_bulk(
      it_requisition_numbers = VALUE #(
        ( '0012345678' )
        ( '0012345679' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-requisition_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-requisition_results[ 1 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'First requisition could not be read'
      act = ls_result-requisition_results[ 1 ]-messages[ 1 ]-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-requisition_results[ 2 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_api->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_delete_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_bulk_pr_delete.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->delete_all_pr_items_bulk(
          it_requisition_numbers = VALUE #(
            ( '0012345678' )
            ( space ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_read_count( ) ).
  ENDMETHOD.

  METHOD rejects_order_unit_ratio.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).
    DATA lv_exception_raised TYPE abap_bool.
    DATA lt_suggestions TYPE zcl_prod_comp_service=>ty_comp_replenishments.
    DATA ls_suggestion TYPE zcl_prod_comp_service=>ty_comp_replenishment.
    DATA lt_controls TYPE zcl_replenishment_req_service=>ty_suggestion_purchasing_controls.
    DATA ls_control TYPE zcl_replenishment_req_service=>ty_suggestion_purchasing_control.

    ls_suggestion-material = 'MAT-UNIT-2'.
    ls_suggestion-plant = '1000'.
    ls_suggestion-base_unit = 'EA'.
    ls_suggestion-required_date = '20261115'.
    ls_suggestion-procurement_type = 'F'.
    ls_suggestion-suggested_base_quantity = '12.000'.
    ls_suggestion-suggested_receipt_count = 1.
    ls_suggestion-final_receipt_base_quantity = '12.000'.
    APPEND ls_suggestion TO lt_suggestions.
    ls_control-source_suggestion_index = 1.
    ls_control-purchasing_unit = 'BOX'.
    ls_control-order_to_base_num = 12.
    APPEND ls_control TO lt_controls.

    TRY.
        lo_cut->create_from_suggestions(
          it_suggestions         = lt_suggestions
          it_purchasing_controls = lt_controls ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD creates_from_agreement_source.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_write_result( is_result = VALUE #(
      requisition_number = '0010001234'
      is_successful      = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    lo_cut->create_from_suggestions(
      it_suggestions = VALUE #(
        ( material                    = 'MAT-CONTRACT'
          plant                       = '1000'
          base_unit                   = 'EA'
          required_date               = '20261115'
          procurement_type            = 'F'
          source_vendor               = '0000100001'
          source_purchasing_org       = '2000'
          source_agreement            = '4500000001'
          source_agreement_item       = '00010'
          suggested_base_quantity     = '2.000'
          suggested_receipt_count     = 1
          final_receipt_base_quantity = '2.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = '4500000001'
      act = lo_api->ms_request-items[ 1 ]-source_agreement ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00010'
      act = lo_api->ms_request-items[ 1 ]-source_agreement_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = lo_api->ms_request-items[ 1 ]-purchasing_org ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lo_api->ms_request-items[ 1 ]-source_vendor ).
    cl_abap_unit_assert=>assert_initial(
      act = lo_api->ms_request-items[ 1 ]-source_info_record ).
  ENDMETHOD.

  METHOD simulates_replenishment_req.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_write_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->create_from_suggestions(
      it_suggestions = VALUE #(
        ( material                    = 'MAT-REQ'
          plant                       = '1000'
          base_unit                   = 'EA'
          required_date               = '20261115'
          procurement_type            = 'F'
          suggested_base_quantity     = '1.000'
          suggested_receipt_count     = 1
          final_receipt_base_quantity = '1.000' ) )
      iv_test_run    = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-bapi_was_called ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lo_api->ms_request-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00010'
      act = ls_result-submitted_items[ 1 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-submitted_items[ 1 ]-source_suggestion_index ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD marks_pr_items_deleted.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_write_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).
    DATA(lt_item_numbers) = VALUE zif_purchase_requisition_api=>ty_requisition_item_numbers(
      ( '00010' )
      ( '00030' ) ).

    DATA(ls_result) = lo_cut->mark_pr_items_deleted(
      iv_requisition_number = '0012345678'
      it_item_numbers       = lt_item_numbers ).
    DATA(lt_deleted_items) = lo_api->get_deleted_items( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0012345678'
      act = ls_result-requisition_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-submitted_item_numbers ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00030'
      act = ls_result-submitted_item_numbers[ 2 ] ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0012345678'
      act = lo_api->get_deleted_requisition( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_deleted_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD simulates_pr_item_deletion.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_write_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->mark_pr_items_deleted(
      iv_requisition_number = '0012345678'
      it_item_numbers       = VALUE #( ( '00010' ) )
      iv_test_run           = abap_true ).

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
      act = lo_api->was_delete_test_run( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD updates_pr_items.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_write_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).
    DATA(lt_updates) = VALUE zif_purchase_requisition_api=>ty_item_updates(
      ( item_number               = '00010'
        change_quantity           = abap_true
        quantity                  = '7.000'
        change_source_vendor      = abap_true
        source_vendor             = '0000100001'
        change_source_info_record = abap_true
        source_info_record        = '0000001234' )
      ( item_number             = '00020'
        change_delivery_date    = abap_true
        delivery_date           = '20261201'
        change_purchasing_group = abap_true
        purchasing_group        = '007'
        change_purchasing_org   = abap_true
        purchasing_org          = '2000' ) ).

    DATA(ls_result) = lo_cut->update_pr_items(
      iv_requisition_number = '0012345678'
      it_item_updates       = lt_updates ).
    DATA(lt_submitted_updates) = lo_api->get_item_updates( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0012345678'
      act = lo_api->get_changed_requisition( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_submitted_updates ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '7.000'
      act = ls_result-submitted_item_updates[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261201'
      act = lt_submitted_updates[ 2 ]-delivery_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_submitted_updates[ 1 ]-source_vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001234'
      act = lt_submitted_updates[ 1 ]-source_info_record ).
    cl_abap_unit_assert=>assert_equals(
      exp = '007'
      act = lt_submitted_updates[ 2 ]-purchasing_group ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = lt_submitted_updates[ 2 ]-purchasing_org ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_change_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD simulates_pr_item_update.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_write_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->update_pr_items(
      iv_requisition_number = '0012345678'
      it_item_updates       = VALUE #( (
        item_number          = '00010'
        change_delivery_date = abap_true
        delivery_date        = '20261210' ) )
      iv_test_run           = abap_true ).

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
      act = lo_api->was_change_test_run( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_pr_item_update.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->update_pr_items(
          iv_requisition_number = '0012345678'
          it_item_updates       = VALUE #(
            ( item_number     = '00010'
              change_quantity = abap_true
              quantity        = '1.000' )
            ( item_number          = '00010'
              change_delivery_date = abap_true
              delivery_date        = '20261201' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).

    CLEAR lv_exception_raised.
    TRY.
        lo_cut->update_pr_items(
          iv_requisition_number = '0012345678'
          it_item_updates       = VALUE #( (
            item_number          = '00010'
            change_source_vendor = 'Y'
            source_vendor        = '0000100001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).

    CLEAR lv_exception_raised.
    TRY.
        lo_cut->update_pr_items(
          iv_requisition_number = '0012345678'
          it_item_updates       = VALUE #( (
            item_number   = '00010'
            source_vendor = '0000100001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).

    CLEAR lv_exception_raised.
    TRY.
        lo_cut->update_pr_items(
          iv_requisition_number = '0012345678'
          it_item_updates       = VALUE #( (
            item_number = '00010' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).

    CLEAR lv_exception_raised.
    TRY.
        lo_cut->update_pr_items(
          iv_requisition_number = '0012345678'
          it_item_updates       = VALUE #( (
            item_number     = '00010'
            change_quantity = abap_true
            quantity        = 0 ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).

    CLEAR lv_exception_raised.
    TRY.
        lo_cut->update_pr_items(
          iv_requisition_number = '0012345678'
          it_item_updates       = VALUE #( (
            item_number     = '00010'
            change_quantity = 'Y'
            quantity        = '1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_change_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_pr_item_update.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_write_result( is_result = VALUE #(
      messages = VALUE #(
        ( type      = 'E'
          parameter = 'PRITEM'
          row       = 1
          message   = 'Item is released' ) ) ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->update_pr_items(
      iv_requisition_number = '0012345678'
      it_item_updates       = VALUE #( (
        item_number     = '00030'
        change_quantity = abap_true
        quantity        = '4.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00030'
      act = ls_result-messages[ 1 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD bulk_updates_pr_items_ind.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_change_results( it_results = VALUE #(
      ( messages = VALUE #(
          ( type    = 'E'
            message = 'Item is released' ) ) )
      ( is_successful = abap_true ) ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->update_pr_items_bulk(
      it_requests = VALUE #(
        ( requisition_number = '0012345678'
          item_updates       = VALUE #(
            ( item_number     = '00010'
              change_quantity = abap_true
              quantity        = '2.000' ) ) )
        ( requisition_number = '0012345679'
          item_updates       = VALUE #(
            ( item_number     = '00020'
              change_quantity = abap_true
              quantity        = '3.000' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-requisition_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-requisition_results[ 1 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-requisition_results[ 2 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-requisition_results[ 2 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_api->get_change_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD updates_pr_items_atomically.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_change_results( it_results = VALUE #(
      ( is_successful = abap_true )
      ( is_successful = abap_true ) ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->update_pr_items_bulk(
      it_requests = VALUE #(
        ( requisition_number = '0012345678'
          item_updates       = VALUE #(
            ( item_number     = '00010'
              change_quantity = abap_true
              quantity        = '2.000' ) ) )
        ( requisition_number = '0012345679'
          item_updates       = VALUE #(
            ( item_number          = '00020'
              change_delivery_date = abap_true
              delivery_date        = '20261201' ) ) ) )
      iv_atomic   = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-requisition_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-requisition_results[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-requisition_results[ 2 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_api->get_change_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD simulates_atomic_pr_updates.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_change_results( it_results = VALUE #(
      ( is_successful = abap_true )
      ( is_successful = abap_true ) ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->update_pr_items_bulk(
      it_requests = VALUE #(
        ( requisition_number = '0012345678'
          item_updates       = VALUE #(
            ( item_number     = '00010'
              change_quantity = abap_true
              quantity        = '2.000' ) ) )
        ( requisition_number = '0012345679'
          item_updates       = VALUE #(
            ( item_number          = '00020'
              change_delivery_date = abap_true
              delivery_date        = '20261201' ) ) ) )
      iv_test_run = abap_true
      iv_atomic   = abap_true ).

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
      exp = 0
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_atomic_pr_update.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_change_results( it_results = VALUE #(
      ( is_successful = abap_true )
      ( messages = VALUE #(
          ( type      = 'E'
            parameter = 'PRITEMX'
            row       = 1
            message   = 'Item is released' ) ) ) ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->update_pr_items_bulk(
      it_requests = VALUE #(
        ( requisition_number = '0012345678'
          item_updates       = VALUE #(
            ( item_number     = '00010'
              change_quantity = abap_true
              quantity        = '2.000' ) ) )
        ( requisition_number = '0012345679'
          item_updates       = VALUE #(
            ( item_number     = '00020'
              change_quantity = abap_true
              quantity        = '3.000' ) ) )
        ( requisition_number = '0012345680'
          item_updates       = VALUE #(
            ( item_number     = '00030'
              change_quantity = abap_true
              quantity        = '4.000' ) ) ) )
      iv_atomic   = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-requisition_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00020'
      act = ls_result-requisition_results[ 2 ]-messages[ 1 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-requisition_results[ 3 ]-bapi_was_called ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_api->get_change_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD fails_atomic_pr_update_commit.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_change_results( it_results = VALUE #(
      ( is_successful = abap_true )
      ( is_successful = abap_true ) ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true
      message       = VALUE #(
        type    = 'E'
        message = 'Commit failed' ) ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->update_pr_items_bulk(
      it_requests = VALUE #(
        ( requisition_number = '0012345678'
          item_updates       = VALUE #(
            ( item_number     = '00010'
              change_quantity = abap_true
              quantity        = '2.000' ) ) )
        ( requisition_number = '0012345679'
          item_updates       = VALUE #(
            ( item_number     = '00020'
              change_quantity = abap_true
              quantity        = '3.000' ) ) ) )
      iv_atomic   = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Commit failed'
      act = ls_result-commit_result-message-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-requisition_results[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_pr_update_batch.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->update_pr_items_bulk(
          it_requests = VALUE #(
            ( requisition_number = '0012345678'
              item_updates       = VALUE #(
                ( item_number     = '00010'
                  change_quantity = abap_true
                  quantity        = '2.000' ) ) )
            ( requisition_number = '0012345678'
              item_updates       = VALUE #(
                ( item_number     = '00020'
                  change_quantity = abap_true
                  quantity        = '3.000' ) ) ) )
          iv_atomic   = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).

    CLEAR lv_exception_raised.
    TRY.
        lo_cut->update_pr_items_bulk(
          it_requests = VALUE #(
            ( requisition_number = '0012345678'
              item_updates       = VALUE #(
                ( item_number     = '00010'
                  change_quantity = abap_true
                  quantity        = '0.000' ) ) ) )
          iv_atomic   = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_change_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_pr_deletion.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->mark_pr_items_deleted(
          iv_requisition_number = '0012345678'
          it_item_numbers       = VALUE #( ( '00010' ) ( '00010' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_delete_count( ) ).

    CLEAR lv_exception_raised.
    TRY.
        lo_cut->mark_pr_items_deleted(
          iv_requisition_number = '0012345678'
          it_item_numbers       = VALUE #( ( '00010' ) )
          iv_test_run           = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_delete_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_pr_item_deletion.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_write_result( is_result = VALUE #(
      messages      = VALUE #( ( type = 'E' message = 'PR item is released' ) )
      is_successful = abap_false ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->mark_pr_items_deleted(
      iv_requisition_number = '0012345678'
      it_item_numbers       = VALUE #( ( '00010' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD deletes_pr_items_atomically.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_delete_results( it_results = VALUE #(
      ( is_successful = abap_true )
      ( is_successful = abap_true ) ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->delete_pr_items_atomic(
      it_requests = VALUE #(
        ( requisition_number = '0012345678'
          item_numbers       = VALUE #( ( '00010' ) ( '00020' ) ) )
        ( requisition_number = '0012345679'
          item_numbers       = VALUE #( ( '00030' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-requisition_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0012345678'
      act = ls_result-requisition_results[ 1 ]-requisition_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00020'
      act = ls_result-requisition_results[ 1 ]-submitted_item_numbers[ 2 ] ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0012345679'
      act = ls_result-requisition_results[ 2 ]-requisition_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-requisition_results[ 2 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_api->get_delete_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD simulates_atomic_pr_deletion.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_delete_results( it_results = VALUE #(
      ( is_successful = abap_true )
      ( is_successful = abap_true ) ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->delete_pr_items_atomic(
      it_requests = VALUE #(
        ( requisition_number = '0012345678'
          item_numbers       = VALUE #( ( '00010' ) ) )
        ( requisition_number = '0012345679'
          item_numbers       = VALUE #( ( '00020' ) ) ) )
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
      act = lo_api->was_delete_test_run( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_atomic_pr_deletion.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_delete_results( it_results = VALUE #(
      ( is_successful = abap_true )
      ( messages = VALUE #(
          ( type      = 'E'
            parameter = 'PRITEMX'
            row       = 1
            message   = 'Requisition item is released' ) ) ) ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->delete_pr_items_atomic(
      it_requests = VALUE #(
        ( requisition_number = '0012345678'
          item_numbers       = VALUE #( ( '00010' ) ) )
        ( requisition_number = '0012345679'
          item_numbers       = VALUE #( ( '00020' ) ) )
        ( requisition_number = '0012345680'
          item_numbers       = VALUE #( ( '00030' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-requisition_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00020'
      act = ls_result-requisition_results[ 2 ]-messages[ 1 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-requisition_results[ 3 ]-bapi_was_called ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_api->get_delete_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_atomic_pr_commit.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_delete_results( it_results = VALUE #(
      ( is_successful = abap_true )
      ( is_successful = abap_true ) ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true
      message       = VALUE #(
        type    = 'E'
        message = 'Commit failed' ) ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->delete_pr_items_atomic(
      it_requests = VALUE #(
        ( requisition_number = '0012345678'
          item_numbers       = VALUE #( ( '00010' ) ) )
        ( requisition_number = '0012345679'
          item_numbers       = VALUE #( ( '00020' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Commit failed'
      act = ls_result-commit_result-message-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-requisition_results[ 1 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_atomic_pr_delete.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->delete_pr_items_atomic(
          it_requests = VALUE #(
            ( requisition_number = '0012345678'
              item_numbers       = VALUE #( ( '00010' ) ) )
            ( requisition_number = '0012345678'
              item_numbers       = VALUE #( ( '00020' ) ) ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).

    CLEAR lv_exception_raised.
    TRY.
        lo_cut->delete_pr_items_atomic(
          it_requests = VALUE #(
            ( requisition_number = '0012345678'
              item_numbers       = VALUE #( ( '00010' ) ( '00010' ) ) ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).

    CLEAR lv_exception_raised.
    TRY.
        lo_cut->delete_pr_items_atomic(
          it_requests = VALUE #(
            ( requisition_number = '0012345678'
              item_numbers       = VALUE #( ( '00010' ) ) ) )
          iv_test_run = 'Y' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_delete_count( ) ).
  ENDMETHOD.

  METHOD bulk_deletes_pr_items_ind.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_delete_results( it_results = VALUE #(
      ( messages = VALUE #(
          ( type    = 'E'
            message = 'Requisition item is released' ) ) )
      ( is_successful = abap_true ) ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->delete_pr_items_bulk(
      it_requests = VALUE #(
        ( requisition_number = '0012345678'
          item_numbers       = VALUE #( ( '00010' ) ) )
        ( requisition_number = '0012345679'
          item_numbers       = VALUE #( ( '00020' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-requisition_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-requisition_results[ 1 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-requisition_results[ 2 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-requisition_results[ 2 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_api->get_delete_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD simulates_bulk_pr_delete.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_delete_results( it_results = VALUE #(
      ( is_successful = abap_true )
      ( is_successful = abap_true ) ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->delete_pr_items_bulk(
      it_requests = VALUE #(
        ( requisition_number = '0012345678'
          item_numbers       = VALUE #( ( '00010' ) ) )
        ( requisition_number = '0012345679'
          item_numbers       = VALUE #( ( '00020' ) ) ) )
      iv_test_run = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lo_api->was_delete_test_run( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-requisition_results[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_pr_commit_message.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_write_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true
      message       = VALUE #(
        type    = 'E'
        message = 'Commit failed' ) ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->mark_pr_items_deleted(
      iv_requisition_number = '0012345678'
      it_item_numbers       = VALUE #( ( '00010' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Commit failed'
      act = ls_result-messages[ 1 ]-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD reports_pr_write_failures.
    DATA(lo_error_api) = NEW lcl_replenishment_req_api( ).
    lo_error_api->set_write_result( is_result = VALUE #(
      is_successful = abap_false ) ).
    DATA(lo_error_cut) = NEW zcl_replenishment_req_service(
      io_api = lo_error_api ).
    DATA(ls_error_result) = lo_error_cut->mark_pr_items_deleted(
      iv_requisition_number = '0012345678'
      it_item_numbers       = VALUE #( ( '00010' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'Purchase requisition write failed without an error message'
      act = ls_error_result-messages[ 1 ]-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'E'
      act = ls_error_result-messages[ 1 ]-type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_error_api->get_rollback_count( ) ).

    DATA(lo_commit_api) = NEW lcl_replenishment_req_api( ).
    lo_commit_api->set_write_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    lo_commit_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_false
      message       = VALUE #(
        type    = 'W'
        message = 'Update was delayed' ) ) ).
    DATA(lo_commit_cut) = NEW zcl_replenishment_req_service(
      io_api = lo_commit_api ).
    DATA(ls_commit_result) = lo_commit_cut->mark_pr_items_deleted(
      iv_requisition_number = '0012345678'
      it_item_numbers       = VALUE #( ( '00010' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_commit_result-messages ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'E'
      act = ls_commit_result-messages[ 2 ]-type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Purchase requisition write commit failed'
      act = ls_commit_result-messages[ 2 ]-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_commit_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD creates_multi_pr_atomically.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_create_results( it_results = VALUE #(
      ( requisition_number = '0010001234'
        is_successful      = abap_true )
      ( requisition_number = '0010001235'
        is_successful      = abap_true ) ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->create_requisitions_atomic(
      it_requests = VALUE #(
        ( requisition_type = 'NB'
          items            = VALUE #(
            ( item_number             = '00010'
              source_suggestion_index = 1
              material                = 'MAT-PR-1'
              plant                   = '1000'
              quantity                = '2.000'
              unit                    = 'EA'
              delivery_date           = '20261115' ) ) )
        ( requisition_type = 'ZNB'
          items            = VALUE #(
            ( item_number             = '00020'
              source_suggestion_index = 1
              material                = 'MAT-PR-2'
              plant                   = '2000'
              quantity                = '3.000'
              unit                    = 'EA'
              delivery_date           = '20261116' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-requisition_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010001234'
      act = ls_result-requisition_results[ 1 ]-requisition_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00020'
      act = ls_result-requisition_results[ 2 ]-submitted_items[ 1 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD simulates_multi_pr_create.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_create_results( it_results = VALUE #(
      ( is_successful = abap_true )
      ( is_successful = abap_true ) ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->create_requisitions_atomic(
      it_requests = VALUE #(
        ( requisition_type = 'NB'
          items            = VALUE #(
            ( item_number             = '00010'
              source_suggestion_index = 0
              material                = 'MAT-PR-1'
              plant                   = '1000'
              quantity                = '1.000'
              unit                    = 'EA'
              delivery_date           = '20261115' ) ) )
        ( requisition_type = 'NB'
          items            = VALUE #(
            ( item_number             = '00010'
              source_suggestion_index = 0
              material                = 'MAT-PR-2'
              plant                   = '1000'
              quantity                = '1.000'
              unit                    = 'EA'
              delivery_date           = '20261115' ) ) ) )
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
      act = lo_api->ms_request-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_multi_pr_error.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_create_results( it_results = VALUE #(
      ( requisition_number = '0010001234'
        is_successful      = abap_true )
      ( messages = VALUE #(
          ( type      = 'E'
            parameter = 'PRITEM'
            row       = 1
            message   = 'Material is blocked' ) ) ) ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->create_requisitions_atomic(
      it_requests = VALUE #(
        ( requisition_type = 'NB'
          items            = VALUE #(
            ( item_number             = '00010'
              source_suggestion_index = 0
              material                = 'MAT-PR-1'
              plant                   = '1000'
              quantity                = '1.000'
              unit                    = 'EA'
              delivery_date           = '20261115' ) ) )
        ( requisition_type = 'NB'
          items            = VALUE #(
            ( item_number             = '00020'
              source_suggestion_index = 4
              material                = 'MAT-PR-2'
              plant                   = '1000'
              quantity                = '1.000'
              unit                    = 'EA'
              delivery_date           = '20261116' ) ) )
        ( requisition_type = 'NB'
          items            = VALUE #(
            ( item_number             = '00030'
              source_suggestion_index = 0
              material                = 'MAT-PR-3'
              plant                   = '1000'
              quantity                = '1.000'
              unit                    = 'EA'
              delivery_date           = '20261117' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-requisition_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = ''
      act = ls_result-requisition_results[ 1 ]-requisition_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00020'
      act = ls_result-requisition_results[ 2 ]-messages[ 1 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = ls_result-requisition_results[ 2 ]-messages[ 1 ]-source_suggestion_index ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-requisition_results[ 3 ]-bapi_was_called ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_multi_pr_commit.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_create_results( it_results = VALUE #(
      ( requisition_number = '0010001234'
        is_successful      = abap_true )
      ( requisition_number = '0010001235'
        is_successful      = abap_true ) ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true
      message       = VALUE #(
        type    = 'E'
        message = 'Commit failed' ) ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->create_requisitions_atomic(
      it_requests = VALUE #(
        ( requisition_type = 'NB'
          items            = VALUE #(
            ( item_number             = '00010'
              source_suggestion_index = 0
              material                = 'MAT-PR-1'
              plant                   = '1000'
              quantity                = '1.000'
              unit                    = 'EA'
              delivery_date           = '20261115' ) ) )
        ( requisition_type = 'NB'
          items            = VALUE #(
            ( item_number             = '00020'
              source_suggestion_index = 0
              material                = 'MAT-PR-2'
              plant                   = '1000'
              quantity                = '1.000'
              unit                    = 'EA'
              delivery_date           = '20261116' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Commit failed'
      act = ls_result-commit_result-message-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = ''
      act = ls_result-requisition_results[ 2 ]-requisition_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_pr_without_number.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_create_results( it_results = VALUE #(
      ( is_successful = abap_true ) ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->create_requisitions_atomic(
      it_requests = VALUE #(
        ( requisition_type = 'NB'
          items            = VALUE #(
            ( item_number             = '00010'
              source_suggestion_index = 0
              material                = 'MAT-PR-1'
              plant                   = '1000'
              quantity                = '1.000'
              unit                    = 'EA'
              delivery_date           = '20261115' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Purchase requisition create returned no document number'
      act = ls_result-requisition_results[ 1 ]-messages[ 1 ]-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_atomic_pr_create.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->create_requisitions_atomic(
          it_requests = VALUE #(
            ( requisition_type = 'NB'
              items            = VALUE #(
                ( item_number             = '00010'
                  source_suggestion_index = 0
                  material                = 'MAT-PR-1'
                  plant                   = '1000'
                  quantity                = '1.000'
                  unit                    = 'EA'
                  delivery_date           = '20261115' ) ) )
            ( requisition_type = 'NB'
              items            = VALUE #(
                ( item_number             = '00020'
                  source_suggestion_index = 0
                  material                = 'MAT-PR-2'
                  plant                   = '1000'
                  quantity                = 0
                  unit                    = 'EA'
                  delivery_date           = '20261116' ) ) ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD bulk_creates_pr_ind.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_create_results( it_results = VALUE #(
      ( messages = VALUE #(
          ( type    = 'E'
            message = 'Material is blocked' ) ) )
      ( requisition_number = '0010001235'
        is_successful      = abap_true ) ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->create_requisitions_bulk(
      it_requests = VALUE #(
        ( requisition_type = 'NB'
          items            = VALUE #(
            ( item_number             = '00010'
              source_suggestion_index = 0
              material                = 'MAT-PR-1'
              plant                   = '1000'
              quantity                = '1.000'
              unit                    = 'EA'
              delivery_date           = '20261115' ) ) )
        ( requisition_type = 'NB'
          items            = VALUE #(
            ( item_number             = '00010'
              source_suggestion_index = 0
              material                = 'MAT-PR-2'
              plant                   = '1000'
              quantity                = '2.000'
              unit                    = 'EA'
              delivery_date           = '20261116' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-requisition_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-requisition_results[ 1 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-requisition_results[ 2 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010001235'
      act = ls_result-requisition_results[ 2 ]-requisition_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lo_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD simulates_bulk_pr_create.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_create_results( it_results = VALUE #(
      ( is_successful = abap_true )
      ( is_successful = abap_true ) ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->create_requisitions_bulk(
      it_requests = VALUE #(
        ( requisition_type = 'NB'
          items            = VALUE #(
            ( item_number             = '00010'
              source_suggestion_index = 0
              material                = 'MAT-PR-1'
              plant                   = '1000'
              quantity                = '1.000'
              unit                    = 'EA'
              delivery_date           = '20261115' ) ) )
        ( requisition_type = 'NB'
          items            = VALUE #(
            ( item_number             = '00010'
              source_suggestion_index = 0
              material                = 'MAT-PR-2'
              plant                   = '1000'
              quantity                = '1.000'
              unit                    = 'EA'
              delivery_date           = '20261115' ) ) ) )
      iv_test_run = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-requisition_results[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_replenishment_req.
    DATA(lo_error_api) = NEW lcl_replenishment_req_api( ).
    lo_error_api->set_write_result( is_result = VALUE #(
      messages      = VALUE #( ( type      = 'E'
                                 id        = '06'
                                 number    = '123'
                                 message   = 'Invalid plant'
                                 parameter = 'PRITEM'
                                 row       = 1
                                 field     = 'PLANT' ) )
      is_successful = abap_false ) ).
    DATA(lo_error_cut) = NEW zcl_replenishment_req_service(
      io_api = lo_error_api ).
    DATA(ls_error_result) = lo_error_cut->create_from_suggestions(
      it_suggestions = VALUE #(
        ( material                    = 'MAT-REQ'
          plant                       = '1000'
          base_unit                   = 'EA'
          required_date               = '20261115'
          procurement_type            = 'F'
          suggested_base_quantity     = '1.000'
          suggested_receipt_count     = 1
          final_receipt_base_quantity = '1.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_error_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '06'
      act = ls_error_result-messages[ 1 ]-id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '123'
      act = ls_error_result-messages[ 1 ]-number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRITEM'
      act = ls_error_result-messages[ 1 ]-parameter ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_error_result-messages[ 1 ]-row ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PLANT'
      act = ls_error_result-messages[ 1 ]-field ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00010'
      act = ls_error_result-messages[ 1 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_error_result-messages[ 1 ]-source_suggestion_index ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_error_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_error_api->get_commit_count( ) ).

    DATA(lo_missing_number_api) = NEW lcl_replenishment_req_api( ).
    lo_missing_number_api->set_write_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_missing_number_cut) = NEW zcl_replenishment_req_service(
      io_api = lo_missing_number_api ).
    DATA(ls_missing_number_result) =
      lo_missing_number_cut->create_from_suggestions(
        it_suggestions = VALUE #(
          ( material                    = 'MAT-REQ'
            plant                       = '1000'
            base_unit                   = 'EA'
            required_date               = '20261115'
            procurement_type            = 'F'
            suggested_base_quantity     = '1.000'
            suggested_receipt_count     = 1
            final_receipt_base_quantity = '1.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_missing_number_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_missing_number_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_missing_number_api->get_commit_count( ) ).

    DATA(lo_commit_api) = NEW lcl_replenishment_req_api( ).
    lo_commit_api->set_write_result( is_result = VALUE #(
      requisition_number = '0010001235'
      is_successful      = abap_true ) ).
    lo_commit_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_false
      message       = VALUE #( type       = 'E'
                               id         = '00'
                               number     = '001'
                               message    = 'Commit failed'
                               message_v1 = 'COMMIT' ) ) ).
    DATA(lo_commit_cut) = NEW zcl_replenishment_req_service(
      io_api = lo_commit_api ).
    DATA(ls_commit_result) = lo_commit_cut->create_from_suggestions(
      it_suggestions = VALUE #(
        ( material                    = 'MAT-REQ'
          plant                       = '1000'
          base_unit                   = 'EA'
          required_date               = '20261115'
          procurement_type            = 'F'
          suggested_base_quantity     = '1.000'
          suggested_receipt_count     = 1
          final_receipt_base_quantity = '1.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_commit_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_commit_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_commit_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00'
      act = ls_commit_result-messages[ 1 ]-id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'COMMIT'
      act = ls_commit_result-messages[ 1 ]-message_v1 ).
  ENDMETHOD.

  METHOD handles_covered_suggestions.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->create_from_suggestions(
      it_suggestions = VALUE #(
        ( material                = 'MAT-COVERED'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261115'
          suggested_base_quantity = '0.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-bapi_was_called ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-messages ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_repl_req.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).
    DATA lv_rejected TYPE abap_bool.
    DATA lv_bad_lot_split_rejected TYPE abap_bool.
    DATA lv_inhouse_route_rejected TYPE abap_bool.
    DATA lv_ambiguous_route_rejected TYPE abap_bool.
    DATA lv_special_route_rejected TYPE abap_bool.
    DATA lv_missing_route_rejected TYPE abap_bool.
    DATA lv_duplicate_control_rejected TYPE abap_bool.
    DATA lv_bad_range_control TYPE abap_bool.
    DATA lv_covered_control_rejected TYPE abap_bool.
    DATA lv_empty_control_rejected TYPE abap_bool.
    DATA lv_partial_source_rejected TYPE abap_bool.
    DATA lv_partial_agreement_rejected TYPE abap_bool.
    DATA lv_mixed_source_rejected TYPE abap_bool.
    DATA(lt_control_test_suggestions) =
      VALUE zcl_prod_comp_service=>ty_comp_replenishments(
        ( material                    = 'MAT-REQ'
          plant                       = '1000'
          base_unit                   = 'EA'
          required_date               = '20261115'
          procurement_type            = 'F'
          suggested_base_quantity     = '1.000'
          suggested_receipt_count     = 1
          final_receipt_base_quantity = '1.000' )
        ( material                = 'MAT-COVERED'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261116'
          suggested_base_quantity = '0.000' ) ).

    TRY.
        lo_cut->create_from_suggestions(
          it_suggestions = VALUE #(
            ( material                = 'MAT-REQ'
          plant                       = '1000'
          base_unit                   = 'EA'
          required_date               = '20261115'
          suggested_base_quantity     = '-1.000'
          suggested_receipt_count     = 1
          final_receipt_base_quantity = '-1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_cut->create_from_suggestions(
          it_suggestions = VALUE #(
            ( material                    = 'MAT-REQ'
              plant                       = '1000'
              base_unit                   = 'EA'
              required_date               = '20261115'
              procurement_type            = 'F'
              maximum_base_quantity       = '2.000'
              suggested_base_quantity     = '4.000'
              suggested_receipt_count     = 2
              final_receipt_base_quantity = '1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_bad_lot_split_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_cut->create_from_suggestions(
          it_suggestions = VALUE #(
            ( material                    = 'MAT-INHOUSE'
              plant                       = '1000'
              base_unit                   = 'EA'
              required_date               = '20261115'
              procurement_type            = 'E'
              suggested_base_quantity     = '1.000'
              suggested_receipt_count     = 1
              final_receipt_base_quantity = '1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_inhouse_route_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_cut->create_from_suggestions(
          it_suggestions = VALUE #(
            ( material                    = 'MAT-AMBIGUOUS'
              plant                       = '1000'
              base_unit                   = 'EA'
              required_date               = '20261115'
              procurement_type            = 'X'
              suggested_base_quantity     = '1.000'
              suggested_receipt_count     = 1
              final_receipt_base_quantity = '1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_ambiguous_route_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_cut->create_from_suggestions(
          it_suggestions = VALUE #(
            ( material                    = 'MAT-SPECIAL'
              plant                       = '1000'
              base_unit                   = 'EA'
              required_date               = '20261115'
              procurement_type            = 'F'
              special_procurement_key     = '30'
              suggested_base_quantity     = '1.000'
              suggested_receipt_count     = 1
              final_receipt_base_quantity = '1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_special_route_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_cut->create_from_suggestions(
          it_suggestions = VALUE #(
            ( material                    = 'MAT-NO-POLICY'
              plant                       = '1000'
              base_unit                   = 'EA'
              required_date               = '20261115'
              suggested_base_quantity     = '1.000'
              suggested_receipt_count     = 1
              final_receipt_base_quantity = '1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_missing_route_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_cut->create_from_suggestions(
          it_suggestions         = lt_control_test_suggestions
          it_purchasing_controls = VALUE #(
            ( source_suggestion_index = 1 purchasing_group = '001' )
            ( source_suggestion_index = 1 purchasing_group = '002' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_duplicate_control_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_cut->create_from_suggestions(
          it_suggestions         = lt_control_test_suggestions
          it_purchasing_controls = VALUE #(
            ( source_suggestion_index = 3 purchasing_org = '1000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_bad_range_control = abap_true.
    ENDTRY.

    TRY.
        lo_cut->create_from_suggestions(
          it_suggestions         = lt_control_test_suggestions
          it_purchasing_controls = VALUE #(
            ( source_suggestion_index = 2 purchasing_org = '1000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_covered_control_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_cut->create_from_suggestions(
          it_suggestions         = lt_control_test_suggestions
          it_purchasing_controls = VALUE #(
            ( source_suggestion_index = 1 ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_empty_control_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_cut->create_from_suggestions(
          it_suggestions = VALUE #(
            ( material                    = 'MAT-PARTIAL-SOURCE'
              plant                       = '1000'
              base_unit                   = 'EA'
              required_date               = '20261115'
              procurement_type            = 'F'
              source_vendor               = '0000100001'
              suggested_base_quantity     = '1.000'
              suggested_receipt_count     = 1
              final_receipt_base_quantity = '1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_partial_source_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_cut->create_from_suggestions(
          it_suggestions = VALUE #(
            ( material                    = 'MAT-PARTIAL-AGREEMENT'
              plant                       = '1000'
              base_unit                   = 'EA'
              required_date               = '20261115'
              procurement_type            = 'F'
              source_vendor               = '0000100001'
              source_purchasing_org       = '1000'
              source_agreement            = '4500000001'
              suggested_base_quantity     = '1.000'
              suggested_receipt_count     = 1
              final_receipt_base_quantity = '1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_partial_agreement_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_cut->create_from_suggestions(
          it_suggestions = VALUE #(
            ( material                    = 'MAT-MIXED-SOURCES'
              plant                       = '1000'
              base_unit                   = 'EA'
              required_date               = '20261115'
              procurement_type            = 'F'
              source_vendor               = '0000100001'
              source_purchasing_org       = '1000'
              source_info_record          = '0000001234'
              source_category             = '0'
              source_agreement            = '4500000001'
              source_agreement_item       = '00010'
              suggested_base_quantity     = '1.000'
              suggested_receipt_count     = 1
              final_receipt_base_quantity = '1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_mixed_source_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_lot_split_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_inhouse_route_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_ambiguous_route_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_special_route_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_missing_route_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_duplicate_control_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_range_control ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_covered_control_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_empty_control_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_partial_source_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_partial_agreement_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_mixed_source_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_create_count( ) ).
  ENDMETHOD.
ENDCLASS.
