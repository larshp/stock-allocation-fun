CLASS lcl_po_uom_repository DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_material_uom_repository.
    METHODS set_material_data
      IMPORTING
        iv_material         TYPE mard-matnr
        iv_base_unit        TYPE mara-meins
        iv_alternative_unit TYPE marm-meinh
        iv_numerator        TYPE marm-umrez
        iv_denominator      TYPE marm-umren.
  PRIVATE SECTION.
    DATA mv_material TYPE mard-matnr.
    DATA mv_base_unit TYPE mara-meins.
    DATA mv_alternative_unit TYPE marm-meinh.
    DATA ms_ratio TYPE zif_material_uom_repository=>ty_alt_unit_ratio.
ENDCLASS.

CLASS lcl_po_uom_repository IMPLEMENTATION.
  METHOD set_material_data.
    mv_material = iv_material.
    mv_base_unit = iv_base_unit.
    mv_alternative_unit = iv_alternative_unit.
    ms_ratio-numerator = iv_numerator.
    ms_ratio-denominator = iv_denominator.
  ENDMETHOD.

  METHOD zif_material_uom_repository~get_base_unit.
    IF iv_material = mv_material.
      rv_base_unit = mv_base_unit.
    ENDIF.
  ENDMETHOD.

  METHOD zif_material_uom_repository~get_alt_unit_ratio.
    IF iv_material = mv_material
        AND iv_alternative_unit = mv_alternative_unit.
      rs_ratio = ms_ratio.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_purchase_order_api_double DEFINITION FINAL.
  PUBLIC SECTION.
    TYPES ty_write_results TYPE STANDARD TABLE OF
      zif_purchase_order_api=>ty_write_result WITH EMPTY KEY.
    TYPES ty_read_results TYPE STANDARD TABLE OF
      zif_purchase_order_api=>ty_read_result WITH EMPTY KEY.
    TYPES ty_requests TYPE STANDARD TABLE OF
      zif_purchase_order_api=>ty_request WITH EMPTY KEY.
    INTERFACES zif_purchase_order_api.
    METHODS set_write_result
      IMPORTING
        is_result TYPE zif_purchase_order_api=>ty_write_result.
    METHODS set_write_results
      IMPORTING
        it_results TYPE ty_write_results.
    METHODS set_read_result
      IMPORTING
        is_result TYPE zif_purchase_order_api=>ty_read_result.
    METHODS set_read_results
      IMPORTING
        it_results TYPE ty_read_results.
    METHODS set_item_change_results
      IMPORTING
        it_results TYPE ty_write_results.
    METHODS set_commit_result
      IMPORTING
        is_result TYPE zif_purchase_order_api=>ty_commit_result.
    METHODS get_request
      RETURNING
        VALUE(rs_request) TYPE zif_purchase_order_api=>ty_request.
    METHODS get_requests
      RETURNING
        VALUE(rt_requests) TYPE ty_requests.
    METHODS get_create_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_item_change_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_test_run_call_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_changed_order
      RETURNING
        VALUE(rv_order) TYPE zif_purchase_order_api=>ty_purchase_order_number.
    METHODS get_changed_item_numbers
      RETURNING
        VALUE(rt_item_numbers) TYPE zif_purchase_order_api=>ty_item_numbers.
    METHODS get_changed_schedules
      RETURNING
        VALUE(rt_schedules) TYPE zif_purchase_order_api=>ty_schedule_changes.
    METHODS get_changed_item_quantities
      RETURNING
        VALUE(rt_changes) TYPE
          zif_purchase_order_api=>ty_item_quantity_changes.
    METHODS get_commit_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_rollback_count
      RETURNING
        VALUE(rv_count) TYPE i.
  PRIVATE SECTION.
    DATA ms_write_result TYPE zif_purchase_order_api=>ty_write_result.
    DATA mt_write_results TYPE ty_write_results.
    DATA ms_read_result TYPE zif_purchase_order_api=>ty_read_result.
    DATA mt_read_results TYPE ty_read_results.
    DATA mt_item_change_results TYPE ty_write_results.
    DATA ms_commit_result TYPE zif_purchase_order_api=>ty_commit_result.
    DATA ms_request TYPE zif_purchase_order_api=>ty_request.
    DATA mt_requests TYPE ty_requests.
    DATA mv_read_order TYPE zif_purchase_order_api=>ty_purchase_order_number.
    DATA mv_changed_order TYPE zif_purchase_order_api=>ty_purchase_order_number.
    DATA mt_changed_item_numbers TYPE zif_purchase_order_api=>ty_item_numbers.
    DATA mt_changed_schedules TYPE zif_purchase_order_api=>ty_schedule_changes.
    DATA mt_changed_item_quantities TYPE
      zif_purchase_order_api=>ty_item_quantity_changes.
    DATA mv_create_count TYPE i.
    DATA mv_read_count TYPE i.
    DATA mv_item_change_count TYPE i.
    DATA mv_test_run_call_count TYPE i.
    DATA mv_commit_count TYPE i.
    DATA mv_rollback_count TYPE i.
ENDCLASS.

CLASS lcl_purchase_order_api_double IMPLEMENTATION.
  METHOD set_write_result.
    ms_write_result = is_result.
  ENDMETHOD.

  METHOD set_write_results.
    mt_write_results = it_results.
  ENDMETHOD.

  METHOD set_read_result.
    ms_read_result = is_result.
  ENDMETHOD.

  METHOD set_read_results.
    mt_read_results = it_results.
  ENDMETHOD.

  METHOD set_item_change_results.
    mt_item_change_results = it_results.
  ENDMETHOD.

  METHOD set_commit_result.
    ms_commit_result = is_result.
  ENDMETHOD.

  METHOD get_request.
    rs_request = ms_request.
  ENDMETHOD.

  METHOD get_requests.
    rt_requests = mt_requests.
  ENDMETHOD.

  METHOD get_create_count.
    rv_count = mv_create_count.
  ENDMETHOD.

  METHOD get_read_count.
    rv_count = mv_read_count.
  ENDMETHOD.

  METHOD get_item_change_count.
    rv_count = mv_item_change_count.
  ENDMETHOD.

  METHOD get_test_run_call_count.
    rv_count = mv_test_run_call_count.
  ENDMETHOD.

  METHOD get_changed_order.
    rv_order = mv_changed_order.
  ENDMETHOD.

  METHOD get_changed_item_numbers.
    rt_item_numbers = mt_changed_item_numbers.
  ENDMETHOD.

  METHOD get_changed_schedules.
    rt_schedules = mt_changed_schedules.
  ENDMETHOD.

  METHOD get_changed_item_quantities.
    rt_changes = mt_changed_item_quantities.
  ENDMETHOD.

  METHOD get_commit_count.
    rv_count = mv_commit_count.
  ENDMETHOD.

  METHOD get_rollback_count.
    rv_count = mv_rollback_count.
  ENDMETHOD.

  METHOD zif_purchase_order_api~create_order.
    ADD 1 TO mv_create_count.
    ms_request = is_request.
    APPEND is_request TO mt_requests.
    IF mv_create_count <= lines( mt_write_results ).
      rs_result = mt_write_results[ mv_create_count ].
    ELSE.
      rs_result = ms_write_result.
    ENDIF.
    IF rs_result-submitted_items IS INITIAL.
      rs_result-submitted_items = is_request-items.
    ENDIF.
  ENDMETHOD.

  METHOD zif_purchase_order_api~read_order.
    ADD 1 TO mv_read_count.
    mv_read_order = iv_purchase_order_number.
    IF mv_read_count <= lines( mt_read_results ).
      rs_result = mt_read_results[ mv_read_count ].
    ELSE.
      rs_result = ms_read_result.
    ENDIF.
    IF rs_result-purchase_order_number IS INITIAL.
      rs_result-purchase_order_number = iv_purchase_order_number.
    ENDIF.
  ENDMETHOD.

  METHOD zif_purchase_order_api~mark_items_for_deletion.
    IF iv_test_run = abap_true.
      ADD 1 TO mv_test_run_call_count.
    ENDIF.
    ADD 1 TO mv_item_change_count.
    mv_changed_order = iv_purchase_order_number.
    mt_changed_item_numbers = it_item_numbers.
    IF mv_item_change_count <= lines( mt_item_change_results ).
      rs_result = mt_item_change_results[ mv_item_change_count ].
    ELSE.
      rs_result = ms_write_result.
    ENDIF.
    IF rs_result-purchase_order_number IS INITIAL.
      rs_result-purchase_order_number = iv_purchase_order_number.
    ENDIF.
    IF rs_result-submitted_item_numbers IS INITIAL.
      rs_result-submitted_item_numbers = it_item_numbers.
    ENDIF.
  ENDMETHOD.

  METHOD zif_purchase_order_api~mark_items_delivery_complete.
    IF iv_test_run = abap_true.
      ADD 1 TO mv_test_run_call_count.
    ENDIF.
    ADD 1 TO mv_item_change_count.
    mv_changed_order = iv_purchase_order_number.
    mt_changed_item_numbers = it_item_numbers.
    IF mv_item_change_count <= lines( mt_item_change_results ).
      rs_result = mt_item_change_results[ mv_item_change_count ].
    ELSE.
      rs_result = ms_write_result.
    ENDIF.
    IF rs_result-purchase_order_number IS INITIAL.
      rs_result-purchase_order_number = iv_purchase_order_number.
    ENDIF.
    IF rs_result-submitted_item_numbers IS INITIAL.
      rs_result-submitted_item_numbers = it_item_numbers.
    ENDIF.
  ENDMETHOD.

  METHOD zif_purchase_order_api~change_schedules.
    IF iv_test_run = abap_true.
      ADD 1 TO mv_test_run_call_count.
    ENDIF.
    ADD 1 TO mv_item_change_count.
    mv_changed_order = iv_purchase_order_number.
    mt_changed_schedules = it_schedule_changes.
    IF mv_item_change_count <= lines( mt_item_change_results ).
      rs_result = mt_item_change_results[ mv_item_change_count ].
    ELSE.
      rs_result = ms_write_result.
    ENDIF.
    IF rs_result-purchase_order_number IS INITIAL.
      rs_result-purchase_order_number = iv_purchase_order_number.
    ENDIF.
    IF rs_result-submitted_schedules IS INITIAL.
      rs_result-submitted_schedules = it_schedule_changes.
    ENDIF.
  ENDMETHOD.

  METHOD zif_purchase_order_api~change_item_quantities.
    IF iv_test_run = abap_true.
      ADD 1 TO mv_test_run_call_count.
    ENDIF.
    ADD 1 TO mv_item_change_count.
    mv_changed_order = iv_purchase_order_number.
    mt_changed_item_quantities = it_item_changes.
    IF mv_item_change_count <= lines( mt_item_change_results ).
      rs_result = mt_item_change_results[ mv_item_change_count ].
    ELSE.
      rs_result = ms_write_result.
    ENDIF.
    IF rs_result-purchase_order_number IS INITIAL.
      rs_result-purchase_order_number = iv_purchase_order_number.
    ENDIF.
    IF rs_result-submitted_item_quantities IS INITIAL.
      rs_result-submitted_item_quantities = it_item_changes.
    ENDIF.
  ENDMETHOD.

  METHOD zif_purchase_order_api~commit.
    ADD 1 TO mv_commit_count.
    rs_result = ms_commit_result.
  ENDMETHOD.

  METHOD zif_purchase_order_api~rollback.
    ADD 1 TO mv_rollback_count.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_purchase_order_service DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_api TYPE REF TO lcl_purchase_order_api_double.
    DATA mo_cut TYPE REF TO zcl_purchase_order_service.
    METHODS setup.
    METHODS build_request
      RETURNING
        VALUE(rs_request) TYPE zif_purchase_order_api=>ty_request.
    METHODS build_selected_pr_item
      IMPORTING
        iv_requisition_number TYPE eban-banfn
        iv_vendor             TYPE zif_purchase_order_api=>ty_vendor
        iv_purchasing_org     TYPE zif_purchase_order_api=>ty_purchasing_org
        iv_item_number        TYPE eban-bnfpo
        iv_material           TYPE mard-matnr
        iv_quantity           TYPE mard-labst
        iv_ordered_quantity   TYPE mard-labst
      RETURNING
        VALUE(rs_item)        TYPE
          zcl_purchase_order_service=>ty_selected_requisition_item.
    METHODS creates_selected_source_order FOR TESTING.
    METHODS simulates_without_commit FOR TESTING.
    METHODS rejects_invalid_source_order FOR TESTING.
    METHODS rolls_back_api_error FOR TESTING.
    METHODS rejects_missing_order_number FOR TESTING.
    METHODS rolls_back_commit_error FOR TESTING.
    METHODS creates_orders_in_bulk FOR TESTING.
    METHODS simulates_bulk_order_creates FOR TESTING.
    METHODS validates_bulk_before_writing FOR TESTING.
    METHODS creates_orders_atomically FOR TESTING.
    METHODS rolls_back_atomic_create_error FOR TESTING.
    METHODS fails_atomic_create_commit FOR TESTING.
    METHODS simulates_atomic_po_creates FOR TESTING.
    METHODS validates_atomic_test_mode FOR TESTING.
    METHODS marks_selected_items_deleted FOR TESTING.
    METHODS continues_bulk_item_deletion FOR TESTING.
    METHODS validates_delete_batch_first FOR TESTING.
    METHODS marks_items_delivery_complete FOR TESTING.
    METHODS continues_complete_bulk FOR TESTING.
    METHODS validates_complete_batch FOR TESTING.
    METHODS reads_purchase_order_details FOR TESTING.
    METHODS reads_orders_in_bulk FOR TESTING.
    METHODS validates_po_read_batch FOR TESTING.
    METHODS preserves_po_read_errors FOR TESTING.
    METHODS rejects_mismatched_po_read FOR TESTING.
    METHODS creates_order_from_suggestions FOR TESTING.
    METHODS groups_suggestions_by_vendor FOR TESTING.
    METHODS continues_vendor_batch FOR TESTING.
    METHODS validates_vendor_groups FOR TESTING.
    METHODS skips_empty_vendor_batch FOR TESTING.
    METHODS creates_suggestion_pos_atomic FOR TESTING.
    METHODS rolls_back_suggestion_atomic FOR TESTING.
    METHODS skips_empty_atomic_suggestions FOR TESTING.
    METHODS rejects_mismatched_suggestion FOR TESTING.
    METHODS skips_zero_suggestions FOR TESTING.
    METHODS creates_po_from_pr_items FOR TESTING.
    METHODS validates_pr_items_first FOR TESTING.
    METHODS groups_selected_prs_by_vendor FOR TESTING.
    METHODS continues_pr_po_batch FOR TESTING.
    METHODS validates_selected_pr_groups FOR TESTING.
    METHODS creates_pr_pos_atomic FOR TESTING.
    METHODS rolls_back_pr_po_batch FOR TESTING.
    METHODS changes_order_schedules FOR TESTING.
    METHODS continues_schedule_batch FOR TESTING.
    METHODS validates_schedule_batch_first FOR TESTING.
    METHODS changes_schedules_atomic FOR TESTING.
    METHODS simulates_po_change FOR TESTING.
    METHODS simulates_atomic_scheds FOR TESTING.
    METHODS sim_atomic_change_error FOR TESTING.
    METHODS rejects_bad_change_test_flag FOR TESTING.
    METHODS changes_item_quantities FOR TESTING.
    METHODS continues_quantity_bulk FOR TESTING.
    METHODS changes_quantities_atomic FOR TESTING.
    METHODS rolls_back_quantity_batch FOR TESTING.
    METHODS fails_quantity_commit FOR TESTING.
    METHODS prevalidates_quantity_batch FOR TESTING.
    METHODS changes_base_qty FOR TESTING.
    METHODS validates_base_qty_bulk_first FOR TESTING.
    METHODS changes_base_qty_atomically FOR TESTING.
    METHODS rejects_unconvertible_base_qty FOR TESTING.
    METHODS changes_sched_base FOR TESTING.
    METHODS validates_base_sched_bulk FOR TESTING.
    METHODS changes_base_sched_atomically FOR TESTING.
    METHODS rejects_bad_sched_base_unit FOR TESTING.
    METHODS rolls_back_schedule_atomic FOR TESTING.
    METHODS fails_atomic_schedule_commit FOR TESTING.
    METHODS prevalidates_atomic_scheds FOR TESTING.
    METHODS deletes_item_batch_atomic FOR TESTING.
    METHODS completes_item_batch_atomic FOR TESTING.
    METHODS rolls_back_item_batch_atomic FOR TESTING.
    METHODS prevalidates_atomic_items FOR TESTING.
ENDCLASS.

CLASS ltcl_purchase_order_service IMPLEMENTATION.
  METHOD simulates_po_change.
    DATA(lt_changes) = VALUE zif_purchase_order_api=>ty_item_quantity_changes(
      ( item_number = '00010' quantity = '8.000' ) ).
    mo_api->set_write_result(
      is_result = VALUE #( is_successful = abap_true ) ).

    DATA(ls_result) = mo_cut->change_item_quantities(
      iv_purchase_order_number = '4500000100'
      it_item_changes          = lt_changes
      iv_test_run              = abap_true ).

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
      exp = 1
      act = mo_api->get_test_run_call_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD simulates_atomic_scheds.
    DATA(lt_changes) = VALUE zcl_purchase_order_service=>ty_order_schedule_changes(
        ( purchase_order_number = '4500000101'
          schedule_changes      = VALUE #( (
            item_number          = '00010'
            schedule_line        = '0001'
            change_delivery_date = abap_true
            delivery_date        = '20261201' ) ) )
        ( purchase_order_number = '4500000102'
          schedule_changes      = VALUE #( (
            item_number     = '00020'
            schedule_line   = '0002'
            change_quantity = abap_true
            quantity        = '6.000' ) ) ) ).
    mo_api->set_item_change_results(
      it_results = VALUE #(
        ( is_successful = abap_true )
        ( is_successful = abap_true ) ) ).

    DATA(ls_result) = mo_cut->change_order_schedules_atomic(
      it_changes  = lt_changes
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
      act = ls_result-order_results[ 1 ]-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->get_test_run_call_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD sim_atomic_change_error.
    DATA(lt_changes) = VALUE zcl_purchase_order_service=>ty_order_schedule_changes(
        ( purchase_order_number = '4500000101'
          schedule_changes      = VALUE #( (
            item_number          = '00010'
            schedule_line        = '0001'
            change_delivery_date = abap_true
            delivery_date        = '20261201' ) ) )
        ( purchase_order_number = '4500000102'
          schedule_changes      = VALUE #( (
            item_number     = '00020'
            schedule_line   = '0002'
            change_quantity = abap_true
            quantity        = '6.000' ) ) ) ).
    mo_api->set_item_change_results(
      it_results = VALUE #(
        ( is_successful = abap_true )
        ( messages = VALUE #( (
          type    = 'E'
          message = 'Schedule update rejected' ) ) ) ) ).

    DATA(ls_result) = mo_cut->change_order_schedules_atomic(
      it_changes  = lt_changes
      iv_test_run = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-order_results[ 1 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 2 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->get_test_run_call_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_change_test_flag.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->change_qty_from_base(
          iv_purchase_order_number = '4500000100'
          it_item_changes          = VALUE #(
            ( item_number = '00010' base_quantity = '2.000' ) )
          iv_test_run              = 'Y' ).
      CATCH zcx_invalid_stock_request.
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
      act = mo_api->get_item_change_count( ) ).
  ENDMETHOD.

  METHOD setup.
    mo_api = NEW lcl_purchase_order_api_double( ).
    mo_api->set_write_result(
      is_result = VALUE #(
        is_successful         = abap_true
        purchase_order_number = '4500000100' ) ).
    mo_api->set_commit_result(
      is_result = VALUE #( is_successful = abap_true ) ).
    mo_cut = NEW zcl_purchase_order_service( io_api = mo_api ).
  ENDMETHOD.

  METHOD build_request.
    rs_request = VALUE #(
      document_type    = 'NB'
      company_code     = '1000'
      purchasing_org   = '1000'
      purchasing_group = '001'
      vendor           = '0000100001'
      document_date    = '20261011'
      items            = VALUE #(
        ( item_number        = '00010'
          source_request_id  = 'PIR-1'
          material           = 'MAT-1'
          plant              = '1000'
          quantity           = '5.000'
          unit               = 'EA'
          delivery_date      = '20261101'
          source_info_record = '0000001234' )
        ( item_number           = '00020'
          source_request_id     = 'AGR-1'
          material              = 'MAT-2'
          plant                 = '1000'
          quantity              = '3.000'
          unit                  = 'EA'
          delivery_date         = '20261108'
          source_agreement      = '4500000001'
          source_agreement_item = '00010' ) ) ).
  ENDMETHOD.

  METHOD build_selected_pr_item.
    rs_item = VALUE #(
      requisition_number = iv_requisition_number
      vendor             = iv_vendor
      purchasing_org     = iv_purchasing_org
      item               = VALUE #(
        item_number      = iv_item_number
        material         = iv_material
        plant            = '1000'
        quantity         = iv_quantity
        ordered_quantity = iv_ordered_quantity
        unit             = 'EA'
        delivery_date    = '20261101'
        purchasing_org   = iv_purchasing_org
        source_vendor    = iv_vendor ) ).
  ENDMETHOD.

  METHOD creates_selected_source_order.
    DATA(ls_result) = mo_cut->create_order(
      is_request = build_request( ) ).
    DATA(ls_submitted_request) = mo_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000100'
      act = ls_result-purchase_order_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = ls_submitted_request-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001234'
      act = ls_submitted_request-items[ 1 ]-source_info_record ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000001'
      act = ls_submitted_request-items[ 2 ]-source_agreement ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD simulates_without_commit.
    DATA(ls_request) = build_request( ).
    ls_request-is_test_run = abap_true.
    mo_api->set_write_result(
      is_result = VALUE #( is_successful = abap_true ) ).

    DATA(ls_result) = mo_cut->create_order( is_request = ls_request ).

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
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_invalid_source_order.
    DATA(ls_request) = build_request( ).
    ls_request-items[ 2 ]-source_agreement_item = ' '.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->create_order( is_request = ls_request ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_api_error.
    mo_api->set_write_result(
      is_result = VALUE #(
        purchase_order_number = '4500000100'
        messages              = VALUE #( (
          type    = 'E'
          message = 'Source rejected by SAP' ) ) ) ).

    DATA(ls_result) = mo_cut->create_order(
      is_request = build_request( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-purchase_order_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rejects_missing_order_number.
    mo_api->set_write_result(
      is_result = VALUE #( is_successful = abap_true ) ).

    DATA(ls_result) = mo_cut->create_order(
      is_request = build_request( ) ).

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

  METHOD rolls_back_commit_error.
    mo_api->set_commit_result(
      is_result = VALUE #(
        is_successful = abap_false
        message       = VALUE #(
          type    = 'E'
          message = 'Commit failed' ) ) ).

    DATA(ls_result) = mo_cut->create_order(
      is_request = build_request( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-purchase_order_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD creates_orders_in_bulk.
    mo_api->set_write_results(
      it_results = VALUE #(
        ( is_successful         = abap_true
          purchase_order_number = '4500000101' )
        ( purchase_order_number = '4500000102'
          messages              = VALUE #( (
            type    = 'E'
            message = 'Second order rejected' ) ) )
        ( is_successful         = abap_true
          purchase_order_number = '4500000103' ) ) ).
    DATA(ls_request) = build_request( ).

    DATA(ls_result) = mo_cut->create_orders_bulk(
      it_requests = VALUE #(
        ( ls_request )
        ( ls_request )
        ( ls_request ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-order_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-order_results[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 2 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Second order rejected'
      act = ls_result-order_results[ 2 ]-messages[ 1 ]-message ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-order_results[ 2 ]-purchase_order_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000103'
      act = ls_result-order_results[ 3 ]-purchase_order_number ).
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
    DATA(ls_request) = build_request( ).
    ls_request-is_test_run = abap_true.

    DATA(ls_result) = mo_cut->create_orders_bulk(
      it_requests = VALUE #( ( ls_request ) ( ls_request ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD validates_bulk_before_writing.
    DATA(ls_request) = build_request( ).
    DATA(ls_invalid_request) = ls_request.
    CLEAR ls_invalid_request-vendor.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->create_orders_bulk(
          it_requests = VALUE #(
            ( ls_request )
            ( ls_invalid_request ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD creates_orders_atomically.
    mo_api->set_write_results(
      it_results = VALUE #(
        ( is_successful         = abap_true
          purchase_order_number = '4500000111' )
        ( is_successful         = abap_true
          purchase_order_number = '4500000112' ) ) ).
    DATA(ls_request) = build_request( ).

    DATA(ls_result) = mo_cut->create_orders_atomic(
      it_requests = VALUE #( ( ls_request ) ( ls_request ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000111'
      act = ls_result-order_results[ 1 ]-purchase_order_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-order_results[ 2 ]-is_committed ).
  ENDMETHOD.

  METHOD rolls_back_atomic_create_error.
    mo_api->set_write_results(
      it_results = VALUE #(
        ( is_successful         = abap_true
          purchase_order_number = '4500000111' )
        ( purchase_order_number = '4500000112'
          messages              = VALUE #( (
            type    = 'E'
            message = 'Second order rejected' ) ) ) ) ).
    DATA(ls_request) = build_request( ).

    DATA(ls_result) = mo_cut->create_orders_atomic(
      it_requests = VALUE #( ( ls_request ) ( ls_request ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 1 ]-is_successful ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-order_results[ 1 ]-purchase_order_number ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-order_results[ 2 ]-purchase_order_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD fails_atomic_create_commit.
    mo_api->set_write_results(
      it_results = VALUE #(
        ( is_successful         = abap_true
          purchase_order_number = '4500000111' )
        ( is_successful         = abap_true
          purchase_order_number = '4500000112' ) ) ).
    mo_api->set_commit_result(
      is_result = VALUE #(
        is_successful = abap_false
        message       = VALUE #(
          type    = 'E'
          message = 'Group commit failed' ) ) ).
    DATA(ls_request) = build_request( ).

    DATA(ls_result) = mo_cut->create_orders_atomic(
      it_requests = VALUE #( ( ls_request ) ( ls_request ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Group commit failed'
      act = ls_result-commit_result-message-message ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-order_results[ 1 ]-purchase_order_number ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-order_results[ 2 ]-purchase_order_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD simulates_atomic_po_creates.
    DATA(ls_request) = build_request( ).
    ls_request-is_test_run = abap_true.

    DATA(ls_result) = mo_cut->create_orders_atomic(
      it_requests = VALUE #( ( ls_request ) ( ls_request ) ) ).

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
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD validates_atomic_test_mode.
    DATA(ls_request) = build_request( ).
    DATA(ls_test_request) = ls_request.
    ls_test_request-is_test_run = abap_true.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->create_orders_atomic(
          it_requests = VALUE #( ( ls_request ) ( ls_test_request ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD marks_selected_items_deleted.
    DATA(ls_result) = mo_cut->delete_order_items(
      iv_purchase_order_number = '4500000200'
      it_item_numbers          = VALUE #(
        ( '00010' )
        ( '00030' ) ) ).
    DATA(lt_deleted_item_numbers) = mo_api->get_changed_item_numbers( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000200'
      act = ls_result-purchase_order_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00030'
      act = ls_result-submitted_item_numbers[ 2 ] ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000200'
      act = mo_api->get_changed_order( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00030'
      act = lt_deleted_item_numbers[ 2 ] ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD continues_bulk_item_deletion.
    mo_api->set_item_change_results(
      it_results = VALUE #(
        ( is_successful = abap_true )
        ( messages      = VALUE #( (
          type    = 'E'
          message = 'Item cannot be deleted' ) ) )
        ( is_successful = abap_true ) ) ).

    DATA(ls_result) = mo_cut->delete_orders_items_bulk(
      it_deletions = VALUE #(
        ( purchase_order_number = '4500000201'
          item_numbers          = VALUE #( ( '00010' ) ) )
        ( purchase_order_number = '4500000202'
          item_numbers          = VALUE #( ( '00020' ) ) )
        ( purchase_order_number = '4500000203'
          item_numbers          = VALUE #( ( '00030' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-order_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-order_results[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 2 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Item cannot be deleted'
      act = ls_result-order_results[ 2 ]-messages[ 1 ]-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-order_results[ 3 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = mo_api->get_item_change_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD validates_delete_batch_first.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->delete_orders_items_bulk(
          it_deletions = VALUE #(
            ( purchase_order_number = '4500000201'
              item_numbers          = VALUE #( ( '00010' ) ) )
            ( purchase_order_number = '4500000201'
              item_numbers          = VALUE #( ( '00020' ) ) ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_item_change_count( ) ).
  ENDMETHOD.

  METHOD marks_items_delivery_complete.
    DATA(ls_result) = mo_cut->mark_delivery_complete(
      iv_purchase_order_number = '4500000300'
      it_item_numbers          = VALUE #(
        ( '00010' )
        ( '00020' ) ) ).
    DATA(lt_changed_item_numbers) = mo_api->get_changed_item_numbers( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000300'
      act = mo_api->get_changed_order( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00020'
      act = lt_changed_item_numbers[ 2 ] ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD continues_complete_bulk.
    mo_api->set_item_change_results(
      it_results = VALUE #(
        ( is_successful = abap_true )
        ( messages      = VALUE #( (
          type    = 'E'
          message = 'Item update rejected' ) ) )
        ( is_successful = abap_true ) ) ).

    DATA(ls_result) = mo_cut->mark_delivery_complete_bulk(
      it_changes = VALUE #(
        ( purchase_order_number = '4500000301'
          item_numbers          = VALUE #( ( '00010' ) ) )
        ( purchase_order_number = '4500000302'
          item_numbers          = VALUE #( ( '00020' ) ) )
        ( purchase_order_number = '4500000303'
          item_numbers          = VALUE #( ( '00030' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_result-order_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-order_results[ 1 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 2 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Item update rejected'
      act = ls_result-order_results[ 2 ]-messages[ 1 ]-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-order_results[ 3 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = mo_api->get_item_change_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD validates_complete_batch.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->mark_delivery_complete_bulk(
          it_changes = VALUE #(
            ( purchase_order_number = '4500000301'
              item_numbers          = VALUE #( ( '00010' ) ) )
            ( purchase_order_number = '4500000301'
              item_numbers          = VALUE #( ( '00020' ) ) ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_item_change_count( ) ).
  ENDMETHOD.

  METHOD reads_purchase_order_details.
    mo_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        header        = VALUE #(
          document_type    = 'NB'
          company_code     = '1000'
          purchasing_org   = '1000'
          purchasing_group = '001'
          vendor           = '0000100001'
          document_date    = '20261011' )
        items         = VALUE #( (
          item_number       = '00010'
          material          = 'MAT-1'
          plant             = '1000'
          ordered_quantity  = '5.000'
          unit              = 'EA'
          delivery_complete = abap_true ) )
        schedules     = VALUE #( (
          item_number   = '00010'
          schedule_line = '0001'
          delivery_date = '20261101'
          quantity      = '5.000' ) ) ) ).

    DATA(ls_result) = mo_cut->read_order(
      iv_purchase_order_number = '4500000400' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000400'
      act = ls_result-header-purchase_order_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = ls_result-header-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MAT-1'
      act = ls_result-items[ 1 ]-material ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-items[ 1 ]-delivery_complete ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261101'
      act = ls_result-schedules[ 1 ]-delivery_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_read_count( ) ).
  ENDMETHOD.

  METHOD reads_orders_in_bulk.
    mo_api->set_read_results(
      it_results = VALUE #(
        ( is_successful = abap_true
          header        = VALUE #( vendor = '0000100001' ) )
        ( is_successful = abap_true
          header        = VALUE #( vendor = '0000100002' ) ) ) ).

    DATA(lt_results) = mo_cut->read_orders(
      it_purchase_order_numbers = VALUE #(
        ( '4500000401' )
        ( '4500000402' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000401'
      act = lt_results[ 1 ]-purchase_order_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100002'
      act = lt_results[ 2 ]-read_result-header-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->get_read_count( ) ).
  ENDMETHOD.

  METHOD validates_po_read_batch.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->read_orders(
          it_purchase_order_numbers = VALUE #(
            ( '4500000401' )
            ( '4500000401' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_read_count( ) ).
  ENDMETHOD.

  METHOD preserves_po_read_errors.
    mo_api->set_read_result(
      is_result = VALUE #(
        messages = VALUE #( (
          type    = 'E'
          message = 'Purchase order was not found' ) ) ) ).

    DATA(ls_result) = mo_cut->read_order(
      iv_purchase_order_number = '4500000499' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Purchase order was not found'
      act = ls_result-messages[ 1 ]-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000499'
      act = ls_result-purchase_order_number ).
  ENDMETHOD.

  METHOD rejects_mismatched_po_read.
    mo_api->set_read_result(
      is_result = VALUE #(
        is_successful         = abap_true
        purchase_order_number = '4500000498' ) ).

    DATA(ls_result) = mo_cut->read_order(
      iv_purchase_order_number = '4500000499' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'E'
      act = ls_result-messages[ 1 ]-type ).
  ENDMETHOD.

  METHOD creates_order_from_suggestions.
    DATA(ls_header) = build_request( ).
    CLEAR ls_header-items.
    DATA(lt_suggestions) = VALUE
      zcl_prod_comp_service=>ty_comp_replenishments(
        ( material                = 'MAT-1'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261101'
          procurement_type        = 'F'
          source_vendor           = '0000100001'
          source_purchasing_org   = '1000'
          source_info_record      = '0000001234'
          suggested_base_quantity = '5.000' )
        ( material                = 'MAT-2'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261108'
          procurement_type        = 'F'
          source_vendor           = '0000100001'
          source_purchasing_org   = '1000'
          source_agreement        = '4500000001'
          source_agreement_item   = '00010'
          suggested_base_quantity = '3.000' ) ).
    DATA(lt_controls) = VALUE
      zcl_purchase_order_service=>ty_suggestion_po_controls(
        ( suggestion_index  = 1
          purchasing_unit   = 'BOX'
          order_to_base_num = 5
          order_to_base_den = 1 ) ).

    DATA(ls_prepared_request) = mo_cut->prepare_from_suggestions(
      is_header              = ls_header
      it_suggestions         = lt_suggestions
      it_purchasing_controls = lt_controls ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = ls_prepared_request-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_prepared_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = ls_prepared_request-items[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1.000'
      act = ls_prepared_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001234'
      act = ls_prepared_request-items[ 1 ]-source_info_record ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).

    DATA(ls_result) = mo_cut->create_from_suggestions(
      is_header              = ls_header
      it_suggestions         = lt_suggestions
      it_purchasing_controls = lt_controls ).
    DATA(ls_api_request) = mo_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = ls_api_request-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_api_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = ls_api_request-items[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1.000'
      act = ls_api_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001234'
      act = ls_api_request-items[ 1 ]-source_info_record ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000001'
      act = ls_api_request-items[ 2 ]-source_agreement ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD groups_suggestions_by_vendor.
    DATA(ls_header) = build_request( ).
    CLEAR: ls_header-items, ls_header-vendor, ls_header-purchasing_org.
    DATA(lt_suggestions) = VALUE
      zcl_prod_comp_service=>ty_comp_replenishments(
        ( material                = 'MAT-1'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261101'
          procurement_type        = 'F'
          source_vendor           = '0000100001'
          source_purchasing_org   = '1000'
          source_info_record      = '0000001234'
          suggested_base_quantity = '5.000' )
        ( material                = 'MAT-2'
          plant                   = '2000'
          base_unit               = 'EA'
          required_date           = '20261108'
          procurement_type        = 'F'
          source_vendor           = '0000100002'
          source_purchasing_org   = '2000'
          source_info_record      = '0000005678'
          suggested_base_quantity = '3.000' )
        ( material                = 'MAT-3'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261115'
          procurement_type        = 'F'
          source_vendor           = '0000100001'
          source_purchasing_org   = '1000'
          source_agreement        = '4500000001'
          source_agreement_item   = '00010'
          suggested_base_quantity = '10.000' ) ).
    DATA(lt_controls) = VALUE
      zcl_purchase_order_service=>ty_suggestion_po_controls(
        ( suggestion_index  = 3
          purchasing_unit   = 'BOX'
          order_to_base_num = 5
          order_to_base_den = 1 ) ).
    mo_api->set_write_results(
      it_results = VALUE #(
        ( is_successful         = abap_true
          purchase_order_number = '4500000501' )
        ( is_successful         = abap_true
          purchase_order_number = '4500000502' ) ) ).

    DATA(lt_prepared_requests) = mo_cut->prepare_from_suggestions_bulk(
      is_header              = ls_header
      it_suggestions         = lt_suggestions
      it_purchasing_controls = lt_controls ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_prepared_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_prepared_requests[ 1 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1'
      act = lt_prepared_requests[ 1 ]-items[ 1 ]-source_request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '3'
      act = lt_prepared_requests[ 1 ]-items[ 2 ]-source_request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2.000'
      act = lt_prepared_requests[ 1 ]-items[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100002'
      act = lt_prepared_requests[ 2 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).

    DATA(ls_result) = mo_cut->create_from_suggestions_bulk(
      is_header              = ls_header
      it_suggestions         = lt_suggestions
      it_purchasing_controls = lt_controls ).
    DATA(lt_requests) = mo_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_requests[ 1 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_requests[ 1 ]-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1'
      act = lt_requests[ 1 ]-items[ 1 ]-source_request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '3'
      act = lt_requests[ 1 ]-items[ 2 ]-source_request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2.000'
      act = lt_requests[ 1 ]-items[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100002'
      act = lt_requests[ 2 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD continues_vendor_batch.
    DATA(ls_header) = build_request( ).
    CLEAR: ls_header-items, ls_header-vendor, ls_header-purchasing_org.
    DATA(lt_suggestions) = VALUE
      zcl_prod_comp_service=>ty_comp_replenishments(
        ( material                = 'MAT-1'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261101'
          procurement_type        = 'F'
          source_vendor           = '0000100001'
          source_purchasing_org   = '1000'
          source_info_record      = '0000001234'
          suggested_base_quantity = '5.000' )
        ( material                = 'MAT-2'
          plant                   = '2000'
          base_unit               = 'EA'
          required_date           = '20261108'
          procurement_type        = 'F'
          source_vendor           = '0000100002'
          source_purchasing_org   = '2000'
          source_info_record      = '0000005678'
          suggested_base_quantity = '3.000' ) ).
    mo_api->set_write_results(
      it_results = VALUE #(
        ( messages = VALUE #( (
          type    = 'E'
          message = 'Vendor order rejected' ) ) )
        ( is_successful         = abap_true
          purchase_order_number = '4500000502' ) ) ).

    DATA(ls_result) = mo_cut->create_from_suggestions_bulk(
      is_header      = ls_header
      it_suggestions = lt_suggestions ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Vendor order rejected'
      act = ls_result-order_results[ 1 ]-messages[ 1 ]-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000502'
      act = ls_result-order_results[ 2 ]-purchase_order_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD validates_vendor_groups.
    DATA(ls_header) = build_request( ).
    CLEAR: ls_header-items, ls_header-vendor, ls_header-purchasing_org.
    DATA(lt_suggestions) = VALUE
      zcl_prod_comp_service=>ty_comp_replenishments(
        ( material                = 'MAT-1'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261101'
          procurement_type        = 'F'
          source_vendor           = '0000100001'
          source_purchasing_org   = '1000'
          source_info_record      = '0000001234'
          suggested_base_quantity = '5.000' )
        ( material                = 'MAT-2'
          plant                   = '2000'
          base_unit               = 'EA'
          required_date           = '20261108'
          procurement_type        = 'F'
          source_vendor           = '0000100002'
          source_purchasing_org   = '2000'
          source_agreement        = '4500000001'
          suggested_base_quantity = '3.000' ) ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->create_from_suggestions_bulk(
          is_header      = ls_header
          it_suggestions = lt_suggestions ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD skips_empty_vendor_batch.
    DATA(ls_header) = build_request( ).
    CLEAR: ls_header-items, ls_header-vendor, ls_header-purchasing_org.
    DATA(lt_suggestions) = VALUE
      zcl_prod_comp_service=>ty_comp_replenishments( (
        material                = 'MAT-1'
        plant                   = '1000'
        base_unit               = 'EA'
        required_date           = '20261101'
        suggested_base_quantity = 0 ) ).

    DATA(ls_result) = mo_cut->create_from_suggestions_bulk(
      is_header      = ls_header
      it_suggestions = lt_suggestions ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-order_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'S'
      act = ls_result-order_results[ 1 ]-messages[ 1 ]-type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD creates_suggestion_pos_atomic.
    DATA(ls_header) = build_request( ).
    CLEAR: ls_header-items, ls_header-vendor, ls_header-purchasing_org.
    DATA(lt_suggestions) = VALUE
      zcl_prod_comp_service=>ty_comp_replenishments(
        ( material                = 'MAT-1'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261101'
          procurement_type        = 'F'
          source_vendor           = '0000100001'
          source_purchasing_org   = '1000'
          source_info_record      = '0000001234'
          suggested_base_quantity = '10.000' )
        ( material                = 'MAT-2'
          plant                   = '2000'
          base_unit               = 'EA'
          required_date           = '20261108'
          procurement_type        = 'F'
          source_vendor           = '0000100002'
          source_purchasing_org   = '2000'
          source_info_record      = '0000005678'
          suggested_base_quantity = '3.000' ) ).
    DATA(lt_controls) = VALUE
      zcl_purchase_order_service=>ty_suggestion_po_controls(
        ( suggestion_index  = 1
          purchasing_unit   = 'BOX'
          order_to_base_num = 5
          order_to_base_den = 1 ) ).
    mo_api->set_write_results(
      it_results = VALUE #(
        ( is_successful         = abap_true
          purchase_order_number = '4500000601' )
        ( is_successful         = abap_true
          purchase_order_number = '4500000602' ) ) ).

    DATA(ls_result) = mo_cut->create_from_suggestions_atomic(
      is_header              = ls_header
      it_suggestions         = lt_suggestions
      it_purchasing_controls = lt_controls ).
    DATA(lt_requests) = mo_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_requests[ 1 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lt_requests[ 1 ]-items[ 1 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2.000'
      act = lt_requests[ 1 ]-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1'
      act = lt_requests[ 1 ]-items[ 1 ]-source_request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100002'
      act = lt_requests[ 2 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_suggestion_atomic.
    DATA(ls_header) = build_request( ).
    CLEAR: ls_header-items, ls_header-vendor, ls_header-purchasing_org.
    DATA(lt_suggestions) = VALUE
      zcl_prod_comp_service=>ty_comp_replenishments(
        ( material                = 'MAT-1'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261101'
          procurement_type        = 'F'
          source_vendor           = '0000100001'
          source_purchasing_org   = '1000'
          source_info_record      = '0000001234'
          suggested_base_quantity = '5.000' )
        ( material                = 'MAT-2'
          plant                   = '2000'
          base_unit               = 'EA'
          required_date           = '20261108'
          procurement_type        = 'F'
          source_vendor           = '0000100002'
          source_purchasing_org   = '2000'
          source_info_record      = '0000005678'
          suggested_base_quantity = '3.000' ) ).
    mo_api->set_write_results(
      it_results = VALUE #(
        ( is_successful         = abap_true
          purchase_order_number = '4500000611' )
        ( messages = VALUE #( (
          type    = 'E'
          message = 'Vendor order rejected' ) ) ) ) ).

    DATA(ls_result) = mo_cut->create_from_suggestions_atomic(
      is_header      = ls_header
      it_suggestions = lt_suggestions ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-order_results ) ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-order_results[ 1 ]-purchase_order_number ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-order_results[ 2 ]-purchase_order_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD skips_empty_atomic_suggestions.
    DATA(ls_header) = build_request( ).
    CLEAR: ls_header-items, ls_header-vendor, ls_header-purchasing_org.
    DATA(lt_suggestions) = VALUE
      zcl_prod_comp_service=>ty_comp_replenishments( (
        material                = 'MAT-1'
        plant                   = '1000'
        base_unit               = 'EA'
        required_date           = '20261101'
        suggested_base_quantity = 0 ) ).

    DATA(ls_result) = mo_cut->create_from_suggestions_atomic(
      is_header      = ls_header
      it_suggestions = lt_suggestions ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-order_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'S'
      act = ls_result-order_results[ 1 ]-messages[ 1 ]-type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_mismatched_suggestion.
    DATA(ls_header) = build_request( ).
    CLEAR ls_header-items.
    DATA(lt_suggestions) = VALUE
      zcl_prod_comp_service=>ty_comp_replenishments( (
        material                = 'MAT-1'
        plant                   = '1000'
        base_unit               = 'EA'
        required_date           = '20261101'
        procurement_type        = 'F'
        source_vendor           = '0000100002'
        source_purchasing_org   = '1000'
        source_info_record      = '0000001234'
        suggested_base_quantity = '5.000' ) ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->create_from_suggestions(
          is_header      = ls_header
          it_suggestions = lt_suggestions ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD skips_zero_suggestions.
    DATA(ls_header) = build_request( ).
    CLEAR ls_header-items.
    DATA(lt_suggestions) = VALUE
      zcl_prod_comp_service=>ty_comp_replenishments( (
        material                = 'MAT-1'
        plant                   = '1000'
        base_unit               = 'EA'
        required_date           = '20261101'
        suggested_base_quantity = 0 ) ).

    DATA(ls_result) = mo_cut->create_from_suggestions(
      is_header      = ls_header
      it_suggestions = lt_suggestions ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'S'
      act = ls_result-messages[ 1 ]-type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD creates_po_from_pr_items.
    DATA(ls_header) = build_request( ).
    CLEAR ls_header-items.
    DATA(lt_requisition_items) = VALUE
      zif_purchase_requisition_api=>ty_requisition_items(
        ( item_number      = '00010'
          material         = 'MAT-1'
          plant            = '1000'
          storage_location = '0001'
          quantity         = '8.000'
          ordered_quantity = '3.000'
          unit             = 'EA'
          delivery_date    = '20261101'
          purchasing_org   = '1000'
          source_vendor    = '0000100001' )
        ( item_number    = '00020'
          material       = 'MAT-2'
          plant          = '1000'
          quantity       = '2.000'
          unit           = 'EA'
          delivery_date  = '20261108'
          purchasing_org = '1000'
          source_vendor  = '0000100001' ) ).

    DATA(ls_prepared_request) = mo_cut->prepare_from_requisition_items(
      is_header             = ls_header
      iv_requisition_number = '0010001234'
      it_requisition_items  = lt_requisition_items ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_prepared_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '5.000'
      act = ls_prepared_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010001234'
      act = ls_prepared_request-items[ 1 ]-purchase_requisition ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00010'
      act = ls_prepared_request-items[ 1 ]-requisition_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).

    DATA(ls_result) = mo_cut->create_from_requisition_items(
      is_header             = ls_header
      iv_requisition_number = '0010001234'
      it_requisition_items  = lt_requisition_items ).
    DATA(ls_request) = mo_api->get_request( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '5.000'
      act = ls_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010001234'
      act = ls_request-items[ 1 ]-purchase_requisition ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00010'
      act = ls_request-items[ 1 ]-requisition_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010001234/00010'
      act = ls_request-items[ 1 ]-source_request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD validates_pr_items_first.
    DATA(ls_header) = build_request( ).
    CLEAR ls_header-items.
    DATA(lt_requisition_items) = VALUE
      zif_purchase_requisition_api=>ty_requisition_items(
        ( item_number    = '00010'
          material       = 'MAT-1'
          plant          = '1000'
          quantity       = '5.000'
          unit           = 'EA'
          delivery_date  = '20261101'
          purchasing_org = '1000'
          source_vendor  = '0000100001' )
        ( item_number    = '00020'
          material       = 'MAT-2'
          plant          = '1000'
          quantity       = '2.000'
          unit           = 'EA'
          delivery_date  = '20261108'
          purchasing_org = '1000'
          source_vendor  = '0000100002' ) ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->create_from_requisition_items(
          is_header             = ls_header
          iv_requisition_number = '0010001234'
          it_requisition_items  = lt_requisition_items ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD groups_selected_prs_by_vendor.
    DATA(ls_header) = build_request( ).
    CLEAR: ls_header-items, ls_header-vendor, ls_header-purchasing_org.
    DATA lt_selected_items TYPE
      zcl_purchase_order_service=>ty_selected_requisition_items.
    DATA(ls_first) = build_selected_pr_item(
      iv_requisition_number = '0010001001'
      iv_vendor             = '0000100001'
      iv_purchasing_org     = '1000'
      iv_item_number        = '00010'
      iv_material           = 'MAT-1'
      iv_quantity           = '6.000'
      iv_ordered_quantity   = '2.000' ).
    DATA(ls_second) = build_selected_pr_item(
      iv_requisition_number = '0010001002'
      iv_vendor             = '0000100002'
      iv_purchasing_org     = '2000'
      iv_item_number        = '00010'
      iv_material           = 'MAT-2'
      iv_quantity           = '3.000'
      iv_ordered_quantity   = 0 ).
    DATA(ls_third) = build_selected_pr_item(
      iv_requisition_number = '0010001003'
      iv_vendor             = '0000100001'
      iv_purchasing_org     = '1000'
      iv_item_number        = '00020'
      iv_material           = 'MAT-3'
      iv_quantity           = '5.000'
      iv_ordered_quantity   = '1.000' ).
    APPEND ls_first TO lt_selected_items.
    APPEND ls_second TO lt_selected_items.
    APPEND ls_third TO lt_selected_items.
    mo_api->set_write_results(
      it_results = VALUE #(
        ( is_successful         = abap_true
          purchase_order_number = '4500000601' )
        ( is_successful         = abap_true
          purchase_order_number = '4500000602' ) ) ).

    DATA(lt_prepared_requests) = mo_cut->prepare_from_requisitions(
      is_header         = ls_header
      it_selected_items = lt_selected_items ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_prepared_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_prepared_requests[ 1 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_prepared_requests[ 1 ]-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4.000'
      act = lt_prepared_requests[ 1 ]-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010001003/00020'
      act = lt_prepared_requests[ 1 ]-items[ 2 ]-source_request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100002'
      act = lt_prepared_requests[ 2 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010001002'
      act = lt_prepared_requests[ 2 ]-items[ 1 ]-purchase_requisition ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).

    DATA(ls_result) = mo_cut->create_from_requisitions_bulk(
      is_header         = ls_header
      it_selected_items = lt_selected_items ).
    DATA(lt_requests) = mo_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_requests[ 1 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = lt_requests[ 1 ]-purchasing_org ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_requests[ 1 ]-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4.000'
      act = lt_requests[ 1 ]-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010001003/00020'
      act = lt_requests[ 1 ]-items[ 2 ]-source_request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100002'
      act = lt_requests[ 2 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010001002'
      act = lt_requests[ 2 ]-items[ 1 ]-purchase_requisition ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD continues_pr_po_batch.
    DATA(ls_header) = build_request( ).
    CLEAR: ls_header-items, ls_header-vendor, ls_header-purchasing_org.
    DATA lt_selected_items TYPE
      zcl_purchase_order_service=>ty_selected_requisition_items.
    DATA(ls_first) = build_selected_pr_item(
      iv_requisition_number = '0010001001'
      iv_vendor             = '0000100001'
      iv_purchasing_org     = '1000'
      iv_item_number        = '00010'
      iv_material           = 'MAT-1'
      iv_quantity           = '5.000'
      iv_ordered_quantity   = 0 ).
    DATA(ls_second) = build_selected_pr_item(
      iv_requisition_number = '0010001002'
      iv_vendor             = '0000100002'
      iv_purchasing_org     = '2000'
      iv_item_number        = '00010'
      iv_material           = 'MAT-2'
      iv_quantity           = '3.000'
      iv_ordered_quantity   = 0 ).
    APPEND ls_first TO lt_selected_items.
    APPEND ls_second TO lt_selected_items.
    mo_api->set_write_results(
      it_results = VALUE #(
        ( messages = VALUE #( (
          type    = 'E'
          message = 'PR order rejected' ) ) )
        ( is_successful         = abap_true
          purchase_order_number = '4500000602' ) ) ).

    DATA(ls_result) = mo_cut->create_from_requisitions_bulk(
      is_header         = ls_header
      it_selected_items = lt_selected_items ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PR order rejected'
      act = ls_result-order_results[ 1 ]-messages[ 1 ]-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-order_results[ 2 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD validates_selected_pr_groups.
    DATA(ls_header) = build_request( ).
    CLEAR: ls_header-items, ls_header-vendor, ls_header-purchasing_org.
    DATA lt_selected_items TYPE
      zcl_purchase_order_service=>ty_selected_requisition_items.
    DATA(ls_first) = build_selected_pr_item(
      iv_requisition_number = '0010001001'
      iv_vendor             = '0000100001'
      iv_purchasing_org     = '1000'
      iv_item_number        = '00010'
      iv_material           = 'MAT-1'
      iv_quantity           = '5.000'
      iv_ordered_quantity   = 0 ).
    DATA(ls_second) = build_selected_pr_item(
      iv_requisition_number = '0010001002'
      iv_vendor             = '0000100002'
      iv_purchasing_org     = '2000'
      iv_item_number        = '00010'
      iv_material           = 'MAT-2'
      iv_quantity           = '3.000'
      iv_ordered_quantity   = 0 ).
    ls_second-item-source_vendor = '0000100001'.
    APPEND ls_first TO lt_selected_items.
    APPEND ls_second TO lt_selected_items.
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->create_from_requisitions_bulk(
          is_header         = ls_header
          it_selected_items = lt_selected_items ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD creates_pr_pos_atomic.
    DATA(ls_header) = build_request( ).
    CLEAR: ls_header-items, ls_header-vendor, ls_header-purchasing_org.
    DATA lt_selected_items TYPE
      zcl_purchase_order_service=>ty_selected_requisition_items.
    DATA(ls_first) = build_selected_pr_item(
      iv_requisition_number = '0010001001'
      iv_vendor             = '0000100001'
      iv_purchasing_org     = '1000'
      iv_item_number        = '00010'
      iv_material           = 'MAT-1'
      iv_quantity           = '5.000'
      iv_ordered_quantity   = 0 ).
    DATA(ls_second) = build_selected_pr_item(
      iv_requisition_number = '0010001002'
      iv_vendor             = '0000100002'
      iv_purchasing_org     = '2000'
      iv_item_number        = '00010'
      iv_material           = 'MAT-2'
      iv_quantity           = '3.000'
      iv_ordered_quantity   = 0 ).
    APPEND ls_first TO lt_selected_items.
    APPEND ls_second TO lt_selected_items.
    mo_api->set_write_results(
      it_results = VALUE #(
        ( is_successful         = abap_true
          purchase_order_number = '4500000701' )
        ( is_successful         = abap_true
          purchase_order_number = '4500000702' ) ) ).

    DATA(ls_result) = mo_cut->create_requisitions_atomic(
      is_header         = ls_header
      it_selected_items = lt_selected_items ).
    DATA(lt_requests) = mo_api->get_requests( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_requests ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010001002'
      act = lt_requests[ 2 ]-items[ 1 ]-purchase_requisition ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_pr_po_batch.
    DATA(ls_header) = build_request( ).
    CLEAR: ls_header-items, ls_header-vendor, ls_header-purchasing_org.
    DATA lt_selected_items TYPE
      zcl_purchase_order_service=>ty_selected_requisition_items.
    DATA(ls_first) = build_selected_pr_item(
      iv_requisition_number = '0010001001'
      iv_vendor             = '0000100001'
      iv_purchasing_org     = '1000'
      iv_item_number        = '00010'
      iv_material           = 'MAT-1'
      iv_quantity           = '5.000'
      iv_ordered_quantity   = 0 ).
    DATA(ls_second) = build_selected_pr_item(
      iv_requisition_number = '0010001002'
      iv_vendor             = '0000100002'
      iv_purchasing_org     = '2000'
      iv_item_number        = '00010'
      iv_material           = 'MAT-2'
      iv_quantity           = '3.000'
      iv_ordered_quantity   = 0 ).
    APPEND ls_first TO lt_selected_items.
    APPEND ls_second TO lt_selected_items.
    mo_api->set_write_results(
      it_results = VALUE #(
        ( is_successful         = abap_true
          purchase_order_number = '4500000701' )
        ( messages = VALUE #( (
          type    = 'E'
          message = 'PR order rejected' ) ) ) ) ).

    DATA(ls_result) = mo_cut->create_requisitions_atomic(
      is_header         = ls_header
      it_selected_items = lt_selected_items ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PR order rejected'
      act = ls_result-order_results[ 2 ]-messages[ 1 ]-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 1 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010001001'
      act = ls_result-order_results[ 1 ]-submitted_items[ 1 ]-purchase_requisition ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-order_results[ 1 ]-purchase_order_number ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-order_results[ 2 ]-purchase_order_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD changes_order_schedules.
    DATA(lt_changes) = VALUE zif_purchase_order_api=>ty_schedule_changes(
      ( item_number          = '00010'
        schedule_line        = '0001'
        change_delivery_date = abap_true
        delivery_date        = '20261201' )
      ( item_number     = '00020'
        schedule_line   = '0002'
        change_quantity = abap_true
        quantity        = '4.000' ) ).

    DATA(ls_result) = mo_cut->change_order_schedules(
      iv_purchase_order_number = '4500000100'
      it_schedule_changes      = lt_changes ).
    DATA(lt_submitted) = mo_api->get_changed_schedules( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000100'
      act = mo_api->get_changed_order( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_submitted ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261201'
      act = lt_submitted[ 1 ]-delivery_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4.000'
      act = lt_submitted[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD continues_schedule_batch.
    DATA(lt_changes) = VALUE zcl_purchase_order_service=>ty_order_schedule_changes(
        ( purchase_order_number = '4500000101'
          schedule_changes      = VALUE #( (
            item_number          = '00010'
            schedule_line        = '0001'
            change_delivery_date = abap_true
            delivery_date        = '20261201' ) ) )
        ( purchase_order_number = '4500000102'
          schedule_changes      = VALUE #( (
            item_number     = '00010'
            schedule_line   = '0001'
            change_quantity = abap_true
            quantity        = '6.000' ) ) ) ).
    mo_api->set_item_change_results(
      it_results = VALUE #(
        ( messages = VALUE #( (
          type    = 'E'
          message = 'Schedule update rejected' ) ) )
        ( is_successful = abap_true ) ) ).

    DATA(ls_result) = mo_cut->change_order_schedules_bulk(
      it_changes = lt_changes ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Schedule update rejected'
      act = ls_result-order_results[ 1 ]-messages[ 1 ]-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-order_results[ 2 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->get_item_change_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD validates_schedule_batch_first.
    DATA(lt_changes) = VALUE zcl_purchase_order_service=>ty_order_schedule_changes(
        ( purchase_order_number = '4500000101'
          schedule_changes      = VALUE #( (
            item_number          = '00010'
            schedule_line        = '0001'
            change_delivery_date = abap_true
            delivery_date        = '20261201' ) ) )
        ( purchase_order_number = '4500000102'
          schedule_changes      = VALUE #( (
            item_number   = '00010'
            schedule_line = '0001' ) ) ) ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->change_order_schedules_bulk( it_changes = lt_changes ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_item_change_count( ) ).
  ENDMETHOD.

  METHOD changes_schedules_atomic.
    DATA(lt_changes) = VALUE zcl_purchase_order_service=>ty_order_schedule_changes(
        ( purchase_order_number = '4500000101'
          schedule_changes      = VALUE #( (
            item_number          = '00010'
            schedule_line        = '0001'
            change_delivery_date = abap_true
            delivery_date        = '20261201' ) ) )
        ( purchase_order_number = '4500000102'
          schedule_changes      = VALUE #( (
            item_number     = '00020'
            schedule_line   = '0002'
            change_quantity = abap_true
            quantity        = '6.000' ) ) ) ).
    mo_api->set_item_change_results(
      it_results = VALUE #(
        ( is_successful = abap_true )
        ( is_successful = abap_true ) ) ).

    DATA(ls_result) = mo_cut->change_order_schedules_atomic(
      it_changes = lt_changes ).

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
      exp = '4500000101'
      act = ls_result-order_results[ 1 ]-purchase_order_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261201'
      act = ls_result-order_results[ 1 ]-submitted_schedules[ 1 ]-delivery_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000102'
      act = ls_result-order_results[ 2 ]-purchase_order_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->get_item_change_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_schedule_atomic.
    DATA(lt_changes) = VALUE zcl_purchase_order_service=>ty_order_schedule_changes(
        ( purchase_order_number = '4500000101'
          schedule_changes      = VALUE #( (
            item_number          = '00010'
            schedule_line        = '0001'
            change_delivery_date = abap_true
            delivery_date        = '20261201' ) ) )
        ( purchase_order_number = '4500000102'
          schedule_changes      = VALUE #( (
            item_number     = '00020'
            schedule_line   = '0002'
            change_quantity = abap_true
            quantity        = '6.000' ) ) ) ).
    mo_api->set_item_change_results(
      it_results = VALUE #(
        ( is_successful = abap_true )
        ( messages = VALUE #( (
          type    = 'E'
          message = 'Schedule update rejected' ) ) ) ) ).

    DATA(ls_result) = mo_cut->change_order_schedules_atomic(
      it_changes = lt_changes ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 1 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 2 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000101'
      act = ls_result-order_results[ 1 ]-purchase_order_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD fails_atomic_schedule_commit.
    DATA(lt_changes) = VALUE zcl_purchase_order_service=>ty_order_schedule_changes(
        ( purchase_order_number = '4500000101'
          schedule_changes      = VALUE #( (
            item_number          = '00010'
            schedule_line        = '0001'
            change_delivery_date = abap_true
            delivery_date        = '20261201' ) ) )
        ( purchase_order_number = '4500000102'
          schedule_changes      = VALUE #( (
            item_number     = '00020'
            schedule_line   = '0002'
            change_quantity = abap_true
            quantity        = '6.000' ) ) ) ).
    mo_api->set_item_change_results(
      it_results = VALUE #(
        ( is_successful = abap_true )
        ( is_successful = abap_true ) ) ).
    mo_api->set_commit_result(
      is_result = VALUE #(
        is_successful = abap_false
        message       = VALUE #(
          type    = 'E'
          message = 'Commit failed' ) ) ).

    DATA(ls_result) = mo_cut->change_order_schedules_atomic(
      it_changes = lt_changes ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000102'
      act = ls_result-order_results[ 2 ]-purchase_order_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Commit failed'
      act = ls_result-commit_result-message-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD prevalidates_atomic_scheds.
    DATA(lt_changes) = VALUE zcl_purchase_order_service=>ty_order_schedule_changes(
        ( purchase_order_number = '4500000101'
          schedule_changes      = VALUE #( (
            item_number          = '00010'
            schedule_line        = '0001'
            change_delivery_date = abap_true
            delivery_date        = '20261201' ) ) )
        ( purchase_order_number = '4500000102'
          schedule_changes      = VALUE #( (
            item_number   = '00020'
            schedule_line = '0002' ) ) ) ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->change_order_schedules_atomic( it_changes = lt_changes ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_item_change_count( ) ).
  ENDMETHOD.

  METHOD changes_item_quantities.
    DATA(lt_changes) = VALUE zif_purchase_order_api=>ty_item_quantity_changes(
      ( item_number = '00010' quantity = '8.000' )
      ( item_number = '00020' quantity = '3.500' ) ).

    DATA(ls_result) = mo_cut->change_item_quantities(
      iv_purchase_order_number = '4500000100'
      it_item_changes          = lt_changes ).
    DATA(lt_submitted) = mo_api->get_changed_item_quantities( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000100'
      act = mo_api->get_changed_order( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_submitted ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '8.000'
      act = lt_submitted[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '3.500'
      act = ls_result-submitted_item_quantities[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD continues_quantity_bulk.
    DATA(lt_changes) = VALUE zcl_purchase_order_service=>ty_order_qty_changes(
        ( purchase_order_number = '4500000101'
          item_changes          = VALUE #( (
            item_number = '00010'
            quantity    = '8.000' ) ) )
        ( purchase_order_number = '4500000102'
          item_changes          = VALUE #( (
            item_number = '00020'
            quantity    = '6.000' ) ) ) ).
    mo_api->set_item_change_results(
      it_results = VALUE #(
        ( messages = VALUE #( (
          type    = 'E'
          message = 'Quantity update rejected' ) ) )
        ( is_successful = abap_true ) ) ).

    DATA(ls_result) = mo_cut->change_item_quantities_bulk(
      it_changes = lt_changes ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Quantity update rejected'
      act = ls_result-order_results[ 1 ]-messages[ 1 ]-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-order_results[ 2 ]-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->get_item_change_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD changes_quantities_atomic.
    DATA(lt_changes) = VALUE zcl_purchase_order_service=>ty_order_qty_changes(
        ( purchase_order_number = '4500000101'
          item_changes          = VALUE #( (
            item_number = '00010'
            quantity    = '8.000' ) ) )
        ( purchase_order_number = '4500000102'
          item_changes          = VALUE #( (
            item_number = '00020'
            quantity    = '6.000' ) ) ) ).
    mo_api->set_item_change_results(
      it_results = VALUE #(
        ( is_successful = abap_true )
        ( is_successful = abap_true ) ) ).

    DATA(ls_result) = mo_cut->change_item_quantities_atomic(
      it_changes = lt_changes ).

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
      exp = '4500000101'
      act = ls_result-order_results[ 1 ]-purchase_order_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '8.000'
      act = ls_result-order_results[ 1 ]-submitted_item_quantities[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->get_item_change_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_quantity_batch.
    DATA(lt_changes) = VALUE zcl_purchase_order_service=>ty_order_qty_changes(
        ( purchase_order_number = '4500000101'
          item_changes          = VALUE #( (
            item_number = '00010'
            quantity    = '8.000' ) ) )
        ( purchase_order_number = '4500000102'
          item_changes          = VALUE #( (
            item_number = '00020'
            quantity    = '6.000' ) ) ) ).
    mo_api->set_item_change_results(
      it_results = VALUE #(
        ( is_successful = abap_true )
        ( messages = VALUE #( (
          type    = 'E'
          message = 'Quantity update rejected' ) ) ) ) ).

    DATA(ls_result) = mo_cut->change_item_quantities_atomic(
      it_changes = lt_changes ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 1 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD prevalidates_quantity_batch.
    DATA(lt_changes) = VALUE zcl_purchase_order_service=>ty_order_qty_changes(
        ( purchase_order_number = '4500000101'
          item_changes          = VALUE #( (
            item_number = '00010'
            quantity    = '8.000' ) ) )
        ( purchase_order_number = '4500000102'
          item_changes          = VALUE #( (
            item_number = '00020'
            quantity    = 0 ) ) ) ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->change_item_quantities_atomic( it_changes = lt_changes ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_item_change_count( ) ).
  ENDMETHOD.

  METHOD fails_quantity_commit.
    DATA(lt_changes) = VALUE zcl_purchase_order_service=>ty_order_qty_changes(
      ( purchase_order_number = '4500000101'
        item_changes          = VALUE #( (
          item_number = '00010'
          quantity    = '8.000' ) ) ) ).
    mo_api->set_item_change_results(
      it_results = VALUE #( ( is_successful = abap_true ) ) ).
    mo_api->set_commit_result(
      is_result = VALUE #(
        is_successful = abap_false
        message       = VALUE #(
          type    = 'E'
          message = 'Commit failed' ) ) ).

    DATA(ls_result) = mo_cut->change_item_quantities_atomic(
      it_changes = lt_changes ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Commit failed'
      act = ls_result-commit_result-message-message ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 1 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD changes_base_qty.
    DATA(lo_uom_repository) = NEW lcl_po_uom_repository( ).
    lo_uom_repository->set_material_data(
      iv_material         = 'MAT-PO'
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    mo_api->set_read_result(
      is_result = VALUE #(
        purchase_order_number = '4500000100'
        is_successful         = abap_true
        items                 = VALUE #( (
          item_number = '00010'
          material    = 'MAT-PO'
          unit        = 'BOX' ) ) ) ).
    DATA(lo_cut) = NEW zcl_purchase_order_service(
      io_api           = mo_api
      io_uom_converter = lo_converter ).

    DATA(ls_result) = lo_cut->change_qty_from_base(
      iv_purchase_order_number = '4500000100'
      it_item_changes          = VALUE #( (
        item_number   = '00010'
        base_quantity = '24.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2.000'
      act = ls_result-submitted_item_quantities[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD validates_base_qty_bulk_first.
    DATA(lo_uom_repository) = NEW lcl_po_uom_repository( ).
    lo_uom_repository->set_material_data(
      iv_material         = 'MAT-PO'
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    mo_api->set_read_results(
      it_results = VALUE #(
        ( is_successful = abap_true
          items         = VALUE #( (
            item_number = '00010'
            material    = 'MAT-PO'
            unit        = 'BOX' ) ) )
        ( is_successful = abap_false ) ) ).
    DATA(lo_cut) = NEW zcl_purchase_order_service(
      io_api           = mo_api
      io_uom_converter = lo_converter ).
    DATA(lv_exception_raised) = abap_false.

    TRY.
        lo_cut->change_qty_from_base_bulk(
          it_changes = VALUE #(
            ( purchase_order_number = '4500000101'
              item_changes          = VALUE #( (
                item_number   = '00010'
                base_quantity = '24.000' ) ) )
            ( purchase_order_number = '4500000102'
              item_changes          = VALUE #( (
                item_number   = '00010'
                base_quantity = '12.000' ) ) ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_item_change_count( ) ).
  ENDMETHOD.

  METHOD changes_base_qty_atomically.
    DATA(lo_uom_repository) = NEW lcl_po_uom_repository( ).
    lo_uom_repository->set_material_data(
      iv_material         = 'MAT-PO'
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    mo_api->set_read_results(
      it_results = VALUE #(
        ( is_successful = abap_true
          items         = VALUE #( (
            item_number = '00010'
            material    = 'MAT-PO'
            unit        = 'BOX' ) ) )
        ( is_successful = abap_true
          items         = VALUE #( (
            item_number = '00020'
            material    = 'MAT-PO'
            unit        = 'BOX' ) ) ) ) ).
    mo_api->set_item_change_results(
      it_results = VALUE #(
        ( is_successful = abap_true )
        ( is_successful = abap_true ) ) ).
    DATA(lo_cut) = NEW zcl_purchase_order_service(
      io_api           = mo_api
      io_uom_converter = lo_converter ).

    DATA(ls_result) = lo_cut->change_qty_from_base_atomic(
      it_changes = VALUE #(
        ( purchase_order_number = '4500000101'
          item_changes          = VALUE #( (
            item_number   = '00010'
            base_quantity = '24.000' ) ) )
        ( purchase_order_number = '4500000102'
          item_changes          = VALUE #( (
            item_number   = '00020'
            base_quantity = '36.000' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2.000'
      act = ls_result-order_results[ 1 ]-submitted_item_quantities[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '3.000'
      act = ls_result-order_results[ 2 ]-submitted_item_quantities[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_unconvertible_base_qty.
    DATA(lo_uom_repository) = NEW lcl_po_uom_repository( ).
    lo_uom_repository->set_material_data(
      iv_material         = 'MAT-PO'
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'PAL'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    mo_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        items         = VALUE #( (
          item_number = '00010'
          material    = 'MAT-PO'
          unit        = 'BOX' ) ) ) ).
    DATA(lo_cut) = NEW zcl_purchase_order_service(
      io_api           = mo_api
      io_uom_converter = lo_converter ).
    DATA(lv_exception_raised) = abap_false.

    TRY.
        lo_cut->change_qty_from_base(
          iv_purchase_order_number = '4500000100'
          it_item_changes          = VALUE #( (
            item_number   = '00010'
            base_quantity = '24.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_item_change_count( ) ).
  ENDMETHOD.

  METHOD changes_sched_base.
    DATA(lo_uom_repository) = NEW lcl_po_uom_repository( ).
    lo_uom_repository->set_material_data(
      iv_material         = 'MAT-PO'
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    mo_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        items         = VALUE #( (
          item_number = '00010'
          material    = 'MAT-PO'
          unit        = 'BOX' ) ) ) ).
    DATA(lo_cut) = NEW zcl_purchase_order_service(
      io_api           = mo_api
      io_uom_converter = lo_converter ).

    DATA(ls_result) = lo_cut->change_base_schedules(
      iv_purchase_order_number = '4500000100'
      it_schedule_changes      = VALUE #(
        ( item_number     = '00010'
          schedule_line   = '0001'
          change_quantity = abap_true
          base_quantity   = '36.000' )
        ( item_number          = '00010'
          schedule_line        = '0002'
          change_delivery_date = abap_true
          delivery_date        = '20261210' ) ) ).
    DATA(lt_submitted) = mo_api->get_changed_schedules( ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '3.000'
      act = lt_submitted[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261210'
      act = lt_submitted[ 2 ]-delivery_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD validates_base_sched_bulk.
    DATA(lo_uom_repository) = NEW lcl_po_uom_repository( ).
    lo_uom_repository->set_material_data(
      iv_material         = 'MAT-PO'
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    mo_api->set_read_results(
      it_results = VALUE #(
        ( is_successful = abap_true
          items         = VALUE #( (
            item_number = '00010'
            material    = 'MAT-PO'
            unit        = 'BOX' ) ) )
        ( is_successful = abap_false ) ) ).
    DATA(lo_cut) = NEW zcl_purchase_order_service(
      io_api           = mo_api
      io_uom_converter = lo_converter ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->change_base_schedules_bulk(
          it_changes = VALUE #(
            ( purchase_order_number = '4500000101'
              schedule_changes      = VALUE #( (
                item_number     = '00010'
                schedule_line   = '0001'
                change_quantity = abap_true
                base_quantity   = '24.000' ) ) )
            ( purchase_order_number = '4500000102'
              schedule_changes      = VALUE #( (
                item_number     = '00010'
                schedule_line   = '0001'
                change_quantity = abap_true
                base_quantity   = '12.000' ) ) ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_item_change_count( ) ).
  ENDMETHOD.

  METHOD changes_base_sched_atomically.
    DATA(lo_uom_repository) = NEW lcl_po_uom_repository( ).
    lo_uom_repository->set_material_data(
      iv_material         = 'MAT-PO'
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    mo_api->set_read_results(
      it_results = VALUE #(
        ( is_successful = abap_true
          items         = VALUE #( (
            item_number = '00010'
            material    = 'MAT-PO'
            unit        = 'BOX' ) ) )
        ( is_successful = abap_true
          items         = VALUE #( (
            item_number = '00020'
            material    = 'MAT-PO'
            unit        = 'BOX' ) ) ) ) ).
    mo_api->set_item_change_results(
      it_results = VALUE #(
        ( is_successful = abap_true )
        ( is_successful = abap_true ) ) ).
    DATA(lo_cut) = NEW zcl_purchase_order_service(
      io_api           = mo_api
      io_uom_converter = lo_converter ).

    DATA(ls_result) = lo_cut->change_base_schedules_atomic(
      it_changes = VALUE #(
        ( purchase_order_number = '4500000101'
          schedule_changes      = VALUE #( (
            item_number     = '00010'
            schedule_line   = '0001'
            change_quantity = abap_true
            base_quantity   = '24.000' ) ) )
        ( purchase_order_number = '4500000102'
          schedule_changes      = VALUE #( (
            item_number     = '00020'
            schedule_line   = '0001'
            change_quantity = abap_true
            base_quantity   = '36.000' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->get_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->get_item_change_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_sched_base_unit.
    DATA(lo_uom_repository) = NEW lcl_po_uom_repository( ).
    lo_uom_repository->set_material_data(
      iv_material         = 'MAT-PO'
      iv_base_unit        = 'EA'
      iv_alternative_unit = 'BOX'
      iv_numerator        = 12
      iv_denominator      = 1 ).
    DATA(lo_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    mo_api->set_read_result(
      is_result = VALUE #(
        is_successful = abap_true
        items         = VALUE #( (
          item_number = '00010'
          material    = 'MAT-PO'
          unit        = 'PAL' ) ) ) ).
    DATA(lo_cut) = NEW zcl_purchase_order_service(
      io_api           = mo_api
      io_uom_converter = lo_converter ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->change_base_schedules(
          iv_purchase_order_number = '4500000100'
          it_schedule_changes      = VALUE #( (
            item_number     = '00010'
            schedule_line   = '0001'
            change_quantity = abap_true
            base_quantity   = '24.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_item_change_count( ) ).
  ENDMETHOD.

  METHOD deletes_item_batch_atomic.
    DATA(lt_deletions) = VALUE zcl_purchase_order_service=>ty_order_item_changes(
        ( purchase_order_number = '4500000101'
          item_numbers          = VALUE #( ( '00010' ) ) )
        ( purchase_order_number = '4500000102'
          item_numbers          = VALUE #( ( '00020' ) ) ) ).
    mo_api->set_item_change_results(
      it_results = VALUE #(
        ( is_successful = abap_true )
        ( is_successful = abap_true ) ) ).

    DATA(ls_result) = mo_cut->delete_orders_items_atomic(
      it_deletions = lt_deletions ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000101'
      act = ls_result-order_results[ 1 ]-purchase_order_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00010'
      act = ls_result-order_results[ 1 ]-submitted_item_numbers[ 1 ] ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = mo_api->get_item_change_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD completes_item_batch_atomic.
    DATA(lt_changes) = VALUE zcl_purchase_order_service=>ty_order_item_changes(
        ( purchase_order_number = '4500000101'
          item_numbers          = VALUE #( ( '00010' ) ) )
        ( purchase_order_number = '4500000102'
          item_numbers          = VALUE #( ( '00020' ) ) ) ).
    mo_api->set_item_change_results(
      it_results = VALUE #(
        ( is_successful = abap_true )
        ( is_successful = abap_true ) ) ).

    DATA(ls_result) = mo_cut->mark_delivery_complete_atomic(
      it_changes = lt_changes ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000102'
      act = ls_result-order_results[ 2 ]-purchase_order_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00020'
      act = ls_result-order_results[ 2 ]-submitted_item_numbers[ 1 ] ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_commit_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_item_batch_atomic.
    DATA(lt_deletions) = VALUE zcl_purchase_order_service=>ty_order_item_changes(
        ( purchase_order_number = '4500000101'
          item_numbers          = VALUE #( ( '00010' ) ) )
        ( purchase_order_number = '4500000102'
          item_numbers          = VALUE #( ( '00020' ) ) ) ).
    mo_api->set_item_change_results(
      it_results = VALUE #(
        ( is_successful = abap_true )
        ( messages = VALUE #( (
          type    = 'E'
          message = 'Item update rejected' ) ) ) ) ).

    DATA(ls_result) = mo_cut->delete_orders_items_atomic(
      it_deletions = lt_deletions ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-order_results[ 1 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000101'
      act = ls_result-order_results[ 1 ]-purchase_order_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = mo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD prevalidates_atomic_items.
    DATA(lt_changes) = VALUE zcl_purchase_order_service=>ty_order_item_changes(
        ( purchase_order_number = '4500000101'
          item_numbers          = VALUE #( ( '00010' ) ) )
        ( purchase_order_number = '4500000102' ) ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        mo_cut->mark_delivery_complete_atomic( it_changes = lt_changes ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = mo_api->get_item_change_count( ) ).
  ENDMETHOD.
ENDCLASS.
