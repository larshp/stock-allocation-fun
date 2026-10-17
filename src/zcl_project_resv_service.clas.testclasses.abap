CLASS lcl_proj_res_api_double DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_project_reservation_api.
    DATA ms_request TYPE zif_project_reservation_api=>ty_request.
    DATA mt_requests TYPE STANDARD TABLE OF
      zif_project_reservation_api=>ty_request WITH EMPTY KEY.
    DATA ms_create_result TYPE zif_project_reservation_api=>ty_result.
    DATA mt_create_results TYPE STANDARD TABLE OF
      zif_project_reservation_api=>ty_result WITH EMPTY KEY.
    DATA ms_delete_result TYPE
      zif_project_reservation_api=>ty_delete_result.
    DATA mt_delete_results TYPE STANDARD TABLE OF
      zif_project_reservation_api=>ty_delete_result WITH EMPTY KEY.
    DATA ms_delete_items_result TYPE
      zif_project_reservation_api=>ty_delete_result.
    DATA mt_delete_items_results TYPE STANDARD TABLE OF
      zif_project_reservation_api=>ty_delete_result WITH EMPTY KEY.
    DATA ms_change_result TYPE
      zif_project_reservation_api=>ty_change_result.
    DATA mt_change_results TYPE STANDARD TABLE OF
      zif_project_reservation_api=>ty_change_result WITH EMPTY KEY.
    DATA ms_change_quantity_result TYPE
      zif_project_reservation_api=>ty_change_result.
    DATA mt_change_quantity_results TYPE STANDARD TABLE OF
      zif_project_reservation_api=>ty_change_result WITH EMPTY KEY.
    DATA ms_final_issue_result TYPE
      zif_project_reservation_api=>ty_change_result.
    DATA mt_final_issue_results TYPE STANDARD TABLE OF
      zif_project_reservation_api=>ty_change_result WITH EMPTY KEY.
    DATA ms_stock_change_result TYPE
      zif_project_reservation_api=>ty_change_result.
    DATA mt_stock_change_results TYPE STANDARD TABLE OF
      zif_project_reservation_api=>ty_change_result WITH EMPTY KEY.
    DATA mt_deleted_numbers TYPE
      zif_project_reservation_api=>ty_reservation_numbers.
    DATA mt_deleted_item_numbers TYPE
      zif_project_reservation_api=>ty_reservation_item_numbers.
    DATA ms_commit_result TYPE
      zif_project_reservation_api=>ty_commit_result.
    DATA mv_create_calls TYPE i.
    DATA mv_delete_calls TYPE i.
    DATA mv_delete_items_calls TYPE i.
    DATA mv_change_calls TYPE i.
    DATA mv_changed_reservation TYPE
      zif_project_reservation_api=>ty_reservation_number.
    DATA mt_changed_item_numbers TYPE
      zif_project_reservation_api=>ty_reservation_item_numbers.
    DATA mv_changed_required_date TYPE d.
    DATA mv_change_quantity_calls TYPE i.
    DATA mv_qty_change_reservation TYPE
      zif_project_reservation_api=>ty_reservation_number.
    DATA mt_changed_quantities TYPE
      zif_project_reservation_api=>ty_item_quantity_changes.
    DATA mv_final_issue_calls TYPE i.
    DATA mv_final_issue_reservation TYPE
      zif_project_reservation_api=>ty_reservation_number.
    DATA mt_final_issue_items TYPE
      zif_project_reservation_api=>ty_reservation_item_numbers.
    DATA mv_final_issue_value TYPE abap_bool.
    DATA mv_stock_change_calls TYPE i.
    DATA mv_stock_change_reservation TYPE
      zif_project_reservation_api=>ty_reservation_number.
    DATA mt_stock_changes TYPE
      zif_project_reservation_api=>ty_item_stock_changes.
    DATA mv_deleted_item_reservation TYPE
      zif_project_reservation_api=>ty_reservation_number.
    DATA mv_commit_calls TYPE i.
    DATA mv_rollback_calls TYPE i.
    DATA mv_test_run TYPE abap_bool.
    DATA mv_delete_test_run TYPE abap_bool.
ENDCLASS.

CLASS lcl_proj_res_api_double IMPLEMENTATION.
  METHOD zif_project_reservation_api~create_reservation.
    mv_create_calls = mv_create_calls + 1.
    ms_request = is_request.
    APPEND is_request TO mt_requests.
    mv_test_run = iv_test_run.
    READ TABLE mt_create_results INDEX mv_create_calls INTO rs_result.
    IF sy-subrc <> 0.
      rs_result = ms_create_result.
    ENDIF.
  ENDMETHOD.

  METHOD zif_project_reservation_api~delete_reservation.
    mv_delete_calls = mv_delete_calls + 1.
    APPEND iv_reservation_number TO mt_deleted_numbers.
    mv_delete_test_run = iv_test_run.
    READ TABLE mt_delete_results INDEX mv_delete_calls INTO rs_result.
    IF sy-subrc <> 0.
      rs_result = ms_delete_result.
    ENDIF.
  ENDMETHOD.

  METHOD zif_project_reservation_api~delete_reservation_items.
    mv_delete_items_calls = mv_delete_items_calls + 1.
    mv_deleted_item_reservation = iv_reservation_number.
    mt_deleted_item_numbers = it_item_numbers.
    READ TABLE mt_delete_items_results INDEX mv_delete_items_calls
      INTO rs_result.
    IF sy-subrc <> 0.
      rs_result = ms_delete_items_result.
    ENDIF.
  ENDMETHOD.

  METHOD zif_project_reservation_api~change_reservation_item_dates.
    mv_change_calls = mv_change_calls + 1.
    mv_changed_reservation = iv_reservation_number.
    mt_changed_item_numbers = it_item_numbers.
    mv_changed_required_date = iv_required_date.
    READ TABLE mt_change_results INDEX mv_change_calls INTO rs_result.
    IF sy-subrc <> 0.
      rs_result = ms_change_result.
    ENDIF.
  ENDMETHOD.

  METHOD zif_project_reservation_api~change_reservation_qty.
    mv_change_quantity_calls = mv_change_quantity_calls + 1.
    mv_qty_change_reservation = iv_reservation_number.
    mt_changed_quantities = it_item_quantities.
    READ TABLE mt_change_quantity_results INDEX mv_change_quantity_calls
      INTO rs_result.
    IF sy-subrc <> 0.
      rs_result = ms_change_quantity_result.
    ENDIF.
  ENDMETHOD.

  METHOD zif_project_reservation_api~set_items_final_issue.
    mv_final_issue_calls = mv_final_issue_calls + 1.
    mv_final_issue_reservation = iv_reservation_number.
    mt_final_issue_items = it_item_numbers.
    mv_final_issue_value = iv_final_issue.
    READ TABLE mt_final_issue_results INDEX mv_final_issue_calls
      INTO rs_result.
    IF sy-subrc <> 0.
      rs_result = ms_final_issue_result.
    ENDIF.
  ENDMETHOD.

  METHOD zif_project_reservation_api~change_reservation_stock.
    mv_stock_change_calls = mv_stock_change_calls + 1.
    mv_stock_change_reservation = iv_reservation_number.
    mt_stock_changes = it_item_changes.
    READ TABLE mt_stock_change_results INDEX mv_stock_change_calls
      INTO rs_result.
    IF sy-subrc <> 0.
      rs_result = ms_stock_change_result.
    ENDIF.
  ENDMETHOD.

  METHOD zif_project_reservation_api~commit.
    mv_commit_calls = mv_commit_calls + 1.
    rs_result = ms_commit_result.
  ENDMETHOD.

  METHOD zif_project_reservation_api~rollback.
    mv_rollback_calls = mv_rollback_calls + 1.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_proj_res_repo_double DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_project_stock_repository.
    DATA mt_stocks TYPE zif_project_stock_repository=>ty_stocks.
    DATA mt_reservations TYPE zif_project_stock_repository=>ty_reservations.
    DATA mt_recheck_stocks TYPE zif_project_stock_repository=>ty_stocks.
    DATA mv_stock_read_calls TYPE i.
    DATA mv_use_recheck_snapshot TYPE abap_bool.
ENDCLASS.

CLASS lcl_proj_res_repo_double IMPLEMENTATION.
  METHOD zif_project_stock_repository~read_project_stocks.
    mv_stock_read_calls = mv_stock_read_calls + 1.
    IF mv_use_recheck_snapshot = abap_true
        AND mv_stock_read_calls > 1.
      rt_stocks = mt_recheck_stocks.
    ELSE.
      rt_stocks = mt_stocks.
    ENDIF.
  ENDMETHOD.

  METHOD zif_project_stock_repository~read_project_stocks_wbs.
    rt_stocks = mt_stocks.
  ENDMETHOD.

  METHOD zif_project_stock_repository~read_project_reservations.
    rt_reservations = mt_reservations.
  ENDMETHOD.

  METHOD zif_project_stock_repository~read_project_reservations_wbs.
    rt_reservations = mt_reservations.
  ENDMETHOD.

  METHOD zif_project_stock_repository~read_project_resv_items_wbs.
    rt_reservations = mt_reservations.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_proj_res_uom_repo DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_material_uom_repository.
ENDCLASS.

CLASS lcl_proj_res_uom_repo IMPLEMENTATION.
  METHOD zif_material_uom_repository~get_base_unit.
    IF iv_material = 'MAT-1'.
      rv_base_unit = 'EA'.
    ENDIF.
  ENDMETHOD.

  METHOD zif_material_uom_repository~get_alt_unit_ratio.
    IF iv_material = 'MAT-1' AND iv_alternative_unit = 'BOX'.
      rs_ratio-numerator = 12.
      rs_ratio-denominator = 1.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_proj_issue_res_reader DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_so_reservation_reader.
    DATA ms_result TYPE zif_so_reservation_reader=>ty_result.
    DATA mt_results TYPE STANDARD TABLE OF
      zif_so_reservation_reader=>ty_result WITH EMPTY KEY.
    DATA mv_read_calls TYPE i.
ENDCLASS.

CLASS lcl_proj_issue_res_reader IMPLEMENTATION.
  METHOD zif_so_reservation_reader~read_reservation.
    mv_read_calls = mv_read_calls + 1.
    READ TABLE mt_results INDEX mv_read_calls INTO rs_result.
    IF sy-subrc <> 0.
      rs_result = ms_result.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_proj_issue_goods_api DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_goods_movement_api.
    DATA mv_gm_code TYPE zif_goods_movement_api=>ty_gm_code.
    DATA mt_items TYPE zif_goods_movement_api=>ty_items.
    DATA mv_test_run TYPE abap_bool.
    DATA ms_create_result TYPE zif_goods_movement_api=>ty_result.
    DATA mt_create_results TYPE STANDARD TABLE OF
      zif_goods_movement_api=>ty_result WITH EMPTY KEY.
    DATA ms_commit_result TYPE zif_goods_movement_api=>ty_commit_result.
    DATA mv_create_calls TYPE i.
    DATA mv_commit_calls TYPE i.
    DATA mv_rollback_calls TYPE i.
ENDCLASS.

CLASS lcl_proj_issue_goods_api IMPLEMENTATION.
  METHOD zif_goods_movement_api~create_movement.
    mv_create_calls = mv_create_calls + 1.
    mv_gm_code = iv_gm_code.
    mt_items = it_items.
    mv_test_run = iv_test_run.
    READ TABLE mt_create_results INDEX mv_create_calls INTO rs_result.
    IF sy-subrc <> 0.
      rs_result = ms_create_result.
    ENDIF.
  ENDMETHOD.

  METHOD zif_goods_movement_api~cancel_movement.
    rs_result = ms_create_result.
  ENDMETHOD.

  METHOD zif_goods_movement_api~commit.
    mv_commit_calls = mv_commit_calls + 1.
    rs_result = ms_commit_result.
  ENDMETHOD.

  METHOD zif_goods_movement_api~rollback.
    mv_rollback_calls = mv_rollback_calls + 1.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_proj_res_service DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_api TYPE REF TO lcl_proj_res_api_double.
    DATA mo_stock_repo TYPE REF TO lcl_proj_res_repo_double.
    DATA mo_uom_repository TYPE REF TO lcl_proj_res_uom_repo.
    DATA mo_issue_reader TYPE REF TO lcl_proj_issue_res_reader.
    DATA mo_goods_api TYPE REF TO lcl_proj_issue_goods_api.
    DATA mo_cut TYPE REF TO zcl_project_resv_service.
    METHODS setup.
    METHODS reserves_wbs_bulk FOR TESTING.
    METHODS rejects_wbs_bulk_before_write FOR TESTING.
    METHODS continues_wbs_bulk_failure FOR TESTING.
    METHODS reserves_wbs_bulk_atomic FOR TESTING.
    METHODS rolls_back_wbs_bulk_atomic FOR TESTING.
    METHODS fails_wbs_bulk_commit FOR TESTING.
    METHODS simulates_wbs_bulk_no_luw FOR TESTING.
    METHODS batch_preview
      RETURNING
        VALUE(rs_result) TYPE zcl_project_stock_service=>ty_result.
    METHODS location_preview
      RETURNING
        VALUE(rs_result) TYPE zcl_project_stock_service=>ty_location_result.
    METHODS creates_project_reservation FOR TESTING.
    METHODS issues_reserved_wbs_items FOR TESTING.
    METHODS issues_reserved_wbs_bulk FOR TESTING.
    METHODS rejects_bulk_wbs_scope FOR TESTING.
    METHODS simulates_reserved_wbs_issue FOR TESTING.
    METHODS rejects_wrong_wbs_issue FOR TESTING.
    METHODS returns_reserved_wbs_items FOR TESTING.
    METHODS returns_reserved_wbs_bulk FOR TESTING.
    METHODS commits_reserved_wbs_atomic FOR TESTING.
    METHODS rolls_back_reserved_wbs_atomic FOR TESTING.
    METHODS fails_resv_atomic_commit FOR TESTING.
    METHODS simulates_resv_atomic FOR TESTING.
    METHODS returns_reserved_wbs_atomic FOR TESTING.
    METHODS accepts_valid_leap_day FOR TESTING.
    METHODS rejects_invalid_required_date FOR TESTING.
    METHODS rejects_non_numeric_date FOR TESTING.
    METHODS rejects_invalid_alloc_date FOR TESTING.
    METHODS deletes_wbs_reservation_items FOR TESTING.
    METHODS rolls_back_item_commit FOR TESTING.
    METHODS validates_wbs_item_scope FOR TESTING.
    METHODS simulates_wbs_item_delete FOR TESTING.
    METHODS bulk_item_delete_continues FOR TESTING.
    METHODS atomic_delete_commits FOR TESTING.
    METHODS atomic_delete_scope FOR TESTING.
    METHODS atomic_delete_api_failure FOR TESTING.
    METHODS atomic_delete_simulates FOR TESTING.
    METHODS atomic_delete_commit_failure FOR TESTING.
    METHODS reschedules_wbs_items FOR TESTING.
    METHODS rejects_bad_resched_date FOR TESTING.
    METHODS rejects_bad_bulk_resched_date FOR TESTING.
    METHODS rejects_atomic_bad_date FOR TESTING.
    METHODS rejects_reschedule_scope FOR TESTING.
    METHODS simulates_reschedule FOR TESTING.
    METHODS rolls_back_reschedule_commit FOR TESTING.
    METHODS bulk_reschedule_continues FOR TESTING.
    METHODS atomic_resched_commits FOR TESTING.
    METHODS atomic_resched_scope FOR TESTING.
    METHODS atomic_resched_api_failure FOR TESTING.
    METHODS atomic_resched_simulates FOR TESTING.
    METHODS atomic_resched_commit_fail FOR TESTING.
    METHODS changes_project_resv_qty FOR TESTING.
    METHODS rejects_qty_at_withdrawn FOR TESTING.
    METHODS simulates_quantity_change FOR TESTING.
    METHODS bulk_quantity_continues FOR TESTING.
    METHODS atomic_qty_commits_once FOR TESTING.
    METHODS atomic_qty_validates_scope FOR TESTING.
    METHODS atomic_qty_rolls_back_api FOR TESTING.
    METHODS atomic_qty_simulates FOR TESTING.
    METHODS atomic_qty_commit_failure FOR TESTING.
    METHODS marks_reservation_final FOR TESTING.
    METHODS rejects_final_issue_scope FOR TESTING.
    METHODS simulates_final_issue FOR TESTING.
    METHODS bulk_final_issue_continues FOR TESTING.
    METHODS resets_final_issue FOR TESTING.
    METHODS rejects_final_reset_scope FOR TESTING.
    METHODS simulates_final_reset FOR TESTING.
    METHODS bulk_final_reset_continues FOR TESTING.
    METHODS atomic_final_commit_success FOR TESTING.
    METHODS atomic_final_reset_success FOR TESTING.
    METHODS atomic_final_validates_state FOR TESTING.
    METHODS atomic_final_api_failure FOR TESTING.
    METHODS atomic_final_commit_failure FOR TESTING.
    METHODS atomic_final_simulates FOR TESTING.
    METHODS changes_reservation_item_stock FOR TESTING.
    METHODS rejects_stock_change_scope FOR TESTING.
    METHODS simulates_stock_change FOR TESTING.
    METHODS rolls_back_stock_change_commit FOR TESTING.
    METHODS bulk_stock_change_continues FOR TESTING.
    METHODS atomic_stock_commit_success FOR TESTING.
    METHODS atomic_stock_validate_scope FOR TESTING.
    METHODS atomic_stock_rollback_failure FOR TESTING.
    METHODS atomic_stock_simulates FOR TESTING.
    METHODS atomic_stock_commit_failure FOR TESTING.
    METHODS deletes_project_reservation FOR TESTING.
    METHODS rolls_back_delete_commit FOR TESTING.
    METHODS bulk_delete_continues_failure FOR TESTING.
    METHODS rejects_duplicate_delete_nums FOR TESTING.
    METHODS simulates_delete_without_tx FOR TESTING.
    METHODS atomic_delete_group_success FOR TESTING.
    METHODS atomic_delete_prechecks FOR TESTING.
    METHODS atomic_delete_group_failure FOR TESTING.
    METHODS atomic_resv_delete_simulates FOR TESTING.
    METHODS atomic_resv_delete_commit_fail FOR TESTING.
    METHODS reserves_batch_preview_by_wbs FOR TESTING.
    METHODS reserves_fefo_wbs FOR TESTING.
    METHODS reserves_priority_fefo_wbs FOR TESTING.
    METHODS rejects_prio_fefo_stock_change FOR TESTING.
    METHODS reserves_dated_fefo_wbs FOR TESTING.
    METHODS reserves_dated_fefo_dup FOR TESTING.
    METHODS atomic_dated_fefo_groups FOR TESTING.
    METHODS rejects_bad_dated_fefo_reserve FOR TESTING.
    METHODS reserves_dated_location_wbs FOR TESTING.
    METHODS reserves_dated_location_dup FOR TESTING.
    METHODS rejects_dated_location FOR TESTING.
    METHODS reserves_fefo_demand_shelf FOR TESTING.
    METHODS rejects_fefo_stock_change FOR TESTING.
    METHODS rejects_fefo_expiry_change FOR TESTING.
    METHODS rejects_new_earlier_fefo_batch FOR TESTING.
    METHODS rejects_fefo_shortfall FOR TESTING.
    METHODS reserves_location_wbs FOR TESTING.
    METHODS reserves_wbs_location_prio FOR TESTING.
    METHODS rejects_wbs_location_prio FOR TESTING.
    METHODS rejects_location_stock_change FOR TESTING.
    METHODS rejects_new_priority_location FOR TESTING.
    METHODS rejects_location_shortfall FOR TESTING.
    METHODS reserves_batch_atomic FOR TESTING.
    METHODS atomic_batch_prevalidates FOR TESTING.
    METHODS rejects_expired_batch_preview FOR TESTING.
    METHODS accepts_batch_shelf_boundary FOR TESTING.
    METHODS rejects_short_batch_shelf_life FOR TESTING.
    METHODS rejects_unknown_batch_expiry FOR TESTING.
    METHODS atomic_batch_api_rollback FOR TESTING.
    METHODS atomic_batch_duplicate_number FOR TESTING.
    METHODS atomic_batch_simulates FOR TESTING.
    METHODS atomic_batch_commit_fail FOR TESTING.
    METHODS reserves_location_preview FOR TESTING.
    METHODS reserves_location_atomic FOR TESTING.
    METHODS rejects_short_preview FOR TESTING.
    METHODS rejects_missing_alloc_wbs_date FOR TESTING.
    METHODS rejects_duplicate_items FOR TESTING.
    METHODS simulates_without_transaction FOR TESTING.
    METHODS rolls_back_commit_failure FOR TESTING.
    METHODS rolls_back_create_failure FOR TESTING.
ENDCLASS.

CLASS ltcl_proj_res_service IMPLEMENTATION.
  METHOD setup.
    mo_api = NEW lcl_proj_res_api_double( ).
    mo_api->ms_create_result-reservation_number = '0000001234'.
    mo_api->ms_create_result-is_successful = abap_true.
    mo_api->ms_delete_result-is_successful = abap_true.
    mo_api->ms_delete_items_result-is_successful = abap_true.
    mo_api->ms_change_result-is_successful = abap_true.
    mo_api->ms_change_quantity_result-is_successful = abap_true.
    mo_api->ms_final_issue_result-is_successful = abap_true.
    mo_api->ms_stock_change_result-is_successful = abap_true.
    mo_api->ms_commit_result-is_successful = abap_true.
    mo_stock_repo = NEW lcl_proj_res_repo_double( ).
    mo_uom_repository = NEW lcl_proj_res_uom_repo( ).
    mo_issue_reader = NEW lcl_proj_issue_res_reader( ).
    mo_issue_reader->ms_result-is_successful = abap_true.
    mo_issue_reader->ms_result-items = VALUE #(
      ( reservation_number = '0000001234'
        item_number        = '0001'
        movement_allowed   = abap_true
        material           = 'MAT-1'
        plant              = '1000'
        storage_location   = '0001'
        batch              = 'B-1'
        required_quantity  = '24.000'
        base_unit          = 'EA'
        base_unit_iso      = 'PCE' ) ).
    mo_goods_api = NEW lcl_proj_issue_goods_api( ).
    mo_goods_api->ms_create_result-material_document = '5000000001'.
    mo_goods_api->ms_create_result-fiscal_year = '2026'.
    mo_goods_api->ms_create_result-is_successful = abap_true.
    mo_goods_api->ms_commit_result-is_successful = abap_true.
    DATA(lo_issue_service) = NEW zcl_reservation_issue_service(
      io_reservation_reader = mo_issue_reader
      io_goods_movement_api = mo_goods_api
      io_uom_repository     = mo_uom_repository ).
    mo_cut = NEW zcl_project_resv_service(
      io_api                   = mo_api
      io_project_stock_service = NEW zcl_project_stock_service(
        io_repository     = mo_stock_repo
        io_uom_repository = mo_uom_repository )
      io_issue_service         = lo_issue_service
      io_uom_repository        = mo_uom_repository ).
  ENDMETHOD.

  METHOD issues_reserved_wbs_items.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        storage_location   = '0001'
        batch              = 'B-1'
        unit               = 'EA'
        entry_unit         = 'EA'
        required_quantity  = '24.000'
        withdrawn_quantity = '0.000' ) ).

    DATA(ls_result) = mo_cut->issue_reserved_wbs_items(
      iv_wbs_element        = 'PRJ-100-001'
      iv_reservation_number = '0000001234'
      is_header             = VALUE #(
        posting_date  = '20261014'
        document_date = '20261014' )
      it_items              = VALUE #(
        ( reservation_item = '0001'
          quantity         = '1.000'
          unit             = 'BOX' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_issue_reader->mv_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = '03'
      act = mo_goods_api->mv_gm_code ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001234'
      act = mo_goods_api->mt_items[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = mo_goods_api->mt_items[ 1 ]-reservation_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = mo_goods_api->mt_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = mo_goods_api->mt_items[ 1 ]-entry_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PCE'
      act = mo_goods_api->mt_items[ 1 ]-entry_unit_iso ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = mo_goods_api->mt_items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = mo_goods_api->mt_items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_initial(
      act = mo_goods_api->mt_items[ 1 ]-material ).
    cl_abap_unit_assert=>assert_initial(
      act = mo_goods_api->mt_items[ 1 ]-plant ).
    cl_abap_unit_assert=>assert_initial(
      act = mo_goods_api->mt_items[ 1 ]-movement_type ).
  ENDMETHOD.

  METHOD simulates_reserved_wbs_issue.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '24.000' ) ).

    DATA(ls_result) = mo_cut->issue_reserved_wbs_items(
      iv_wbs_element        = 'PRJ-100-001'
      iv_reservation_number = '0000001234'
      is_header             = VALUE #(
        posting_date  = '20261014'
        document_date = '20261014' )
      it_items              = VALUE #(
        ( reservation_item = '0001'
          quantity         = '2.000'
          unit             = 'EA' ) )
      iv_test_run           = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = mo_goods_api->mv_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->mv_commit_calls ).
  ENDMETHOD.

  METHOD issues_reserved_wbs_bulk.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        storage_location   = '0001'
        batch              = 'B-1'
        unit               = 'EA'
        required_quantity  = '24.000' )
      ( reservation_number = '0000005678'
        reservation_item   = '0002'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-002'
        storage_location   = '0002'
        batch              = 'B-2'
        unit               = 'EA'
        required_quantity  = '24.000' ) ).
    mo_issue_reader->mt_results = VALUE #(
      ( is_successful = abap_true
        items         = VALUE #(
          ( reservation_number = '0000001234'
            item_number        = '0001'
            movement_allowed   = abap_true
            material           = 'MAT-1'
            plant              = '1000'
            storage_location   = '0001'
            batch              = 'B-1'
            required_quantity  = '24.000'
            base_unit          = 'EA'
            base_unit_iso      = 'PCE' ) ) )
      ( is_successful = abap_true
        items         = VALUE #(
          ( reservation_number = '0000005678'
            item_number        = '0002'
            movement_allowed   = abap_true
            material           = 'MAT-1'
            plant              = '1000'
            storage_location   = '0002'
            batch              = 'B-2'
            required_quantity  = '24.000'
            base_unit          = 'EA'
            base_unit_iso      = 'PCE' ) ) ) ).

    DATA(ls_result) = mo_cut->issue_reserved_wbs_items_bulk(
      is_header   = VALUE #(
        posting_date  = '20261014'
        document_date = '20261014' )
      it_requests = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          items              = VALUE #(
            ( reservation_item = '0001'
              quantity         = '1.000'
              unit             = 'BOX' ) ) )
        ( wbs_element        = 'PRJ-100-002'
          reservation_number = '0000005678'
          items              = VALUE #(
            ( reservation_item = '0002'
              quantity         = '2.000'
              unit             = 'EA' ) ) ) ) ).

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
      act = lines( ls_result-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_issue_reader->mv_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_goods_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_goods_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001234'
      act = ls_result-items[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000005678'
      act = ls_result-items[ 2 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_committed ).
  ENDMETHOD.

  METHOD rejects_bulk_wbs_scope.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '24.000' )
      ( reservation_number = '0000005678'
        reservation_item   = '0002'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-OTHER'
        unit               = 'EA'
        required_quantity  = '24.000' ) ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->issue_reserved_wbs_items_bulk(
          is_header   = VALUE #(
            posting_date  = '20261014'
            document_date = '20261014' )
          it_requests = VALUE #(
            ( wbs_element        = 'PRJ-100-001'
              reservation_number = '0000001234'
              items              = VALUE #(
                ( reservation_item = '0001'
                  quantity         = '1.000'
                  unit             = 'EA' ) ) )
            ( wbs_element        = 'PRJ-100-002'
              reservation_number = '0000005678'
              items              = VALUE #(
                ( reservation_item = '0002'
                  quantity         = '1.000'
                  unit             = 'EA' ) ) ) ) ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_issue_reader->mv_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->mv_create_calls ).
  ENDMETHOD.

  METHOD returns_reserved_wbs_items.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        storage_location   = '0001'
        batch              = 'B-1'
        unit               = 'EA'
        required_quantity  = '24.000'
        withdrawn_quantity = '24.000'
        is_final_issue     = abap_true ) ).
    mo_issue_reader->ms_result-items = VALUE #(
      ( reservation_number = '0000001234'
        item_number        = '0001'
        is_final_issue     = abap_true
        movement_allowed   = abap_false
        material           = 'MAT-1'
        plant              = '1000'
        storage_location   = '0001'
        batch              = 'B-1'
        required_quantity  = '24.000'
        withdrawn_quantity = '24.000'
        base_unit          = 'EA'
        base_unit_iso      = 'PCE' ) ).

    DATA(ls_result) = mo_cut->return_reserved_wbs_items(
      iv_wbs_element        = 'PRJ-100-001'
      iv_reservation_number = '0000001234'
      is_header             = VALUE #(
        posting_date  = '20261014'
        document_date = '20261014' )
      it_items              = VALUE #(
        ( reservation_item = '0001'
          quantity         = '1.000'
          unit             = 'BOX' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = '06'
      act = mo_goods_api->mv_gm_code ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = mo_goods_api->mt_items[ 1 ]-is_reversal ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001234'
      act = mo_goods_api->mt_items[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = mo_goods_api->mt_items[ 1 ]-reservation_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = mo_goods_api->mt_items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = mo_goods_api->mt_items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_initial(
      act = mo_goods_api->mt_items[ 1 ]-movement_type ).
  ENDMETHOD.

  METHOD returns_reserved_wbs_bulk.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '24.000'
        withdrawn_quantity = '24.000'
        is_final_issue     = abap_true )
      ( reservation_number = '0000005678'
        reservation_item   = '0002'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-002'
        unit               = 'EA'
        required_quantity  = '24.000'
        withdrawn_quantity = '24.000'
        is_final_issue     = abap_true ) ).
    mo_issue_reader->mt_results = VALUE #(
      ( is_successful = abap_true
        items         = VALUE #(
          ( reservation_number = '0000001234'
            item_number        = '0001'
            is_final_issue     = abap_true
            movement_allowed   = abap_false
            material           = 'MAT-1'
            plant              = '1000'
            required_quantity  = '24.000'
            withdrawn_quantity = '24.000'
            base_unit          = 'EA'
            base_unit_iso      = 'PCE' ) ) )
      ( is_successful = abap_true
        items         = VALUE #(
          ( reservation_number = '0000005678'
            item_number        = '0002'
            is_final_issue     = abap_true
            movement_allowed   = abap_false
            material           = 'MAT-1'
            plant              = '1000'
            required_quantity  = '24.000'
            withdrawn_quantity = '24.000'
            base_unit          = 'EA'
            base_unit_iso      = 'PCE' ) ) ) ).

    DATA(ls_result) = mo_cut->return_reserved_wbs_items_bulk(
      is_header   = VALUE #(
        posting_date  = '20261014'
        document_date = '20261014' )
      it_requests = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          items              = VALUE #(
            ( reservation_item = '0001'
              quantity         = '1.000'
              unit             = 'BOX' ) ) )
        ( wbs_element        = 'PRJ-100-002'
          reservation_number = '0000005678'
          items              = VALUE #(
            ( reservation_item = '0002'
              quantity         = '2.000'
              unit             = 'EA' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_goods_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_goods_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = '06'
      act = mo_goods_api->mv_gm_code ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000005678'
      act = mo_goods_api->mt_items[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = mo_goods_api->mt_items[ 1 ]-is_reversal ).
  ENDMETHOD.

  METHOD commits_reserved_wbs_atomic.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '24.000' )
      ( reservation_number = '0000005678'
        reservation_item   = '0002'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-002'
        unit               = 'EA'
        required_quantity  = '24.000' ) ).
    mo_issue_reader->mt_results = VALUE #(
      ( is_successful = abap_true
        items         = VALUE #(
          ( reservation_number = '0000001234'
            item_number        = '0001'
            movement_allowed   = abap_true
            material           = 'MAT-1'
            plant              = '1000'
            required_quantity  = '24.000'
            base_unit          = 'EA'
            base_unit_iso      = 'PCE' ) ) )
      ( is_successful = abap_true
        items         = VALUE #(
          ( reservation_number = '0000005678'
            item_number        = '0002'
            movement_allowed   = abap_true
            material           = 'MAT-1'
            plant              = '1000'
            required_quantity  = '24.000'
            base_unit          = 'EA'
            base_unit_iso      = 'PCE' ) ) ) ).

    DATA(ls_result) = mo_cut->issue_reserved_wbs_atomic(
      is_header   = VALUE #(
        posting_date  = '20261014'
        document_date = '20261014' )
      it_requests = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          items              = VALUE #(
            ( reservation_item = '0001'
              quantity         = '2.000'
              unit             = 'EA' ) ) )
        ( wbs_element        = 'PRJ-100-002'
          reservation_number = '0000005678'
          items              = VALUE #(
            ( reservation_item = '0002'
              quantity         = '3.000'
              unit             = 'EA' ) ) ) ) ).

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
      act = mo_goods_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->mv_rollback_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_committed ).
  ENDMETHOD.

  METHOD rolls_back_reserved_wbs_atomic.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '24.000' )
      ( reservation_number = '0000005678'
        reservation_item   = '0002'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-002'
        unit               = 'EA'
        required_quantity  = '24.000' ) ).
    mo_issue_reader->mt_results = VALUE #(
      ( is_successful = abap_true
        items         = VALUE #(
          ( reservation_number = '0000001234'
            item_number        = '0001'
            movement_allowed   = abap_true
            material           = 'MAT-1'
            plant              = '1000'
            required_quantity  = '24.000'
            base_unit          = 'EA'
            base_unit_iso      = 'PCE' ) ) )
      ( is_successful = abap_true
        items         = VALUE #(
          ( reservation_number = '0000005678'
            item_number        = '0002'
            movement_allowed   = abap_true
            material           = 'MAT-1'
            plant              = '1000'
            required_quantity  = '24.000'
            base_unit          = 'EA'
            base_unit_iso      = 'PCE' ) ) ) ).
    mo_goods_api->mt_create_results = VALUE #(
      ( material_document = '5000000001'
        fiscal_year       = '2026'
        is_successful     = abap_true )
      ( is_successful = abap_false ) ).

    DATA(ls_result) = mo_cut->issue_reserved_wbs_atomic(
      is_header   = VALUE #(
        posting_date  = '20261014'
        document_date = '20261014' )
      it_requests = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          items              = VALUE #(
            ( reservation_item = '0001'
              quantity         = '2.000'
              unit             = 'EA' ) ) )
        ( wbs_element        = 'PRJ-100-002'
          reservation_number = '0000005678'
          items              = VALUE #(
            ( reservation_item = '0002'
              quantity         = '3.000'
              unit             = 'EA' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->mv_rollback_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 1 ]-movement_result-is_successful ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-items[ 1 ]-movement_result-material_document ).
  ENDMETHOD.

  METHOD fails_resv_atomic_commit.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '24.000' ) ).
    mo_goods_api->ms_commit_result-is_successful = abap_false.

    DATA(ls_result) = mo_cut->issue_reserved_wbs_atomic(
      is_header   = VALUE #(
        posting_date  = '20261014'
        document_date = '20261014' )
      it_requests = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          items              = VALUE #(
            ( reservation_item = '0001'
              quantity         = '2.000'
              unit             = 'EA' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->mv_rollback_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-items[ 1 ]-movement_result-material_document ).
  ENDMETHOD.

  METHOD simulates_resv_atomic.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '24.000' ) ).

    DATA(ls_result) = mo_cut->issue_reserved_wbs_atomic(
      is_header   = VALUE #(
        posting_date  = '20261014'
        document_date = '20261014' )
      it_requests = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          items              = VALUE #(
            ( reservation_item = '0001'
              quantity         = '2.000'
              unit             = 'EA' ) ) ) )
      iv_test_run = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = mo_goods_api->mv_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD returns_reserved_wbs_atomic.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        storage_location   = '0001'
        batch              = 'B-1'
        unit               = 'EA'
        required_quantity  = '24.000'
        withdrawn_quantity = '24.000'
        is_final_issue     = abap_true ) ).
    mo_issue_reader->ms_result-items = VALUE #(
      ( reservation_number = '0000001234'
        item_number        = '0001'
        is_final_issue     = abap_true
        movement_allowed   = abap_false
        material           = 'MAT-1'
        plant              = '1000'
        storage_location   = '0001'
        batch              = 'B-1'
        required_quantity  = '24.000'
        withdrawn_quantity = '24.000'
        base_unit          = 'EA'
        base_unit_iso      = 'PCE' ) ).

    DATA(ls_result) = mo_cut->return_reserved_wbs_atomic(
      is_header   = VALUE #(
        posting_date  = '20261014'
        document_date = '20261014' )
      it_requests = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          items              = VALUE #(
            ( reservation_item = '0001'
              quantity         = '1.000'
              unit             = 'BOX' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '06'
      act = mo_goods_api->mv_gm_code ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = mo_goods_api->mt_items[ 1 ]-is_reversal ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_goods_api->mv_commit_calls ).
  ENDMETHOD.

  METHOD rejects_wrong_wbs_issue.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-OTHER'
        unit               = 'EA'
        required_quantity  = '24.000' ) ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->issue_reserved_wbs_items(
          iv_wbs_element        = 'PRJ-100-001'
          iv_reservation_number = '0000001234'
          is_header             = VALUE #(
            posting_date  = '20261014'
            document_date = '20261014' )
          it_items              = VALUE #(
            ( reservation_item = '0001'
              quantity         = '2.000'
              unit             = 'EA' ) ) ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_issue_reader->mv_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_goods_api->mv_create_calls ).
  ENDMETHOD.

  METHOD batch_preview.
    rs_result = VALUE #(
      allocation      = VALUE #(
        allocations       = VALUE #(
          ( allocation                = VALUE #(
              request_id         = 'REQ-1'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '2.000'
              available_quantity = '2.000'
              allocated_quantity = '2.000'
              shortfall_quantity = '0.000' )
            source_quantity           = '2.000'
            source_unit               = 'EA'
            base_quantity             = '2.000'
            base_unit                 = 'EA'
            allocated_source_quantity = '2.000' )
          ( allocation                = VALUE #(
              request_id         = 'REQ-2'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '3.000'
              available_quantity = '3.000'
              allocated_quantity = '3.000'
              shortfall_quantity = '0.000' )
            source_quantity           = '3.000'
            source_unit               = 'EA'
            base_quantity             = '3.000'
            base_unit                 = 'EA'
            allocated_source_quantity = '3.000' ) )
        batch_allocations = VALUE #(
          ( batch_allocation          = VALUE #(
              request_id         = 'REQ-1'
              material           = 'MAT-1'
              plant              = '1000'
              storage_location   = '0001'
              batch              = 'B-1'
              allocated_quantity = '2.000' )
            base_unit                 = 'EA'
            source_unit               = 'EA'
            allocated_source_quantity = '2.000' )
          ( batch_allocation          = VALUE #(
              request_id         = 'REQ-2'
              material           = 'MAT-1'
              plant              = '1000'
              storage_location   = '0002'
              batch              = 'B-2'
              allocated_quantity = '3.000' )
            base_unit                 = 'EA'
            source_unit               = 'EA'
            allocated_source_quantity = '3.000' ) ) )
      wbs_assignments = VALUE #(
        ( request_id = 'REQ-1' wbs_element = 'PRJ-1' )
        ( request_id = 'REQ-2' wbs_element = 'PRJ-2' ) ) ).
  ENDMETHOD.

  METHOD location_preview.
    rs_result = VALUE #(
      allocation      = VALUE #(
        allocations         = VALUE #(
          ( allocation                = VALUE #(
              request_id         = 'REQ-LOC-1'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '2.000'
              available_quantity = '2.000'
              allocated_quantity = '2.000'
              shortfall_quantity = '0.000' )
            source_quantity           = '2.000'
            source_unit               = 'EA'
            base_quantity             = '2.000'
            base_unit                 = 'EA'
            allocated_source_quantity = '2.000' )
          ( allocation                = VALUE #(
              request_id         = 'REQ-LOC-2'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '3.000'
              available_quantity = '3.000'
              allocated_quantity = '3.000'
              shortfall_quantity = '0.000' )
            source_quantity           = '3.000'
            source_unit               = 'EA'
            base_quantity             = '3.000'
            base_unit                 = 'EA'
            allocated_source_quantity = '3.000' ) )
        storage_allocations = VALUE #(
          ( storage_allocation        = VALUE #(
              request_id         = 'REQ-LOC-1'
              material           = 'MAT-1'
              plant              = '1000'
              storage_location   = '0001'
              allocated_quantity = '2.000' )
            base_unit                 = 'EA'
            source_unit               = 'EA'
            allocated_source_quantity = '2.000' )
          ( storage_allocation        = VALUE #(
              request_id         = 'REQ-LOC-2'
              material           = 'MAT-1'
              plant              = '1000'
              storage_location   = '0002'
              allocated_quantity = '3.000' )
            base_unit                 = 'EA'
            source_unit               = 'EA'
            allocated_source_quantity = '3.000' ) ) )
      wbs_assignments = VALUE #(
        ( request_id = 'REQ-LOC-1' wbs_element = 'PRJ-LOC-1' )
        ( request_id = 'REQ-LOC-2' wbs_element = 'PRJ-LOC-2' ) ) ).
  ENDMETHOD.

  METHOD creates_project_reservation.
    DATA(ls_result) = mo_cut->reserve_for_wbs(
      is_request = VALUE #(
        wbs_element   = 'PRJ-100-001'
        required_date = '20261020'
        items         = VALUE #(
          ( material         = 'MAT-1'
            plant            = '1000'
            storage_location = '0001'
            batch            = 'B-1'
            quantity         = '2.000'
            unit             = 'BOX' )
          ( material         = 'MAT-1'
            plant            = '1000'
            storage_location = '0002'
            quantity         = '3.000'
            unit             = 'EA' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001234'
      act = ls_result-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-100-001'
      act = mo_api->ms_request-wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261020'
      act = mo_api->ms_request-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '24.000' )
      act = mo_api->ms_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = mo_api->ms_request-items[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD reserves_wbs_bulk.
    mo_api->mt_create_results = VALUE #(
      ( reservation_number = '0000001234'
        is_successful      = abap_true )
      ( reservation_number = '0000005678'
        is_successful      = abap_true ) ).

    DATA(ls_result) = mo_cut->reserve_wbs_bulk(
      it_requests = VALUE #(
        ( wbs_element   = 'PRJ-100-001'
          required_date = '20261020'
          items         = VALUE #(
            ( material = 'MAT-1'
              plant    = '1000'
              quantity = '2.000'
              unit     = 'BOX' ) ) )
        ( wbs_element   = 'PRJ-100-002'
          required_date = '20261021'
          items         = VALUE #(
            ( material         = 'MAT-1'
              plant            = '1000'
              storage_location = '0002'
              quantity         = '3.000'
              unit             = 'EA' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '24.000' )
      act = mo_api->mt_requests[ 1 ]-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = mo_api->mt_requests[ 1 ]-items[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000005678'
      act = ls_result-reservations[ 2 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-reservations[ 1 ]-is_committed ).
  ENDMETHOD.

  METHOD rejects_wbs_bulk_before_write.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->reserve_wbs_bulk(
          it_requests = VALUE #(
            ( wbs_element   = 'PRJ-100-001'
              required_date = '20261020'
              items         = VALUE #(
                ( material = 'MAT-1'
                  plant    = '1000'
                  quantity = '1.000'
                  unit     = 'EA' ) ) )
            ( wbs_element   = 'PRJ-100-002'
              required_date = '20261021'
              items         = VALUE #(
                ( material = 'MAT-1'
                  plant    = '1000'
                  quantity = '1.000'
                  unit     = 'PAL' ) ) ) ) ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
  ENDMETHOD.

  METHOD continues_wbs_bulk_failure.
    mo_api->mt_create_results = VALUE #(
      ( is_successful = abap_false
        messages      = VALUE #(
          ( type = 'E' message = 'First WBS reservation failed' ) ) )
      ( reservation_number = '0000005678'
        is_successful      = abap_true ) ).

    DATA(ls_result) = mo_cut->reserve_wbs_bulk(
      it_requests = VALUE #(
        ( wbs_element   = 'PRJ-100-001'
          required_date = '20261020'
          items         = VALUE #(
            ( material = 'MAT-1'
              plant    = '1000'
              quantity = '1.000'
              unit     = 'EA' ) ) )
        ( wbs_element   = 'PRJ-100-002'
          required_date = '20261021'
          items         = VALUE #(
            ( material = 'MAT-1'
              plant    = '1000'
              quantity = '2.000'
              unit     = 'EA' ) ) ) ) ).

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
      exp = 2
      act = mo_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-reservations[ 2 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-reservations[ 1 ]-was_rolled_back ).
  ENDMETHOD.

  METHOD reserves_wbs_bulk_atomic.
    mo_api->mt_create_results = VALUE #(
      ( reservation_number = '0000001234'
        is_successful      = abap_true )
      ( reservation_number = '0000005678'
        is_successful      = abap_true ) ).

    DATA(ls_result) = mo_cut->reserve_wbs_bulk(
      it_requests = VALUE #(
        ( wbs_element   = 'PRJ-100-001'
          required_date = '20261020'
          items         = VALUE #(
            ( material = 'MAT-1'
              plant    = '1000'
              quantity = '1.000'
              unit     = 'EA' ) ) )
        ( wbs_element   = 'PRJ-100-002'
          required_date = '20261021'
          items         = VALUE #(
            ( material = 'MAT-1'
              plant    = '1000'
              quantity = '2.000'
              unit     = 'EA' ) ) ) )
      iv_atomic   = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_rollback_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-reservations[ 2 ]-is_committed ).
  ENDMETHOD.

  METHOD rolls_back_wbs_bulk_atomic.
    mo_api->mt_create_results = VALUE #(
      ( reservation_number = '0000001234'
        is_successful      = abap_true )
      ( is_successful = abap_false
        messages      = VALUE #(
          ( type = 'E' message = 'Reservation create failed' ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_wbs_bulk(
      it_requests = VALUE #(
        ( wbs_element   = 'PRJ-100-001'
          required_date = '20261020'
          items         = VALUE #(
            ( material = 'MAT-1'
              plant    = '1000'
              quantity = '1.000'
              unit     = 'EA' ) ) )
        ( wbs_element   = 'PRJ-100-002'
          required_date = '20261021'
          items         = VALUE #(
            ( material = 'MAT-1'
              plant    = '1000'
              quantity = '2.000'
              unit     = 'EA' ) ) ) )
      iv_atomic   = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_rollback_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-reservations[ 1 ]-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = space
      act = ls_result-reservations[ 1 ]-reservation_number ).
  ENDMETHOD.

  METHOD fails_wbs_bulk_commit.
    mo_api->mt_create_results = VALUE #(
      ( reservation_number = '0000001234'
        is_successful      = abap_true )
      ( reservation_number = '0000005678'
        is_successful      = abap_true ) ).
    mo_api->ms_commit_result-is_successful = abap_false.

    DATA(ls_result) = mo_cut->reserve_wbs_bulk(
      it_requests = VALUE #(
        ( wbs_element   = 'PRJ-100-001'
          required_date = '20261020'
          items         = VALUE #(
            ( material = 'MAT-1'
              plant    = '1000'
              quantity = '1.000'
              unit     = 'EA' ) ) )
        ( wbs_element   = 'PRJ-100-002'
          required_date = '20261021'
          items         = VALUE #(
            ( material = 'MAT-1'
              plant    = '1000'
              quantity = '2.000'
              unit     = 'EA' ) ) ) )
      iv_atomic   = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_rollback_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-messages ) ).
  ENDMETHOD.

  METHOD simulates_wbs_bulk_no_luw.
    DATA(ls_result) = mo_cut->reserve_wbs_bulk(
      it_requests = VALUE #(
        ( wbs_element   = 'PRJ-100-001'
          required_date = '20261020'
          items         = VALUE #(
            ( material = 'MAT-1'
              plant    = '1000'
              quantity = '1.000'
              unit     = 'EA' ) ) )
        ( wbs_element   = 'PRJ-100-002'
          required_date = '20261021'
          items         = VALUE #(
            ( material = 'MAT-1'
              plant    = '1000'
              quantity = '2.000'
              unit     = 'EA' ) ) ) )
      iv_test_run = abap_true
      iv_atomic   = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_rollback_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = mo_api->mv_test_run ).
  ENDMETHOD.

  METHOD accepts_valid_leap_day.
    DATA(ls_result) = mo_cut->reserve_for_wbs(
      is_request = VALUE #(
        wbs_element   = 'PRJ-100-001'
        required_date = '20240229'
        items         = VALUE #(
          ( material = 'MAT-1'
            plant    = '1000'
            quantity = '1.000'
            unit     = 'EA' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20240229'
      act = mo_api->ms_request-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_create_calls ).
  ENDMETHOD.

  METHOD rejects_invalid_required_date.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->reserve_for_wbs(
          is_request = VALUE #(
            wbs_element   = 'PRJ-100-001'
            required_date = '20260230'
            items         = VALUE #(
              ( material = 'MAT-1'
                plant    = '1000'
                quantity = '1.000'
                unit     = 'EA' ) ) ) ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
  ENDMETHOD.

  METHOD rejects_non_numeric_date.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->reserve_for_wbs(
          is_request = VALUE #(
            wbs_element   = 'PRJ-100-001'
            required_date = '2026ABCD'
            items         = VALUE #(
              ( material = 'MAT-1'
                plant    = '1000'
                quantity = '1.000'
                unit     = 'EA' ) ) ) ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_create_calls ).
  ENDMETHOD.

  METHOD rejects_invalid_alloc_date.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->reserve_batch_allocation(
          is_allocation    = batch_preview( )
          iv_required_date = '20261301' ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
  ENDMETHOD.

  METHOD deletes_wbs_reservation_items.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000'
        withdrawn_quantity = '1.000' ) ).

    DATA(ls_result) = mo_cut->delete_reservation_items(
      iv_wbs_element        = 'PRJ-100-001'
      iv_reservation_number = '0000001234'
      it_item_numbers       = VALUE #( ( '0001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_deleted ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001234'
      act = mo_api->mv_deleted_item_reservation ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = mo_api->mt_deleted_item_numbers[ 1 ] ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_delete_items_calls ).
  ENDMETHOD.

  METHOD validates_wbs_item_scope.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-OTHER'
        unit               = 'EA'
        required_quantity  = '5.000' ) ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->delete_reservation_items(
          iv_wbs_element        = 'PRJ-100-001'
          iv_reservation_number = '0000001234'
          it_item_numbers       = VALUE #( ( '0001' ) ) ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_delete_items_calls ).
  ENDMETHOD.

  METHOD rolls_back_item_commit.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' ) ).
    mo_api->ms_commit_result-is_successful = abap_false.
    mo_api->ms_commit_result-message = VALUE #(
      type    = 'E'
      message = 'Commit failed' ).

    DATA(ls_result) = mo_cut->delete_reservation_items(
      iv_wbs_element        = 'PRJ-100-001'
      iv_reservation_number = '0000001234'
      it_item_numbers       = VALUE #( ( '0001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_deleted ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD simulates_wbs_item_delete.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' ) ).

    DATA(ls_result) = mo_cut->delete_reservation_items(
      iv_wbs_element        = 'PRJ-100-001'
      iv_reservation_number = '0000001234'
      it_item_numbers       = VALUE #( ( '0001' ) )
      iv_test_run           = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_deleted ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_delete_items_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
  ENDMETHOD.

  METHOD bulk_item_delete_continues.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' )
      ( reservation_number = '0000005678'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-200-001'
        unit               = 'EA'
        required_quantity  = '3.000' ) ).
    mo_api->mt_delete_items_results = VALUE #(
      ( is_successful = abap_false
        messages      = VALUE #(
          ( type = 'E' message = 'Item cannot be deleted' ) ) )
      ( is_successful = abap_true ) ).

    DATA(ls_result) = mo_cut->delete_reservation_items_bulk(
      it_requests = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          item_numbers       = VALUE #( ( '0001' ) ) )
        ( wbs_element        = 'PRJ-200-001'
          reservation_number = '0000005678'
          item_numbers       = VALUE #( ( '0001' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->mv_delete_items_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_committed ).
  ENDMETHOD.

  METHOD atomic_delete_commits.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' )
      ( reservation_number = '0000005678'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-200-001'
        unit               = 'EA'
        required_quantity  = '3.000' ) ).

    DATA(ls_result) = mo_cut->delete_resv_items_atomic(
      it_requests = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          item_numbers       = VALUE #( ( '0001' ) ) )
        ( wbs_element        = 'PRJ-200-001'
          reservation_number = '0000005678'
          item_numbers       = VALUE #( ( '0001' ) ) ) ) ).

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
      act = mo_api->mv_delete_items_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_rollback_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-is_deleted ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_committed ).
  ENDMETHOD.

  METHOD atomic_delete_scope.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' )
      ( reservation_number = '0000005678'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-200-001'
        unit               = 'EA'
        required_quantity  = '3.000' ) ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->delete_resv_items_atomic(
          it_requests = VALUE #(
            ( wbs_element        = 'PRJ-100-001'
              reservation_number = '0000001234'
              item_numbers       = VALUE #( ( '0001' ) ) )
            ( wbs_element        = 'PRJ-200-001'
              reservation_number = '0000005678'
              item_numbers       = VALUE #( ( '0002' ) ) ) ) ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_delete_items_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD atomic_delete_api_failure.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' )
      ( reservation_number = '0000005678'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-200-001'
        unit               = 'EA'
        required_quantity  = '3.000' ) ).
    mo_api->mt_delete_items_results = VALUE #(
      ( is_successful = abap_true )
      ( is_successful = abap_false
        messages      = VALUE #(
          ( type = 'E' message = 'Item deletion failed' ) ) ) ).

    DATA(ls_result) = mo_cut->delete_resv_items_atomic(
      it_requests = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          item_numbers       = VALUE #( ( '0001' ) ) )
        ( wbs_element        = 'PRJ-200-001'
          reservation_number = '0000005678'
          item_numbers       = VALUE #( ( '0001' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->mv_delete_items_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_rollback_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 1 ]-is_deleted ).
  ENDMETHOD.

  METHOD atomic_delete_simulates.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' ) ).

    DATA(ls_result) = mo_cut->delete_resv_items_atomic(
      it_requests = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          item_numbers       = VALUE #( ( '0001' ) ) ) )
      iv_test_run = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_delete_items_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD atomic_delete_commit_failure.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' ) ).
    mo_api->ms_commit_result-is_successful = abap_false.

    DATA(ls_result) = mo_cut->delete_resv_items_atomic(
      it_requests = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          item_numbers       = VALUE #( ( '0001' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_not_initial(
      act = ls_result-messages ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD atomic_delete_group_success.
    DATA(ls_result) = mo_cut->delete_reservations_atomic(
      it_reservation_numbers = VALUE #(
        ( '0000001234' )
        ( '0000005678' ) ) ).

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
      act = mo_api->mv_delete_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_rollback_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-is_deleted ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_committed ).
  ENDMETHOD.

  METHOD atomic_delete_prechecks.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->delete_reservations_atomic(
          it_reservation_numbers = VALUE #(
            ( '0000001234' )
            ( '0000001234' ) ) ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_delete_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD atomic_delete_group_failure.
    mo_api->mt_delete_results = VALUE #(
      ( is_successful = abap_true )
      ( is_successful = abap_false
        messages      = VALUE #(
          ( type = 'E' message = 'Reservation is in use' ) ) ) ).

    DATA(ls_result) = mo_cut->delete_reservations_atomic(
      it_reservation_numbers = VALUE #(
        ( '0000001234' )
        ( '0000005678' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->mv_delete_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_rollback_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 1 ]-is_deleted ).
  ENDMETHOD.

  METHOD atomic_resv_delete_simulates.
    DATA(ls_result) = mo_cut->delete_reservations_atomic(
      it_reservation_numbers = VALUE #(
        ( '0000001234' )
        ( '0000005678' ) )
      iv_test_run            = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->mv_delete_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = mo_api->mv_delete_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_rollback_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 1 ]-is_deleted ).
  ENDMETHOD.

  METHOD atomic_resv_delete_commit_fail.
    mo_api->ms_commit_result-is_successful = abap_false.

    DATA(ls_result) = mo_cut->delete_reservations_atomic(
      it_reservation_numbers = VALUE #( ( '0000001234' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_not_initial(
      act = ls_result-messages ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD deletes_project_reservation.
    DATA(ls_result) = mo_cut->delete_reservation(
      iv_reservation_number = '0000001234' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_deleted ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001234'
      act = mo_api->mt_deleted_numbers[ 1 ] ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD rolls_back_delete_commit.
    mo_api->ms_commit_result-is_successful = abap_false.
    mo_api->ms_commit_result-message = VALUE #(
      type    = 'E'
      message = 'Commit failed' ).

    DATA(ls_result) = mo_cut->delete_reservation(
      iv_reservation_number = '0000001234' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_deleted ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD bulk_delete_continues_failure.
    mo_api->mt_delete_results = VALUE #(
      ( is_successful = abap_false
        messages      = VALUE #(
          ( type = 'E' message = 'Reservation is in use' ) ) )
      ( is_successful = abap_true ) ).

    DATA(ls_result) = mo_cut->delete_reservations_bulk(
      it_reservation_numbers = VALUE #(
        ( '0000001234' )
        ( '0000005678' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->mv_delete_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_rollback_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
  ENDMETHOD.

  METHOD rejects_duplicate_delete_nums.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->delete_reservations_bulk(
          it_reservation_numbers = VALUE #(
            ( '0000001234' )
            ( '0000001234' ) ) ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_delete_calls ).
  ENDMETHOD.

  METHOD simulates_delete_without_tx.
    DATA(ls_result) = mo_cut->delete_reservation(
      iv_reservation_number = '0000001234'
      iv_test_run           = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_deleted ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = mo_api->mv_delete_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD reserves_batch_preview_by_wbs.
    DATA(ls_result) = mo_cut->reserve_batch_allocation(
      is_allocation         = VALUE #(
        allocation      = VALUE #(
          allocations       = VALUE #(
            ( allocation                = VALUE #(
                request_id         = 'REQ-1'
                material           = 'MAT-1'
                plant              = '1000'
                requested_quantity = '5.000'
                available_quantity = '8.000'
                allocated_quantity = '5.000'
                shortfall_quantity = '0.000' )
              source_quantity           = '5.000'
              source_unit               = 'EA'
              base_quantity             = '5.000'
              base_unit                 = 'EA'
              allocated_source_quantity = '5.000' )
            ( allocation                = VALUE #(
                request_id         = 'REQ-2'
                material           = 'MAT-1'
                plant              = '1000'
                requested_quantity = '4.000'
                available_quantity = '4.000'
                allocated_quantity = '4.000'
                shortfall_quantity = '0.000' )
              source_quantity           = '4.000'
              source_unit               = 'EA'
              base_quantity             = '4.000'
              base_unit                 = 'EA'
              allocated_source_quantity = '4.000' ) )
          batch_allocations = VALUE #(
            ( batch_allocation          = VALUE #(
                request_id         = 'REQ-1'
                material           = 'MAT-1'
                plant              = '1000'
                storage_location   = '0001'
                batch              = 'B-1'
                allocated_quantity = '2.000' )
              base_unit                 = 'EA'
              source_unit               = 'EA'
              allocated_source_quantity = '2.000' )
            ( batch_allocation          = VALUE #(
                request_id         = 'REQ-1'
                material           = 'MAT-1'
                plant              = '1000'
                storage_location   = '0001'
                batch              = 'B-1'
                allocated_quantity = '3.000' )
              base_unit                 = 'EA'
              source_unit               = 'EA'
              allocated_source_quantity = '3.000' )
            ( batch_allocation          = VALUE #(
                request_id         = 'REQ-2'
                material           = 'MAT-1'
                plant              = '1000'
                storage_location   = '0002'
                batch              = 'B-2'
                allocated_quantity = '4.000' )
              base_unit                 = 'EA'
              source_unit               = 'EA'
              allocated_source_quantity = '4.000' ) ) )
        wbs_assignments = VALUE #(
          ( request_id = 'REQ-1' wbs_element = 'PRJ-1' )
          ( request_id = 'REQ-2' wbs_element = 'PRJ-2' ) ) )
      it_wbs_required_dates = VALUE #(
        ( wbs_element = 'PRJ-1' required_date = '20261201' )
        ( wbs_element = 'PRJ-2' required_date = '20261215' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-1'
      act = mo_api->mt_requests[ 1 ]-wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = mo_api->mt_requests[ 1 ]-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = mo_api->mt_requests[ 1 ]-items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-2'
      act = mo_api->mt_requests[ 2 ]-wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261201'
      act = mo_api->mt_requests[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261215'
      act = mo_api->mt_requests[ 2 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261215'
      act = ls_result-reservations[ 2 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-successful_count ).
  ENDMETHOD.

  METHOD reserves_fefo_wbs.
    mo_stock_repo->mt_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0001'
        batch                 = 'B-1'
        expiration_date       = '20261130'
        unrestricted_quantity = '3.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0001'
        batch                 = 'B-2'
        expiration_date       = '20261210'
        unrestricted_quantity = '4.000' ) ).

    DATA(ls_result) = mo_cut->reserve_wbs_fefo(
      it_demands                 = VALUE #(
        ( request_id         = 'REQ-1'
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '4.000'
          unit               = 'EA' ) )
      it_wbs_required_dates      = VALUE #(
        ( wbs_element = 'PRJ-1' required_date = '20261201' ) )
      iv_as_of_date              = '20261014'
      iv_minimum_shelf_life_days = 2 ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-preview-allocation-allocations[
        1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-preview-allocation-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-reservation-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001234'
      act = ls_result-reservation-reservations[
        1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261201'
      act = mo_api->mt_requests[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-2'
      act = mo_api->mt_requests[ 1 ]-items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = mo_api->mt_requests[ 1 ]-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261201'
      act = ls_result-preview-allocation-batch_allocations[
        1 ]-batch_allocation-as_of_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
  ENDMETHOD.

  METHOD reserves_priority_fefo_wbs.
    mo_stock_repo->mt_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0001'
        batch                 = 'B-SOON'
        expiration_date       = '20261210'
        unrestricted_quantity = '10.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0001'
        batch                 = 'B-LATER'
        expiration_date       = '20261220'
        unrestricted_quantity = '15.000' ) ).

    DATA(ls_result) = mo_cut->reserve_wbs_fefo_priority(
      it_demands               = VALUE #(
        ( request_id         = 'REQ-DUP'
          priority           = 1
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '12.000'
          unit               = 'EA' )
        ( request_id         = 'REQ-DUP'
          priority           = 10
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '15.000'
          unit               = 'EA' )
        ( request_id         = 'REQ-3'
          priority           = 10
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '10.000'
          unit               = 'EA' ) )
      iv_required_date         = '20261015'
      iv_as_of_date            = '20261014'
      iv_require_full_quantity = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-preview-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-DUP'
      act = ls_result-preview-allocations[
        1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-DUP'
      act = ls_result-preview-allocations[
        2 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = ls_result-preview-allocations[
        1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '15.000' )
      act = ls_result-preview-allocations[
        2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_result-preview-allocations[
        3 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-preview-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SOON'
      act = ls_result-preview-batch_allocations[
        1 ]-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = ls_result-preview-batch_allocations[
        2 ]-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-reservation-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( mo_api->mt_requests[ 1 ]-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '15.000' )
      act = mo_api->mt_requests[ 1 ]-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATER'
      act = mo_api->mt_requests[ 1 ]-items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = mo_api->mt_requests[ 1 ]-items[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-SOON'
      act = mo_api->mt_requests[ 1 ]-items[ 2 ]-batch ).
  ENDMETHOD.

  METHOD rejects_prio_fefo_stock_change.
    mo_stock_repo->mt_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0001'
        batch                 = 'B-LATE'
        expiration_date       = '20261210'
        unrestricted_quantity = '4.000' ) ).
    mo_stock_repo->mt_recheck_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0001'
        batch                 = 'B-EARLY'
        expiration_date       = '20261205'
        unrestricted_quantity = '4.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0001'
        batch                 = 'B-LATE'
        expiration_date       = '20261210'
        unrestricted_quantity = '4.000' ) ).
    mo_stock_repo->mv_use_recheck_snapshot = abap_true.

    DATA(ls_result) = mo_cut->reserve_wbs_fefo_priority(
      it_demands       = VALUE #(
        ( request_id         = 'REQ-1'
          priority           = 5
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '4.000'
          unit               = 'EA' ) )
      iv_required_date = '20261201'
      iv_as_of_date    = '20261014' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATE'
      act = ls_result-preview-batch_allocations[
        1 ]-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-reservation-is_successful ).
    cl_abap_unit_assert=>assert_not_initial(
      act = ls_result-reservation-messages ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_stock_repo->mv_stock_read_calls ).
  ENDMETHOD.

  METHOD reserves_dated_fefo_wbs.
    mo_stock_repo->mt_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0001'
        batch                 = 'B-1'
        expiration_date       = '20261210'
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0001'
        batch                 = 'B-2'
        expiration_date       = '20261211'
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0001'
        batch                 = 'B-3'
        expiration_date       = '20261212'
        unrestricted_quantity = '1.000' ) ).

    DATA(ls_result) = mo_cut->reserve_wbs_fefo_by_date(
      it_demands    = VALUE #(
        ( request_id         = 'REQ-LATE'
          required_date      = '20261205'
          priority           = 99
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'REQ-EARLY-LOW'
          required_date      = '20261201'
          priority           = 1
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'REQ-EARLY-HIGH'
          required_date      = '20261201'
          priority           = 5
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' ) )
      iv_as_of_date = '20261001' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-preview-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-LATE'
      act = ls_result-preview-allocations[
        1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-3'
      act = ls_result-preview-batch_allocations[
        1 ]-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-2'
      act = ls_result-preview-batch_allocations[
        2 ]-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = ls_result-preview-batch_allocations[
        3 ]-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-reservation-reservations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261201'
      act = mo_api->mt_requests[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( mo_api->mt_requests[ 1 ]-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261205'
      act = mo_api->mt_requests[ 2 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-3'
      act = mo_api->mt_requests[ 2 ]-items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-reservation-is_successful ).
  ENDMETHOD.

  METHOD reserves_dated_fefo_dup.
    mo_stock_repo->mt_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0001'
        batch                 = 'B-EARLY'
        expiration_date       = '20261210'
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0001'
        batch                 = 'B-LATE'
        expiration_date       = '20261220'
        unrestricted_quantity = '1.000' ) ).

    DATA(ls_result) = mo_cut->reserve_wbs_fefo_by_date(
      it_demands    = VALUE #(
        ( request_id         = 'REQ-DUP'
          required_date      = '20261205'
          priority           = 1
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'REQ-DUP'
          required_date      = '20261201'
          priority           = 1
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' ) )
      iv_as_of_date = '20261001' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-preview-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-DUP'
      act = ls_result-preview-allocations[
        1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261205'
      act = ls_result-preview-allocations[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-DUP'
      act = ls_result-preview-allocations[
        2 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261201'
      act = ls_result-preview-allocations[ 2 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATE'
      act = ls_result-preview-batch_allocations[
        1 ]-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLY'
      act = ls_result-preview-batch_allocations[
        2 ]-split-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-reservation-reservations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261201'
      act = mo_api->mt_requests[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLY'
      act = mo_api->mt_requests[ 1 ]-items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261205'
      act = mo_api->mt_requests[ 2 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATE'
      act = mo_api->mt_requests[ 2 ]-items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-reservation-is_successful ).
  ENDMETHOD.

  METHOD atomic_dated_fefo_groups.
    mo_stock_repo->mt_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0001'
        batch                 = 'B-1'
        expiration_date       = '20261210'
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0001'
        batch                 = 'B-2'
        expiration_date       = '20261211'
        unrestricted_quantity = '1.000' ) ).
    mo_api->mt_create_results = VALUE #(
      ( reservation_number = '0000001001' is_successful = abap_true )
      ( reservation_number = '0000001002' is_successful = abap_true ) ).

    DATA(ls_result) = mo_cut->reserve_wbs_fefo_by_date(
      it_demands    = VALUE #(
        ( request_id         = 'REQ-LATE'
          required_date      = '20261205'
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'REQ-EARLY'
          required_date      = '20261201'
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' ) )
      iv_as_of_date = '20261001'
      iv_atomic     = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-reservation-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-reservation-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD rejects_bad_dated_fefo_reserve.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->reserve_wbs_fefo_by_date(
          it_demands = VALUE #(
            ( request_id         = 'REQ-BAD-DATE'
              required_date      = '20260230'
              wbs_element        = 'PRJ-1'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_create_calls ).
  ENDMETHOD.

  METHOD reserves_dated_location_wbs.
    mo_stock_repo->mt_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0001'
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0002'
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0003'
        unrestricted_quantity = '1.000' ) ).

    DATA(ls_result) = mo_cut->reserve_wbs_by_location_date(
      it_demands = VALUE #(
        ( request_id         = 'LOC-LATE'
          required_date      = '20261205'
          priority           = 99
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'LOC-EARLY-LOW'
          required_date      = '20261201'
          priority           = 1
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'LOC-EARLY-HIGH'
          required_date      = '20261201'
          priority           = 5
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = ls_result-preview-storage_allocations[
        1 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-reservation-reservations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261201'
      act = mo_api->mt_requests[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( mo_api->mt_requests[ 1 ]-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261205'
      act = mo_api->mt_requests[ 2 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = mo_api->mt_requests[ 2 ]-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-reservation-is_successful ).
  ENDMETHOD.

  METHOD reserves_dated_location_dup.
    mo_stock_repo->mt_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0001'
        unrestricted_quantity = '1.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0002'
        unrestricted_quantity = '1.000' ) ).

    DATA(ls_result) = mo_cut->reserve_wbs_by_location_date(
      it_demands               = VALUE #(
        ( request_id         = 'REQ-DUP'
          required_date      = '20261205'
          priority           = 1
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' )
        ( request_id         = 'REQ-DUP'
          required_date      = '20261201'
          priority           = 1
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' ) )
      iv_require_full_quantity = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-preview-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-DUP'
      act = ls_result-preview-allocations[
        1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-DUP'
      act = ls_result-preview-allocations[
        2 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261205'
      act = ls_result-preview-allocations[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261201'
      act = ls_result-preview-allocations[ 2 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-preview-storage_allocations[
        1 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-preview-storage_allocations[
        2 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-reservation-reservations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261201'
      act = mo_api->mt_requests[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = mo_api->mt_requests[ 1 ]-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261205'
      act = mo_api->mt_requests[ 2 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = mo_api->mt_requests[ 2 ]-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-reservation-is_successful ).
  ENDMETHOD.

  METHOD rejects_dated_location.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->reserve_wbs_by_location_date(
          it_demands = VALUE #(
            ( request_id         = 'LOC-BAD-DATE'
              required_date      = '20260230'
              wbs_element        = 'PRJ-1'
              material           = 'MAT-1'
              plant              = '1000'
              requested_quantity = '1.000'
              unit               = 'EA' ) ) ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_stock_repo->mv_stock_read_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_create_calls ).
  ENDMETHOD.

  METHOD reserves_fefo_demand_shelf.
    mo_stock_repo->mt_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0001'
        batch                 = 'B-SHORT'
        expiration_date       = '20261115'
        unrestricted_quantity = '2.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0002'
        batch                 = 'B-LONG'
        expiration_date       = '20261230'
        unrestricted_quantity = '2.000' ) ).

    DATA(ls_result) = mo_cut->reserve_wbs_fefo(
      it_demands            = VALUE #(
        ( request_id              = 'REQ-WBS-SHELF'
          wbs_element             = 'PRJ-1'
          material                = 'MAT-1'
          plant                   = '1000'
          requested_quantity      = '2.000'
          unit                    = 'EA'
          minimum_shelf_life_days = 30 ) )
      it_wbs_required_dates = VALUE #(
        ( wbs_element = 'PRJ-1' required_date = '20261101' ) )
      iv_as_of_date         = '20261014' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LONG'
      act = ls_result-preview-allocation-batch_allocations[
        1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 30
      act = ls_result-preview-allocation-batch_allocations[
        1 ]-batch_allocation-minimum_shelf_life_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-reservation-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LONG'
      act = mo_api->mt_requests[ 1 ]-items[ 1 ]-batch ).
  ENDMETHOD.

  METHOD rejects_fefo_stock_change.
    mo_stock_repo->mt_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0001'
        batch                 = 'B-1'
        unrestricted_quantity = '4.000' ) ).
    mo_stock_repo->mt_recheck_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0001'
        batch                 = 'B-1'
        unrestricted_quantity = '3.000' ) ).
    mo_stock_repo->mv_use_recheck_snapshot = abap_true.

    DATA(ls_result) = mo_cut->reserve_wbs_fefo(
      it_demands            = VALUE #(
        ( request_id         = 'REQ-1'
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '2.000'
          unit               = 'EA' )
        ( request_id         = 'REQ-2'
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '2.000'
          unit               = 'EA' ) )
      it_wbs_required_dates = VALUE #(
        ( wbs_element = 'PRJ-1' required_date = '20261201' ) )
      iv_as_of_date         = '20261014' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-preview-allocation-allocations[
        1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-preview-allocation-allocations[
        2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-reservation-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-reservation-failed_count ).
    cl_abap_unit_assert=>assert_not_initial(
      act = ls_result-reservation-messages ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_stock_repo->mv_stock_read_calls ).
  ENDMETHOD.

  METHOD rejects_fefo_expiry_change.
    mo_stock_repo->mt_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0001'
        batch                 = 'B-1'
        expiration_date       = '20261230'
        unrestricted_quantity = '1.000' ) ).
    mo_stock_repo->mt_recheck_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0001'
        batch                 = 'B-1'
        expiration_date       = '20261130'
        unrestricted_quantity = '1.000' ) ).
    mo_stock_repo->mv_use_recheck_snapshot = abap_true.

    DATA(ls_result) = mo_cut->reserve_wbs_fefo(
      it_demands            = VALUE #(
        ( request_id         = 'REQ-EXP-1'
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '1.000'
          unit               = 'EA' ) )
      it_wbs_required_dates = VALUE #(
        ( wbs_element = 'PRJ-1' required_date = '20261201' ) )
      iv_as_of_date         = '20261014' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-reservation-is_successful ).
    cl_abap_unit_assert=>assert_not_initial(
      act = ls_result-reservation-messages ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_create_calls ).
  ENDMETHOD.

  METHOD rejects_new_earlier_fefo_batch.
    mo_stock_repo->mt_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0001'
        batch                 = 'B-LATE'
        expiration_date       = '20261210'
        unrestricted_quantity = '4.000' ) ).
    mo_stock_repo->mt_recheck_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0001'
        batch                 = 'B-EARLY'
        expiration_date       = '20261205'
        unrestricted_quantity = '4.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0001'
        batch                 = 'B-LATE'
        expiration_date       = '20261210'
        unrestricted_quantity = '4.000' ) ).
    mo_stock_repo->mv_use_recheck_snapshot = abap_true.

    DATA(ls_result) = mo_cut->reserve_wbs_fefo(
      it_demands            = VALUE #(
        ( request_id         = 'REQ-EARLY-1'
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '4.000'
          unit               = 'EA' ) )
      it_wbs_required_dates = VALUE #(
        ( wbs_element = 'PRJ-1' required_date = '20261201' ) )
      iv_as_of_date         = '20261014' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATE'
      act = ls_result-preview-allocation-batch_allocations[
        1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-reservation-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_create_calls ).
  ENDMETHOD.

  METHOD rejects_fefo_shortfall.
    mo_stock_repo->mt_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0001'
        batch                 = 'B-1'
        unrestricted_quantity = '2.000' ) ).

    DATA(ls_result) = mo_cut->reserve_wbs_fefo(
      it_demands                 = VALUE #(
        ( request_id         = 'REQ-1'
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '4.000'
          unit               = 'EA' ) )
      it_wbs_required_dates      = VALUE #(
        ( wbs_element = 'PRJ-1' required_date = '20261201' ) )
      iv_minimum_shelf_life_days = 2 ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-preview-allocation-allocations[
        1 ]-allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-reservation-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-reservation-failed_count ).
    cl_abap_unit_assert=>assert_not_initial(
      act = ls_result-reservation-messages ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_create_calls ).
  ENDMETHOD.

  METHOD reserves_location_wbs.
    mo_stock_repo->mt_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0002'
        unrestricted_quantity = '4.000' ) ).

    DATA(ls_result) = mo_cut->reserve_wbs_by_location(
      it_demands       = VALUE #(
        ( request_id         = 'REQ-LOC-1'
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '2.000'
          unit               = 'EA' )
        ( request_id         = 'REQ-LOC-2'
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '2.000'
          unit               = 'EA' ) )
      iv_required_date = '20261201' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-preview-allocation-allocations[
        1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-preview-allocation-allocations[
        2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-reservation-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = mo_api->mt_requests[ 1 ]-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_initial(
      act = mo_api->mt_requests[ 1 ]-items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
  ENDMETHOD.

  METHOD reserves_wbs_location_prio.
    mo_stock_repo->mt_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0001'
        unrestricted_quantity = '3.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0002'
        unrestricted_quantity = '2.000' ) ).

    DATA(ls_result) = mo_cut->reserve_wbs_location_priority(
      it_demands                   = VALUE #(
        ( request_id         = 'REQ-DUP'
          priority           = 1
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '2.000'
          unit               = 'EA' )
        ( request_id         = 'REQ-DUP'
          priority           = 9
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '2.000'
          unit               = 'EA' )
        ( request_id         = 'REQ-3'
          priority           = 9
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '2.000'
          unit               = 'EA' ) )
      it_storage_location_priority = VALUE #(
        ( '0002' ) ( '0001' ) )
      iv_required_date             = '20261020'
      iv_require_full_quantity     = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-preview-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REQ-DUP'
      act = ls_result-preview-allocations[
        1 ]-allocation-allocation-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '1.000' )
      act = ls_result-preview-allocations[
        1 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-preview-allocations[
        2 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-preview-allocations[
        3 ]-allocation-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-preview-storage_allocations[
        1 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-preview-storage_allocations[
        2 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-preview-storage_allocations[
        3 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-reservation-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( mo_api->mt_requests[ 1 ]-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = mo_api->mt_requests[ 1 ]-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = mo_api->mt_requests[ 1 ]-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = mo_api->mt_requests[ 1 ]-items[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = mo_api->mt_requests[ 1 ]-items[ 2 ]-storage_location ).
  ENDMETHOD.

  METHOD rejects_wbs_location_prio.
    mo_stock_repo->mt_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0002'
        unrestricted_quantity = '4.000' ) ).
    mo_stock_repo->mt_recheck_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0001'
        unrestricted_quantity = '4.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0002'
        unrestricted_quantity = '4.000' ) ).
    mo_stock_repo->mv_use_recheck_snapshot = abap_true.

    DATA(ls_result) = mo_cut->reserve_wbs_location_priority(
      it_demands                   = VALUE #(
        ( request_id         = 'REQ-LOC-PRIORITY'
          priority           = 5
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '4.000'
          unit               = 'EA' ) )
      it_storage_location_priority = VALUE #(
        ( '0001' ) ( '0002' ) )
      iv_required_date             = '20261020' ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-preview-storage_allocations[
        1 ]-split-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-reservation-is_successful ).
    cl_abap_unit_assert=>assert_not_initial(
      act = ls_result-reservation-messages ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_stock_repo->mv_stock_read_calls ).
  ENDMETHOD.

  METHOD rejects_location_stock_change.
    mo_stock_repo->mt_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0002'
        unrestricted_quantity = '4.000' ) ).
    mo_stock_repo->mt_recheck_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0002'
        unrestricted_quantity = '2.000' ) ).
    mo_stock_repo->mv_use_recheck_snapshot = abap_true.

    DATA(ls_result) = mo_cut->reserve_wbs_by_location(
      it_demands       = VALUE #(
        ( request_id         = 'REQ-LOC-1'
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '2.000'
          unit               = 'EA' )
        ( request_id         = 'REQ-LOC-2'
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '2.000'
          unit               = 'EA' ) )
      iv_required_date = '20261201' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-preview-allocation-allocations[
        1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = ls_result-preview-allocation-allocations[
        2 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-reservation-is_successful ).
    cl_abap_unit_assert=>assert_not_initial(
      act = ls_result-reservation-messages ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_stock_repo->mv_stock_read_calls ).
  ENDMETHOD.

  METHOD rejects_new_priority_location.
    mo_stock_repo->mt_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0002'
        unrestricted_quantity = '4.000' ) ).
    mo_stock_repo->mt_recheck_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0001'
        unrestricted_quantity = '4.000' )
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0002'
        unrestricted_quantity = '4.000' ) ).
    mo_stock_repo->mv_use_recheck_snapshot = abap_true.

    DATA(ls_result) = mo_cut->reserve_wbs_by_location(
      it_demands                   = VALUE #(
        ( request_id         = 'REQ-LOC-PRIORITY'
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '4.000'
          unit               = 'EA' ) )
      it_storage_location_priority = VALUE #(
        ( '0001' ) ( '0002' ) )
      iv_required_date             = '20261201' ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-preview-allocation-storage_allocations[
        1 ]-storage_allocation-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-reservation-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_create_calls ).
  ENDMETHOD.

  METHOD rejects_location_shortfall.
    mo_stock_repo->mt_stocks = VALUE #(
      ( material              = 'MAT-1'
        plant                 = '1000'
        wbs_element           = 'PRJ-1'
        storage_location      = '0002'
        unrestricted_quantity = '2.000' ) ).

    DATA(ls_result) = mo_cut->reserve_wbs_by_location(
      it_demands       = VALUE #(
        ( request_id         = 'REQ-LOC-1'
          wbs_element        = 'PRJ-1'
          material           = 'MAT-1'
          plant              = '1000'
          requested_quantity = '4.000'
          unit               = 'EA' ) )
      iv_required_date = '20261201' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-preview-allocation-allocations[
        1 ]-allocation-shortfall_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-reservation-is_successful ).
    cl_abap_unit_assert=>assert_not_initial(
      act = ls_result-reservation-messages ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_create_calls ).
  ENDMETHOD.

  METHOD reserves_batch_atomic.
    mo_api->mt_create_results = VALUE #(
      ( reservation_number = '0000001234'
        is_successful      = abap_true )
      ( reservation_number = '0000001235'
        is_successful      = abap_true ) ).

    DATA(ls_result) = mo_cut->reserve_batch_allocation(
      is_allocation         = batch_preview( )
      it_wbs_required_dates = VALUE #(
        ( wbs_element = 'PRJ-1' required_date = '20261201' )
        ( wbs_element = 'PRJ-2' required_date = '20261220' ) )
      iv_atomic             = abap_true ).

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
      act = mo_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_rollback_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001235'
      act = ls_result-reservations[ 2 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261220'
      act = mo_api->mt_requests[ 2 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-reservations[ 1 ]-is_committed ).
  ENDMETHOD.

  METHOD atomic_batch_prevalidates.
    DATA(ls_preview) = batch_preview( ).
    ls_preview-allocation-allocations[ 1 ]-allocation-shortfall_quantity =
      '1.000'.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->reserve_batch_allocation(
          is_allocation    = ls_preview
          iv_required_date = '20261201'
          iv_atomic        = abap_true ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD rejects_expired_batch_preview.
    DATA(ls_preview) = batch_preview( ).
    ls_preview-allocation-batch_allocations[ 1 ]-batch_allocation-expiration_date =
      '20261210'.
    ls_preview-allocation-batch_allocations[ 2 ]-batch_allocation-expiration_date =
      '20261210'.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->reserve_batch_allocation(
          is_allocation         = ls_preview
          it_wbs_required_dates = VALUE #(
            ( wbs_element = 'PRJ-1' required_date = '20261201' )
            ( wbs_element = 'PRJ-2' required_date = '20261215' ) ) ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_create_calls ).
  ENDMETHOD.

  METHOD accepts_batch_shelf_boundary.
    DATA(ls_preview) = batch_preview( ).
    ls_preview-allocation-batch_allocations[ 1 ]-batch_allocation-expiration_date =
      '20261203'.
    ls_preview-allocation-batch_allocations[ 2 ]-batch_allocation-expiration_date =
      '20261203'.

    DATA(ls_result) = mo_cut->reserve_batch_allocation(
      is_allocation              = ls_preview
      iv_required_date           = '20261201'
      iv_minimum_shelf_life_days = 2
      iv_test_run                = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
  ENDMETHOD.

  METHOD rejects_short_batch_shelf_life.
    DATA(ls_preview) = batch_preview( ).
    ls_preview-allocation-batch_allocations[ 1 ]-batch_allocation-expiration_date =
      '20261202'.
    ls_preview-allocation-batch_allocations[ 2 ]-batch_allocation-expiration_date =
      '20261202'.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->reserve_batch_allocation(
          is_allocation              = ls_preview
          iv_required_date           = '20261201'
          iv_minimum_shelf_life_days = 2 ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_create_calls ).
  ENDMETHOD.

  METHOD rejects_unknown_batch_expiry.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->reserve_batch_allocation(
          is_allocation              = batch_preview( )
          iv_required_date           = '20261201'
          iv_minimum_shelf_life_days = 1 ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_create_calls ).
  ENDMETHOD.

  METHOD atomic_batch_api_rollback.
    mo_api->mt_create_results = VALUE #(
      ( reservation_number = '0000001234'
        is_successful      = abap_true )
      ( reservation_number = '0000001235'
        is_successful      = abap_false
        messages           = VALUE #(
          ( type = 'E' message = 'Reservation could not be created' ) ) ) ).

    DATA(ls_result) = mo_cut->reserve_batch_allocation(
      is_allocation    = batch_preview( )
      iv_required_date = '20261201'
      iv_atomic        = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_rollback_calls ).
    cl_abap_unit_assert=>assert_not_initial(
      act = ls_result-messages ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-reservations[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-reservations[ 1 ]-was_rolled_back ).
  ENDMETHOD.

  METHOD atomic_batch_simulates.
    DATA(ls_result) = mo_cut->reserve_batch_allocation(
      is_allocation    = batch_preview( )
      iv_required_date = '20261201'
      iv_test_run      = abap_true
      iv_atomic        = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = mo_api->mv_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_rollback_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_committed ).
  ENDMETHOD.

  METHOD atomic_batch_duplicate_number.
    mo_api->mt_create_results = VALUE #(
      ( reservation_number = '0000001234'
        is_successful      = abap_true )
      ( reservation_number = '0000001234'
        is_successful      = abap_true ) ).

    DATA(ls_result) = mo_cut->reserve_batch_allocation(
      is_allocation    = batch_preview( )
      iv_required_date = '20261201'
      iv_atomic        = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_rollback_calls ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-reservations[ 1 ]-reservation_number ).
  ENDMETHOD.

  METHOD atomic_batch_commit_fail.
    mo_api->mt_create_results = VALUE #(
      ( reservation_number = '0000001234'
        is_successful      = abap_true )
      ( reservation_number = '0000001235'
        is_successful      = abap_true ) ).
    mo_api->ms_commit_result-is_successful = abap_false.

    DATA(ls_result) = mo_cut->reserve_batch_allocation(
      is_allocation    = batch_preview( )
      iv_required_date = '20261201'
      iv_atomic        = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_not_initial(
      act = ls_result-messages ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_rollback_calls ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-reservations[ 2 ]-reservation_number ).
  ENDMETHOD.

  METHOD reserves_location_preview.
    DATA(ls_result) = mo_cut->reserve_location_allocation(
      is_allocation         = VALUE #(
        allocation      = VALUE #(
          allocations         = VALUE #(
            ( allocation                = VALUE #(
                request_id         = 'REQ-LOC'
                material           = 'MAT-1'
                plant              = '1000'
                requested_quantity = '3.000'
                available_quantity = '3.000'
                allocated_quantity = '3.000'
                shortfall_quantity = '0.000' )
              source_quantity           = '3.000'
              source_unit               = 'EA'
              base_quantity             = '3.000'
              base_unit                 = 'EA'
              allocated_source_quantity = '3.000' ) )
          storage_allocations = VALUE #(
            ( storage_allocation        = VALUE #(
                request_id         = 'REQ-LOC'
                material           = 'MAT-1'
                plant              = '1000'
                storage_location   = '0002'
                allocated_quantity = '3.000' )
              base_unit                 = 'EA'
              source_unit               = 'EA'
              allocated_source_quantity = '3.000' ) ) )
        wbs_assignments = VALUE #(
          ( request_id = 'REQ-LOC' wbs_element = 'PRJ-LOC' ) ) )
      it_wbs_required_dates = VALUE #(
        ( wbs_element = 'PRJ-LOC' required_date = '20261201' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_initial(
      act = mo_api->ms_request-items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = mo_api->ms_request-items[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261201'
      act = mo_api->ms_request-required_date ).
  ENDMETHOD.

  METHOD reserves_location_atomic.
    mo_api->mt_create_results = VALUE #(
      ( reservation_number = '0000001244'
        is_successful      = abap_true )
      ( reservation_number = '0000001245'
        is_successful      = abap_true ) ).

    DATA(ls_result) = mo_cut->reserve_location_allocation(
      is_allocation    = location_preview( )
      iv_required_date = '20261201'
      iv_atomic        = abap_true ).

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
      act = mo_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_rollback_calls ).
    cl_abap_unit_assert=>assert_initial(
      act = mo_api->mt_requests[ 2 ]-items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = mo_api->mt_requests[ 2 ]-items[ 1 ]-storage_location ).
  ENDMETHOD.

  METHOD rejects_short_preview.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->reserve_location_allocation(
          is_allocation    = VALUE #(
            allocation      = VALUE #(
              allocations         = VALUE #(
                ( allocation                = VALUE #(
                    request_id         = 'REQ-SHORT'
                    material           = 'MAT-1'
                    plant              = '1000'
                    requested_quantity = '5.000'
                    available_quantity = '4.000'
                    allocated_quantity = '4.000'
                    shortfall_quantity = '1.000' )
                  source_quantity           = '5.000'
                  source_unit               = 'EA'
                  base_quantity             = '5.000'
                  base_unit                 = 'EA'
                  allocated_source_quantity = '4.000' ) )
              storage_allocations = VALUE #(
                ( storage_allocation        = VALUE #(
                    request_id         = 'REQ-SHORT'
                    material           = 'MAT-1'
                    plant              = '1000'
                    storage_location   = '0001'
                    allocated_quantity = '4.000' )
                  base_unit                 = 'EA'
                  source_unit               = 'EA'
                  allocated_source_quantity = '4.000' ) ) )
            wbs_assignments = VALUE #(
              ( request_id  = 'REQ-SHORT'
                wbs_element = 'PRJ-SHORT' ) ) )
          iv_required_date = '20261201' ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_create_calls ).
  ENDMETHOD.

  METHOD rejects_missing_alloc_wbs_date.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->reserve_batch_allocation(
          is_allocation         = batch_preview( )
          it_wbs_required_dates = VALUE #(
            ( wbs_element = 'PRJ-1' required_date = '20261201' ) ) ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_create_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
  ENDMETHOD.

  METHOD rejects_duplicate_items.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->reserve_for_wbs(
          is_request = VALUE #(
            wbs_element   = 'PRJ-100-001'
            required_date = '20261020'
            items         = VALUE #(
              ( material         = 'MAT-1'
                plant            = '1000'
                storage_location = '0001'
                quantity         = '1.000'
                unit             = 'EA' )
              ( material         = 'MAT-1'
                plant            = '1000'
                storage_location = '0001'
                quantity         = '2.000'
                unit             = 'EA' ) ) ) ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_create_calls ).
  ENDMETHOD.

  METHOD simulates_without_transaction.
    CLEAR mo_api->ms_create_result-reservation_number.

    DATA(ls_result) = mo_cut->reserve_for_wbs(
      is_request  = VALUE #(
        wbs_element   = 'PRJ-100-001'
        required_date = '20261020'
        items         = VALUE #(
          ( material         = 'MAT-1'
            plant            = '1000'
            storage_location = '0001'
            quantity         = '1.000'
            unit             = 'EA' ) ) )
      iv_test_run = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD rolls_back_commit_failure.
    mo_api->ms_commit_result-is_successful = abap_false.
    mo_api->ms_commit_result-message = VALUE #(
      type    = 'E'
      message = 'Commit failed' ).

    DATA(ls_result) = mo_cut->reserve_for_wbs(
      is_request = VALUE #(
        wbs_element   = 'PRJ-100-001'
        required_date = '20261020'
        items         = VALUE #(
          ( material         = 'MAT-1'
            plant            = '1000'
            storage_location = '0001'
            quantity         = '1.000'
            unit             = 'EA' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD rolls_back_create_failure.
    mo_api->ms_create_result-is_successful = abap_false.
    APPEND VALUE #(
      type    = 'E'
      message = 'Create failed' ) TO mo_api->ms_create_result-messages.

    DATA(ls_result) = mo_cut->reserve_for_wbs(
      is_request = VALUE #(
        wbs_element   = 'PRJ-100-001'
        required_date = '20261020'
        items         = VALUE #(
          ( material         = 'MAT-1'
            plant            = '1000'
            storage_location = '0001'
            quantity         = '1.000'
            unit             = 'EA' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_rollback_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
  ENDMETHOD.

  METHOD reschedules_wbs_items.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000'
        required_date      = '20261020' ) ).

    DATA(ls_result) = mo_cut->reschedule_reservation_items(
      iv_wbs_element        = 'PRJ-100-001'
      iv_reservation_number = '0000001234'
      it_item_numbers       = VALUE #( ( '0001' ) )
      iv_required_date      = '20261105' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_rescheduled ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001234'
      act = mo_api->mv_changed_reservation ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = mo_api->mt_changed_item_numbers[ 1 ] ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261105'
      act = mo_api->mv_changed_required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
  ENDMETHOD.

  METHOD rejects_bad_resched_date.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->reschedule_reservation_items(
          iv_wbs_element        = 'PRJ-100-001'
          iv_reservation_number = '0000001234'
          it_item_numbers       = VALUE #( ( '0001' ) )
          iv_required_date      = '20260230' ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_change_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
  ENDMETHOD.

  METHOD rejects_bad_bulk_resched_date.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->reschedule_items_bulk(
          it_requests = VALUE #(
            ( wbs_element        = 'PRJ-100-001'
              reservation_number = '0000001234'
              item_numbers       = VALUE #( ( '0001' ) )
              required_date      = '20261301' ) ) ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_change_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
  ENDMETHOD.

  METHOD rejects_atomic_bad_date.
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->reschedule_items_atomic(
          it_requests = VALUE #(
            ( wbs_element        = 'PRJ-100-001'
              reservation_number = '0000001234'
              item_numbers       = VALUE #( ( '0001' ) )
              required_date      = '20261105' )
            ( wbs_element        = 'PRJ-100-002'
              reservation_number = '0000001235'
              item_numbers       = VALUE #( ( '0002' ) )
              required_date      = '2026ABCD' ) ) ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_change_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
  ENDMETHOD.

  METHOD rejects_reschedule_scope.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-OTHER'
        unit               = 'EA'
        required_quantity  = '5.000' ) ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->reschedule_reservation_items(
          iv_wbs_element        = 'PRJ-100-001'
          iv_reservation_number = '0000001234'
          it_item_numbers       = VALUE #( ( '0001' ) )
          iv_required_date      = '20261105' ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_change_calls ).
  ENDMETHOD.

  METHOD simulates_reschedule.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' ) ).

    DATA(ls_result) = mo_cut->reschedule_reservation_items(
      iv_wbs_element        = 'PRJ-100-001'
      iv_reservation_number = '0000001234'
      it_item_numbers       = VALUE #( ( '0001' ) )
      iv_required_date      = '20261105'
      iv_test_run           = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_rescheduled ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_change_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD rolls_back_reschedule_commit.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' ) ).
    mo_api->ms_commit_result-is_successful = abap_false.
    mo_api->ms_commit_result-message = VALUE #(
      type    = 'E'
      message = 'Commit failed' ).

    DATA(ls_result) = mo_cut->reschedule_reservation_items(
      iv_wbs_element        = 'PRJ-100-001'
      iv_reservation_number = '0000001234'
      it_item_numbers       = VALUE #( ( '0001' ) )
      iv_required_date      = '20261105' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_rescheduled ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD bulk_reschedule_continues.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' )
      ( reservation_number = '0000001235'
        reservation_item   = '0002'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-002'
        unit               = 'EA'
        required_quantity  = '3.000' ) ).
    APPEND VALUE #(
      is_successful = abap_false
      messages      = VALUE #(
        ( type = 'E' message = 'Change failed' ) ) )
      TO mo_api->mt_change_results.

    DATA(ls_result) = mo_cut->reschedule_items_bulk(
      it_requests = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          item_numbers       = VALUE #( ( '0001' ) )
          required_date      = '20261105' )
        ( wbs_element        = 'PRJ-100-002'
          reservation_number = '0000001235'
          item_numbers       = VALUE #( ( '0002' ) )
          required_date      = '20261106' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 1 ]-is_rescheduled ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_rescheduled ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD atomic_resched_commits.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' )
      ( reservation_number = '0000001235'
        reservation_item   = '0002'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-002'
        unit               = 'EA'
        required_quantity  = '3.000' ) ).

    DATA(ls_result) = mo_cut->reschedule_items_atomic(
      it_requests = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          item_numbers       = VALUE #( ( '0001' ) )
          required_date      = '20261105' )
        ( wbs_element        = 'PRJ-100-002'
          reservation_number = '0000001235'
          item_numbers       = VALUE #( ( '0002' ) )
          required_date      = '20261106' ) ) ).

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
      act = mo_api->mv_change_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_rollback_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261106'
      act = mo_api->mv_changed_required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_rescheduled ).
  ENDMETHOD.

  METHOD atomic_resched_scope.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' )
      ( reservation_number = '0000001235'
        reservation_item   = '0002'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-002'
        unit               = 'EA'
        required_quantity  = '3.000' ) ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->reschedule_items_atomic(
          it_requests = VALUE #(
            ( wbs_element        = 'PRJ-100-001'
              reservation_number = '0000001234'
              item_numbers       = VALUE #( ( '0001' ) )
              required_date      = '20261105' )
            ( wbs_element        = 'PRJ-100-002'
              reservation_number = '0000001235'
              item_numbers       = VALUE #( ( '0003' ) )
              required_date      = '20261106' ) ) ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_change_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD atomic_resched_api_failure.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' )
      ( reservation_number = '0000001235'
        reservation_item   = '0002'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-002'
        unit               = 'EA'
        required_quantity  = '3.000' ) ).
    APPEND VALUE #(
      is_successful = abap_true ) TO mo_api->mt_change_results.
    APPEND VALUE #(
      is_successful = abap_false
      messages      = VALUE #(
        ( type = 'E' message = 'Reschedule failed' ) ) )
      TO mo_api->mt_change_results.

    DATA(ls_result) = mo_cut->reschedule_items_atomic(
      it_requests = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          item_numbers       = VALUE #( ( '0001' ) )
          required_date      = '20261105' )
        ( wbs_element        = 'PRJ-100-002'
          reservation_number = '0000001235'
          item_numbers       = VALUE #( ( '0002' ) )
          required_date      = '20261106' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->mv_change_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_rollback_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-was_rolled_back ).
  ENDMETHOD.

  METHOD atomic_resched_simulates.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' ) ).

    DATA(ls_result) = mo_cut->reschedule_items_atomic(
      it_requests = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          item_numbers       = VALUE #( ( '0001' ) )
          required_date      = '20261105' ) )
      iv_test_run = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_change_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD atomic_resched_commit_fail.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' ) ).
    mo_api->ms_commit_result-is_successful = abap_false.

    DATA(ls_result) = mo_cut->reschedule_items_atomic(
      it_requests = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          item_numbers       = VALUE #( ( '0001' ) )
          required_date      = '20261105' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_not_initial(
      act = ls_result-messages ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD changes_project_resv_qty.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        entry_unit         = 'BOX'
        required_quantity  = '5.000'
        withdrawn_quantity = '1.000' )
      ( reservation_number = '0000001234'
        reservation_item   = '0002'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        entry_unit         = 'EA'
        required_quantity  = '5.000'
        withdrawn_quantity = '1.000' ) ).

    DATA(ls_result) = mo_cut->change_reservation_item_qty(
      iv_wbs_element        = 'PRJ-100-001'
      iv_reservation_number = '0000001234'
      it_item_quantities    = VALUE #(
        ( item_number       = '0001'
          required_quantity = '1.000'
          unit              = 'BOX' )
        ( item_number       = '0002'
          required_quantity = '3.000'
          unit              = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_changed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001234'
      act = mo_api->mv_qty_change_reservation ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = mo_api->mt_changed_quantities[ 1 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1.000'
      act = mo_api->mt_changed_quantities[ 1 ]-required_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '3.000'
      act = mo_api->mt_changed_quantities[ 2 ]-required_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
  ENDMETHOD.

  METHOD rejects_qty_at_withdrawn.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        entry_unit         = 'EA'
        required_quantity  = '5.000'
        withdrawn_quantity = '4.000' ) ).
    DATA lv_raised TYPE abap_bool.
    DATA lv_unit_raised TYPE abap_bool.

    TRY.
        mo_cut->change_reservation_item_qty(
          iv_wbs_element        = 'PRJ-100-001'
          iv_reservation_number = '0000001234'
          it_item_quantities    = VALUE #(
            ( item_number       = '0001'
              required_quantity = '4.000'
              unit              = 'EA' ) ) ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    TRY.
        mo_cut->change_reservation_item_qty(
          iv_wbs_element        = 'PRJ-100-001'
          iv_reservation_number = '0000001234'
          it_item_quantities    = VALUE #(
            ( item_number       = '0001'
              required_quantity = '1.000'
              unit              = 'BOX' ) ) ).
      CATCH zcx_invalid_reservation.
        lv_unit_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_unit_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_change_quantity_calls ).
  ENDMETHOD.

  METHOD simulates_quantity_change.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        entry_unit         = 'EA'
        required_quantity  = '5.000' ) ).

    DATA(ls_result) = mo_cut->change_reservation_item_qty(
      iv_wbs_element        = 'PRJ-100-001'
      iv_reservation_number = '0000001234'
      it_item_quantities    = VALUE #(
        ( item_number       = '0001'
          required_quantity = '8.000'
          unit              = 'EA' ) )
      iv_test_run           = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_changed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_change_quantity_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
  ENDMETHOD.

  METHOD bulk_quantity_continues.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        entry_unit         = 'EA'
        required_quantity  = '5.000' )
      ( reservation_number = '0000001235'
        reservation_item   = '0002'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-002'
        unit               = 'EA'
        entry_unit         = 'EA'
        required_quantity  = '3.000' ) ).
    APPEND VALUE #(
      is_successful = abap_false
      messages      = VALUE #(
        ( type = 'E' message = 'Change failed' ) ) )
      TO mo_api->mt_change_quantity_results.

    DATA(ls_result) = mo_cut->change_reservation_qty_bulk(
      it_requests = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          item_quantities    = VALUE #(
            ( item_number       = '0001'
              required_quantity = '8.000'
              unit              = 'EA' ) ) )
        ( wbs_element        = 'PRJ-100-002'
          reservation_number = '0000001235'
          item_quantities    = VALUE #(
            ( item_number       = '0002'
              required_quantity = '6.000'
              unit              = 'EA' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_changed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD atomic_qty_commits_once.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        entry_unit         = 'BOX'
        required_quantity  = '5.000'
        withdrawn_quantity = '1.000' )
      ( reservation_number = '0000001235'
        reservation_item   = '0002'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-002'
        unit               = 'EA'
        entry_unit         = 'EA'
        required_quantity  = '3.000'
        withdrawn_quantity = '1.000' ) ).

    DATA(ls_result) = mo_cut->change_resv_qty_atomic(
      it_requests = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          item_quantities    = VALUE #(
            ( item_number       = '0001'
              required_quantity = '1.000'
              unit              = 'BOX' ) ) )
        ( wbs_element        = 'PRJ-100-002'
          reservation_number = '0000001235'
          item_quantities    = VALUE #(
            ( item_number       = '0002'
              required_quantity = '6.000'
              unit              = 'EA' ) ) ) ) ).

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
      act = mo_api->mv_change_quantity_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD atomic_qty_validates_scope.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        entry_unit         = 'EA'
        required_quantity  = '5.000'
        withdrawn_quantity = '1.000' )
      ( reservation_number = '0000001235'
        reservation_item   = '0002'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-002'
        unit               = 'EA'
        entry_unit         = 'EA'
        required_quantity  = '3.000'
        withdrawn_quantity = '1.000' ) ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->change_resv_qty_atomic(
          it_requests = VALUE #(
            ( wbs_element        = 'PRJ-100-001'
              reservation_number = '0000001234'
              item_quantities    = VALUE #(
                ( item_number       = '0001'
                  required_quantity = '8.000'
                  unit              = 'EA' ) ) )
            ( wbs_element        = 'PRJ-100-002'
              reservation_number = '0000001235'
              item_quantities    = VALUE #(
                ( item_number       = '0003'
                  required_quantity = '8.000'
                  unit              = 'EA' ) ) ) ) ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_change_quantity_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD atomic_qty_rolls_back_api.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        entry_unit         = 'EA'
        required_quantity  = '5.000'
        withdrawn_quantity = '1.000' )
      ( reservation_number = '0000001235'
        reservation_item   = '0002'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-002'
        unit               = 'EA'
        entry_unit         = 'EA'
        required_quantity  = '3.000'
        withdrawn_quantity = '1.000' ) ).
    APPEND VALUE #(
      is_successful = abap_true )
      TO mo_api->mt_change_quantity_results.
    APPEND VALUE #(
      is_successful = abap_false
      messages      = VALUE #(
        ( type = 'E' message = 'Quantity update failed' ) ) )
      TO mo_api->mt_change_quantity_results.

    DATA(ls_result) = mo_cut->change_resv_qty_atomic(
      it_requests = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          item_quantities    = VALUE #(
            ( item_number       = '0001'
              required_quantity = '8.000'
              unit              = 'EA' ) ) )
        ( wbs_element        = 'PRJ-100-002'
          reservation_number = '0000001235'
          item_quantities    = VALUE #(
            ( item_number       = '0002'
              required_quantity = '6.000'
              unit              = 'EA' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->mv_change_quantity_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_rollback_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-was_rolled_back ).
  ENDMETHOD.

  METHOD atomic_qty_simulates.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        entry_unit         = 'EA'
        required_quantity  = '5.000'
        withdrawn_quantity = '1.000' ) ).

    DATA(ls_result) = mo_cut->change_resv_qty_atomic(
      it_requests = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          item_quantities    = VALUE #(
            ( item_number       = '0001'
              required_quantity = '8.000'
              unit              = 'EA' ) ) ) )
      iv_test_run = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_change_quantity_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD atomic_qty_commit_failure.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        entry_unit         = 'EA'
        required_quantity  = '5.000'
        withdrawn_quantity = '1.000' ) ).
    mo_api->ms_commit_result-is_successful = abap_false.

    DATA(ls_result) = mo_cut->change_resv_qty_atomic(
      it_requests = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          item_quantities    = VALUE #(
            ( item_number       = '0001'
              required_quantity = '8.000'
              unit              = 'EA' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_not_initial(
      act = ls_result-messages ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_rollback_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 1 ]-is_changed ).
  ENDMETHOD.

  METHOD marks_reservation_final.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000'
        withdrawn_quantity = '2.000' ) ).

    DATA(ls_result) = mo_cut->mark_reservation_items_final(
      iv_wbs_element        = 'PRJ-100-001'
      iv_reservation_number = '0000001234'
      it_item_numbers       = VALUE #( ( '0001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_finalized ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001234'
      act = mo_api->mv_final_issue_reservation ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = mo_api->mt_final_issue_items[ 1 ] ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = mo_api->mv_final_issue_value ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_final_issue_calls ).
  ENDMETHOD.

  METHOD rejects_final_issue_scope.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-OTHER'
        unit               = 'EA'
        required_quantity  = '5.000' ) ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->mark_reservation_items_final(
          iv_wbs_element        = 'PRJ-100-001'
          iv_reservation_number = '0000001234'
          it_item_numbers       = VALUE #( ( '0001' ) ) ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_final_issue_calls ).
  ENDMETHOD.

  METHOD simulates_final_issue.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' ) ).

    DATA(ls_result) = mo_cut->mark_reservation_items_final(
      iv_wbs_element        = 'PRJ-100-001'
      iv_reservation_number = '0000001234'
      it_item_numbers       = VALUE #( ( '0001' ) )
      iv_test_run           = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_finalized ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_final_issue_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
  ENDMETHOD.

  METHOD bulk_final_issue_continues.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' )
      ( reservation_number = '0000001235'
        reservation_item   = '0002'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-002'
        unit               = 'EA'
        required_quantity  = '3.000' ) ).
    APPEND VALUE #(
      is_successful = abap_false
      messages      = VALUE #(
        ( type = 'E' message = 'Final issue update failed' ) ) )
      TO mo_api->mt_final_issue_results.

    DATA(ls_result) = mo_cut->mark_reservation_final_bulk(
      it_requests = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          item_numbers       = VALUE #( ( '0001' ) ) )
        ( wbs_element        = 'PRJ-100-002'
          reservation_number = '0000001235'
          item_numbers       = VALUE #( ( '0002' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_finalized ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD resets_final_issue.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000'
        withdrawn_quantity = '2.000'
        is_final_issue     = abap_true ) ).

    DATA(ls_result) = mo_cut->reset_reservation_items_final(
      iv_wbs_element        = 'PRJ-100-001'
      iv_reservation_number = '0000001234'
      it_item_numbers       = VALUE #( ( '0001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_reset ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_finalized ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = mo_api->mv_final_issue_value ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
  ENDMETHOD.

  METHOD rejects_final_reset_scope.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000'
        is_final_issue     = abap_false ) ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->reset_reservation_items_final(
          iv_wbs_element        = 'PRJ-100-001'
          iv_reservation_number = '0000001234'
          it_item_numbers       = VALUE #( ( '0001' ) ) ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_final_issue_calls ).
  ENDMETHOD.

  METHOD simulates_final_reset.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000'
        is_final_issue     = abap_true ) ).

    DATA(ls_result) = mo_cut->reset_reservation_items_final(
      iv_wbs_element        = 'PRJ-100-001'
      iv_reservation_number = '0000001234'
      it_item_numbers       = VALUE #( ( '0001' ) )
      iv_test_run           = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_reset ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_final_issue_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
  ENDMETHOD.

  METHOD bulk_final_reset_continues.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000'
        is_final_issue     = abap_true )
      ( reservation_number = '0000001235'
        reservation_item   = '0002'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-002'
        unit               = 'EA'
        required_quantity  = '3.000'
        is_final_issue     = abap_true ) ).
    APPEND VALUE #(
      is_successful = abap_false
      messages      = VALUE #(
        ( type = 'E' message = 'Final issue reset failed' ) ) )
      TO mo_api->mt_final_issue_results.

    DATA(ls_result) = mo_cut->reset_reservation_final_bulk(
      it_requests = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          item_numbers       = VALUE #( ( '0001' ) ) )
        ( wbs_element        = 'PRJ-100-002'
          reservation_number = '0000001235'
          item_numbers       = VALUE #( ( '0002' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_reset ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD atomic_final_commit_success.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000'
        withdrawn_quantity = '2.000' )
      ( reservation_number = '0000001235'
        reservation_item   = '0002'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-002'
        unit               = 'EA'
        required_quantity  = '3.000' ) ).

    DATA(ls_result) = mo_cut->set_resv_final_atomic(
      it_requests    = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          item_numbers       = VALUE #( ( '0001' ) ) )
        ( wbs_element        = 'PRJ-100-002'
          reservation_number = '0000001235'
          item_numbers       = VALUE #( ( '0002' ) ) ) )
      iv_final_issue = abap_true ).

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
      act = mo_api->mv_final_issue_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = mo_api->mv_final_issue_value ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_rollback_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-is_finalized ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_committed ).
  ENDMETHOD.

  METHOD atomic_final_reset_success.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000'
        withdrawn_quantity = '5.000'
        is_final_issue     = abap_true ) ).

    DATA(ls_result) = mo_cut->set_resv_final_atomic(
      it_requests    = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          item_numbers       = VALUE #( ( '0001' ) ) ) )
      iv_final_issue = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-is_reset ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = mo_api->mv_final_issue_value ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
  ENDMETHOD.

  METHOD atomic_final_validates_state.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000'
        is_final_issue     = abap_false ) ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->set_resv_final_atomic(
          it_requests    = VALUE #(
            ( wbs_element        = 'PRJ-100-001'
              reservation_number = '0000001234'
              item_numbers       = VALUE #( ( '0001' ) ) ) )
          iv_final_issue = abap_false ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_final_issue_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD atomic_final_api_failure.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' )
      ( reservation_number = '0000001235'
        reservation_item   = '0002'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-002'
        unit               = 'EA'
        required_quantity  = '3.000' ) ).
    APPEND VALUE #(
      is_successful = abap_true ) TO mo_api->mt_final_issue_results.
    APPEND VALUE #(
      is_successful = abap_false
      messages      = VALUE #(
        ( type = 'E' message = 'Final issue change failed' ) ) )
      TO mo_api->mt_final_issue_results.

    DATA(ls_result) = mo_cut->set_resv_final_atomic(
      it_requests    = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          item_numbers       = VALUE #( ( '0001' ) ) )
        ( wbs_element        = 'PRJ-100-002'
          reservation_number = '0000001235'
          item_numbers       = VALUE #( ( '0002' ) ) ) )
      iv_final_issue = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->mv_final_issue_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_rollback_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 1 ]-is_finalized ).
  ENDMETHOD.

  METHOD atomic_final_commit_failure.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' ) ).
    mo_api->ms_commit_result-is_successful = abap_false.

    DATA(ls_result) = mo_cut->set_resv_final_atomic(
      it_requests    = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          item_numbers       = VALUE #( ( '0001' ) ) ) )
      iv_final_issue = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_not_initial(
      act = ls_result-messages ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD atomic_final_simulates.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' ) ).

    DATA(ls_result) = mo_cut->set_resv_final_atomic(
      it_requests    = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          item_numbers       = VALUE #( ( '0001' ) ) ) )
      iv_final_issue = abap_true
      iv_test_run    = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_final_issue_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD changes_reservation_item_stock.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' )
      ( reservation_number = '0000001234'
        reservation_item   = '0002'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '3.000' ) ).

    DATA(ls_result) = mo_cut->change_reservation_item_stock(
      iv_wbs_element        = 'PRJ-100-001'
      iv_reservation_number = '0000001234'
      it_item_changes       = VALUE #(
        ( item_number             = '0001'
          storage_location        = '0002'
          batch                   = 'B-2'
          change_storage_location = abap_true
          change_batch            = abap_true )
        ( item_number  = '0002'
          change_batch = abap_true ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_changed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = mo_api->mt_stock_changes[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-2'
      act = mo_api->mt_stock_changes[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = mo_api->mt_stock_changes[ 1 ]-change_storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = mo_api->mt_stock_changes[ 2 ]-change_batch ).
    cl_abap_unit_assert=>assert_initial(
      act = mo_api->mt_stock_changes[ 2 ]-batch ).
  ENDMETHOD.

  METHOD rejects_stock_change_scope.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-OTHER'
        unit               = 'EA'
        required_quantity  = '5.000' ) ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->change_reservation_item_stock(
          iv_wbs_element        = 'PRJ-100-001'
          iv_reservation_number = '0000001234'
          it_item_changes       = VALUE #(
            ( item_number  = '0001'
              change_batch = abap_true
              batch        = 'B-2' ) ) ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_stock_change_calls ).
  ENDMETHOD.

  METHOD simulates_stock_change.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' ) ).

    DATA(ls_result) = mo_cut->change_reservation_item_stock(
      iv_wbs_element        = 'PRJ-100-001'
      iv_reservation_number = '0000001234'
      it_item_changes       = VALUE #(
        ( item_number             = '0001'
          storage_location        = '0002'
          change_storage_location = abap_true ) )
      iv_test_run           = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_changed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_stock_change_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
  ENDMETHOD.

  METHOD rolls_back_stock_change_commit.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' ) ).
    mo_api->ms_commit_result-is_successful = abap_false.

    DATA(ls_result) = mo_cut->change_reservation_item_stock(
      iv_wbs_element        = 'PRJ-100-001'
      iv_reservation_number = '0000001234'
      it_item_changes       = VALUE #(
        ( item_number  = '0001'
          change_batch = abap_true
          batch        = 'B-2' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD bulk_stock_change_continues.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' )
      ( reservation_number = '0000001235'
        reservation_item   = '0002'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-002'
        unit               = 'EA'
        required_quantity  = '3.000' ) ).
    APPEND VALUE #(
      is_successful = abap_false
      messages      = VALUE #(
        ( type = 'E' message = 'Stock change failed' ) ) )
      TO mo_api->mt_stock_change_results.

    DATA(ls_result) = mo_cut->change_reservation_stock_bulk(
      it_requests = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          item_changes       = VALUE #(
            ( item_number  = '0001'
              change_batch = abap_true
              batch        = 'B-2' ) ) )
        ( wbs_element        = 'PRJ-100-002'
          reservation_number = '0000001235'
          item_changes       = VALUE #(
            ( item_number             = '0002'
              storage_location        = '0002'
              change_storage_location = abap_true ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_changed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD atomic_stock_commit_success.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' )
      ( reservation_number = '0000001235'
        reservation_item   = '0002'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-002'
        unit               = 'EA'
        required_quantity  = '3.000' ) ).

    DATA(ls_result) = mo_cut->change_resv_stock_atomic(
      it_requests = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          item_changes       = VALUE #(
            ( item_number  = '0001'
              change_batch = abap_true
              batch        = 'B-2' ) ) )
        ( wbs_element        = 'PRJ-100-002'
          reservation_number = '0000001235'
          item_changes       = VALUE #(
            ( item_number             = '0002'
              storage_location        = '0002'
              change_storage_location = abap_true ) ) ) ) ).

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
      act = mo_api->mv_stock_change_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_rollback_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 2 ]-is_changed ).
  ENDMETHOD.

  METHOD atomic_stock_validate_scope.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' )
      ( reservation_number = '0000001235'
        reservation_item   = '0002'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-002'
        unit               = 'EA'
        required_quantity  = '3.000' ) ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        mo_cut->change_resv_stock_atomic(
          it_requests = VALUE #(
            ( wbs_element        = 'PRJ-100-001'
              reservation_number = '0000001234'
              item_changes       = VALUE #(
                ( item_number  = '0001'
                  change_batch = abap_true
                  batch        = 'B-2' ) ) )
            ( wbs_element        = 'PRJ-100-002'
              reservation_number = '0000001235'
              item_changes       = VALUE #(
                ( item_number  = '0003'
                  change_batch = abap_true
                  batch        = 'B-3' ) ) ) ) ).
      CATCH zcx_invalid_reservation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_stock_change_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD atomic_stock_rollback_failure.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' )
      ( reservation_number = '0000001235'
        reservation_item   = '0002'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-002'
        unit               = 'EA'
        required_quantity  = '3.000' ) ).
    APPEND VALUE #(
      is_successful = abap_false
      messages      = VALUE #(
        ( type = 'E' message = 'Stock change failed' ) ) )
      TO mo_api->mt_stock_change_results.

    DATA(ls_result) = mo_cut->change_resv_stock_atomic(
      it_requests = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          item_changes       = VALUE #(
            ( item_number  = '0001'
              change_batch = abap_true
              batch        = 'B-2' ) ) )
        ( wbs_element        = 'PRJ-100-002'
          reservation_number = '0000001235'
          item_changes       = VALUE #(
            ( item_number             = '0002'
              storage_location        = '0002'
              change_storage_location = abap_true ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->mv_stock_change_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_rollback_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-was_rolled_back ).
  ENDMETHOD.

  METHOD atomic_stock_simulates.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' ) ).

    DATA(ls_result) = mo_cut->change_resv_stock_atomic(
      it_requests = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          item_changes       = VALUE #(
            ( item_number             = '0001'
              storage_location        = '0002'
              change_storage_location = abap_true ) ) ) )
      iv_test_run = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-successful_count ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_stock_change_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->mv_rollback_calls ).
  ENDMETHOD.

  METHOD atomic_stock_commit_failure.
    mo_stock_repo->mt_reservations = VALUE #(
      ( reservation_number = '0000001234'
        reservation_item   = '0001'
        material           = 'MAT-1'
        plant              = '1000'
        wbs_element        = 'PRJ-100-001'
        unit               = 'EA'
        required_quantity  = '5.000' ) ).
    mo_api->ms_commit_result-is_successful = abap_false.

    DATA(ls_result) = mo_cut->change_resv_stock_atomic(
      it_requests = VALUE #(
        ( wbs_element        = 'PRJ-100-001'
          reservation_number = '0000001234'
          item_changes       = VALUE #(
            ( item_number  = '0001'
              change_batch = abap_true
              batch        = 'B-2' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-was_rolled_back ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-failed_count ).
    cl_abap_unit_assert=>assert_not_initial(
      act = ls_result-messages ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_commit_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->mv_rollback_calls ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-items[ 1 ]-is_changed ).
  ENDMETHOD.
ENDCLASS.
