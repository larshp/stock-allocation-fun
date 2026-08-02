CLASS ltcl_stock_allocation_compare DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS classifies_snapshot_changes FOR TESTING.
    METHODS ignores_unit_case FOR TESTING.
    METHODS detects_metadata_changes FOR TESTING.
    METHODS suppresses_mixed_unit_totals FOR TESTING.
    METHODS reconciles_snapshot_metrics FOR TESTING.
    METHODS classifies_recon_transitions FOR TESTING.
    METHODS calculates_running_age FOR TESTING.
    METHODS classifies_running_age_trend FOR TESTING.
    METHODS classifies_audit_metadata FOR TESTING.
    METHODS rejects_duplicate_keys FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_allocation_compare IMPLEMENTATION.
  METHOD classifies_recon_transitions.
    DATA lo_cut TYPE REF TO zif_stock_allocation_compare.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocation_compare.
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get_reconciliation_transition(
        iv_old_status = 'OK'
        iv_new_status = 'OK' )
      exp = 'both_ok' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get_reconciliation_transition(
        iv_old_status = 'MISMATCH'
        iv_new_status = 'OK' )
      exp = 'recovered' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get_reconciliation_transition(
        iv_old_status = 'OK'
        iv_new_status = 'MISMATCH' )
      exp = 'regressed' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get_reconciliation_transition(
        iv_old_status = 'MISMATCH'
        iv_new_status = 'MISMATCH' )
      exp = 'both_mismatch' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get_reconciliation_transition(
        iv_old_status = 'filtered'
        iv_new_status = 'X' )
      exp = 'unavailable' ).
  ENDMETHOD.

  METHOD classifies_audit_metadata.
    DATA lo_cut TYPE REF TO zif_stock_allocation_compare.
    DATA ls_old_run TYPE zif_allocation_audit=>ty_run.
    DATA ls_new_run TYPE zif_allocation_audit=>ty_run.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocation_compare.
    cl_abap_unit_assert=>assert_initial(
      lo_cut->get_audit_metadata_reasons(
        iv_old_run = ls_old_run
        iv_new_run = ls_new_run ) ).

    ls_old_run-status = 'R'.
    ls_new_run-status = 'S'.
    ls_old_run-strategy = 'P'.
    ls_new_run-strategy = 'F'.
    ls_old_run-unit = 'EA'.
    ls_new_run-unit = 'CS'.
    ls_old_run-movement_type = '201'.
    ls_new_run-movement_type = '202'.
    ls_old_run-min_shelf_life = 2.
    ls_new_run-min_shelf_life = 5.
    ls_old_run-requested_on_from = '20260101'.
    ls_new_run-requested_on_from = '20260102'.
    ls_old_run-start_date = '20260101'.
    ls_new_run-start_date = '20260102'.
    ls_old_run-message = 'old'.
    ls_new_run-message = 'new'.
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get_audit_metadata_reasons(
        iv_old_run = ls_old_run
        iv_new_run = ls_new_run )
      exp = 'status|strategy|unit|movement_type|shelf_life|horizon|timestamps|message' ).
  ENDMETHOD.

  METHOD calculates_running_age.
    DATA lo_cut TYPE REF TO zif_stock_allocation_compare.
    DATA ls_run TYPE zif_allocation_audit=>ty_run.
    DATA ls_age TYPE zif_stock_allocation_compare=>ty_running_age.
    DATA lv_age_is_long_enough TYPE abap_bool.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocation_compare.
    ls_run-status = 'R'.
    ls_run-start_date = sy-datum - 1.
    ls_run-start_time = '000001'.
    ls_age = lo_cut->get_running_age( ls_run ).
    cl_abap_unit_assert=>assert_true( ls_age-available ).
    lv_age_is_long_enough = xsdbool( ls_age-seconds >= 86399 ).
    cl_abap_unit_assert=>assert_true( lv_age_is_long_enough ).

    ls_run-finish_date = sy-datum.
    ls_run-finish_time = sy-uzeit.
    ls_age = lo_cut->get_running_age( ls_run ).
    cl_abap_unit_assert=>assert_false( ls_age-available ).
    cl_abap_unit_assert=>assert_initial( ls_age-seconds ).
  ENDMETHOD.

  METHOD classifies_running_age_trend.
    DATA lo_cut TYPE REF TO zif_stock_allocation_compare.
    DATA ls_old_age TYPE zif_stock_allocation_compare=>ty_running_age.
    DATA ls_new_age TYPE zif_stock_allocation_compare=>ty_running_age.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocation_compare.
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get_running_age_trend(
        is_old_age = ls_old_age
        is_new_age = ls_new_age )
      exp = 'unavailable' ).

    ls_old_age-available = abap_true.
    ls_new_age-available = abap_true.
    ls_old_age-seconds = 100.
    ls_new_age-seconds = 200.
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get_running_age_trend(
        is_old_age = ls_old_age
        is_new_age = ls_new_age )
      exp = 'older' ).
    ls_new_age-seconds = 50.
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get_running_age_trend(
        is_old_age = ls_old_age
        is_new_age = ls_new_age )
      exp = 'younger' ).
    ls_new_age-seconds = 100.
    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->get_running_age_trend(
        is_old_age = ls_old_age
        is_new_age = ls_new_age )
      exp = 'unchanged' ).
  ENDMETHOD.

  METHOD classifies_snapshot_changes.
    DATA lo_cut TYPE REF TO zif_stock_allocation_compare.
    DATA lt_old TYPE zif_stock_allocation=>tt_demands.
    DATA lt_new TYPE zif_stock_allocation=>tt_demands.
    DATA lt_changes TYPE zif_stock_allocation_compare=>tt_changes.
    DATA ls_summary TYPE zif_stock_allocation_compare=>ty_summary.
    DATA lv_total_rows TYPE i.

    APPEND VALUE #(
      allocation_unit   = 'EA'
      order_id          = 'CHANGED'
      priority          = 10
      requested         = 5
      allocated         = 2
      shortage          = 3
      allocation_status = 'P'
      reservation_id    = 'OLD-RES' ) TO lt_old.
    APPEND VALUE #(
      allocation_unit   = 'EA'
      order_id          = 'REMOVED'
      priority          = 20
      requested         = 1
      allocated         = 1
      allocation_status = 'F' ) TO lt_old.
    APPEND VALUE #(
      allocation_unit   = 'EA'
      order_id          = 'UNCHANGED'
      priority          = 30
      requested         = 2
      allocated         = 2
      allocation_status = 'F' ) TO lt_old.

    APPEND VALUE #(
      allocation_unit   = 'EA'
      order_id          = 'CHANGED'
      priority          = 10
      requested         = 5
      allocated         = 4
      shortage          = 1
      allocation_status = 'P'
      reservation_id    = 'NEW-RES' ) TO lt_new.
    APPEND VALUE #(
      allocation_unit   = 'EA'
      order_id          = 'ADDED'
      priority          = 40
      requested         = 3
      allocated         = 0
      shortage          = 3
      allocation_status = 'U' ) TO lt_new.
    APPEND VALUE #(
      allocation_unit   = 'EA'
      order_id          = 'UNCHANGED'
      priority          = 30
      requested         = 2
      allocated         = 2
      allocation_status = 'F' ) TO lt_new.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocation_compare.
    lt_changes = lo_cut->compare(
      EXPORTING
        it_old     = lt_old
        it_new     = lt_new
      IMPORTING
        es_summary = ls_summary ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_changes )
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_changes[ order_id = 'ADDED' ]-change_type
      exp = 'A' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_changes[ order_id = 'REMOVED' ]-change_type
      exp = 'R' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_changes[ order_id = 'CHANGED' ]-change_type
      exp = 'C' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_changes[ order_id = 'CHANGED' ]-delta_allocated
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_changes[ order_id = 'CHANGED' ]-delta_shortage
      exp = -2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-total_rows
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-added_rows
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-removed_rows
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-changed_rows
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-unchanged_rows
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-delta_allocated
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-delta_shortage
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-unit
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_false( ls_summary-mixed_units ).

    lt_changes = lo_cut->compare(
      EXPORTING
        it_old         = lt_old
        it_new         = lt_new
        iv_change_type = 'C'
      IMPORTING
        es_summary     = ls_summary
        ev_total_rows  = lv_total_rows ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_changes )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_total_rows
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-changed_rows
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-delta_allocated
      exp = 2 ).

    lt_changes = lo_cut->compare(
      EXPORTING
        it_old        = lt_old
        it_new        = lt_new
        iv_reason     = 'reservation_id'
      IMPORTING
        ev_total_rows = lv_total_rows ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_changes )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_changes[ 1 ]-order_id
      exp = 'CHANGED' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_total_rows
      exp = 1 ).

    lt_changes = lo_cut->compare(
      EXPORTING
        it_old               = lt_old
        it_new               = lt_new
        iv_include_unchanged = abap_true
        iv_offset            = 1
        iv_max_rows          = 2
      IMPORTING
        es_summary           = ls_summary
        ev_total_rows        = lv_total_rows ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_changes )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_total_rows
      exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-unchanged_rows
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_changes[ 1 ]-order_id
      exp = 'CHANGED' ).
  ENDMETHOD.

  METHOD ignores_unit_case.
    DATA lo_cut TYPE REF TO zif_stock_allocation_compare.
    DATA lt_old TYPE zif_stock_allocation=>tt_demands.
    DATA lt_new TYPE zif_stock_allocation=>tt_demands.
    DATA lt_changes TYPE zif_stock_allocation_compare=>tt_changes.
    DATA ls_summary TYPE zif_stock_allocation_compare=>ty_summary.

    APPEND VALUE #(
      allocation_unit   = 'ea'
      order_id          = 'CASE-UNIT'
      order_unit        = 'box'
      requested         = 2
      allocated         = 2
      allocation_status = 'F'
      reservation_id    = 'RES-CASE'
      reservation_unit  = 'box' ) TO lt_old.
    APPEND VALUE #(
      allocation_unit   = 'EA'
      order_id          = 'CASE-UNIT'
      order_unit        = 'BOX'
      requested         = 2
      allocated         = 2
      allocation_status = 'F'
      reservation_id    = 'RES-CASE'
      reservation_unit  = 'BOX' ) TO lt_new.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocation_compare.
    lt_changes = lo_cut->compare(
      EXPORTING
        it_old               = lt_old
        it_new               = lt_new
        iv_include_unchanged = abap_true
      IMPORTING
        es_summary           = ls_summary ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_changes )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_changes[ 1 ]-change_type
      exp = 'U' ).
    cl_abap_unit_assert=>assert_initial( lt_changes[ 1 ]-change_reasons ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-unit
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_false( ls_summary-mixed_units ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_changes[ 1 ]-old_order_unit
      exp = 'BOX' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_changes[ 1 ]-new_reservation_unit
      exp = 'BOX' ).
  ENDMETHOD.

  METHOD detects_metadata_changes.
    DATA lo_cut TYPE REF TO zif_stock_allocation_compare.
    DATA lt_old TYPE zif_stock_allocation=>tt_demands.
    DATA lt_new TYPE zif_stock_allocation=>tt_demands.
    DATA lt_changes TYPE zif_stock_allocation_compare=>tt_changes.

    APPEND VALUE #(
      allocation_unit           = 'EA'
      order_id                  = 'METADATA'
      allocation_strategy       = 'P'
      sales_document            = '5000000001'
      sales_document_type       = 'OR'
      sales_item                = '000010'
      schedule_line             = '0001'
      order_unit                = 'EA'
      requested                 = 4
      allocated                 = 4
      allocation_status         = 'F'
      reservation_id            = 'RES-1'
      reservation_date          = '20260101'
      reservation_movement_type = '201'
      reservation_unit          = 'EA' ) TO lt_old.
    APPEND VALUE #(
      allocation_unit           = 'EA'
      order_id                  = 'METADATA'
      allocation_strategy       = 'F'
      sales_document            = '5000000002'
      sales_document_type       = 'OR'
      sales_item                = '000020'
      schedule_line             = '0002'
      order_unit                = 'BOX'
      requested                 = 4
      allocated                 = 4
      allocation_status         = 'F'
      reservation_id            = 'RES-1'
      reservation_date          = '20260102'
      reservation_movement_type = '202'
      reservation_unit          = 'BOX' ) TO lt_new.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocation_compare.
    lt_changes = lo_cut->compare(
      it_old = lt_old
      it_new = lt_new ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_changes )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_changes[ 1 ]-change_type
      exp = 'C' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_changes[ 1 ]-old_sales_document
      exp = '5000000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_changes[ 1 ]-new_sales_document
      exp = '5000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_changes[ 1 ]-old_reservation_movement_type
      exp = '201' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_changes[ 1 ]-new_reservation_movement_type
      exp = '202' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_changes[ 1 ]-change_reasons
      exp = 'allocation_strategy|sales_document|sales_item|schedule_line|order_unit|reservation_date|'
        && 'reservation_movement_type|reservation_unit' ).
  ENDMETHOD.

  METHOD suppresses_mixed_unit_totals.
    DATA lo_cut TYPE REF TO zif_stock_allocation_compare.
    DATA lt_old TYPE zif_stock_allocation=>tt_demands.
    DATA lt_new TYPE zif_stock_allocation=>tt_demands.
    DATA ls_summary TYPE zif_stock_allocation_compare=>ty_summary.

    APPEND VALUE #(
      allocation_unit   = 'EA'
      order_id          = 'EA-CHANGED'
      requested         = 2
      allocated         = 1
      shortage          = 1
      allocation_status = 'P' ) TO lt_old.
    APPEND VALUE #(
      allocation_unit   = 'EA'
      order_id          = 'EA-CHANGED'
      requested         = 2
      allocated         = 2
      allocation_status = 'F' ) TO lt_new.
    APPEND VALUE #(
      allocation_unit   = 'BOX'
      order_id          = 'BOX-ADDED'
      requested         = 3
      allocated         = 1
      shortage          = 2
      allocation_status = 'P' ) TO lt_new.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocation_compare.
    lo_cut->compare(
      EXPORTING
        it_old     = lt_old
        it_new     = lt_new
      IMPORTING
        es_summary = ls_summary ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-total_rows
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-added_rows
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-changed_rows
      exp = 1 ).
    cl_abap_unit_assert=>assert_true( ls_summary-mixed_units ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-old_requested
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-new_allocated
      exp = 0 ).
  ENDMETHOD.

  METHOD reconciles_snapshot_metrics.
    DATA lo_cut TYPE REF TO zif_stock_allocation_compare.
    DATA lt_snapshot TYPE zif_stock_allocation=>tt_demands.
    DATA ls_audit TYPE zif_allocation_audit=>ty_run.
    DATA ls_reconciliation TYPE zif_stock_allocation_compare=>ty_reconciliation.

    APPEND VALUE #(
      allocation_unit   = 'EA'
      order_id          = 'FULL'
      requested         = 5
      allocated         = 5
      allocation_status = 'F' ) TO lt_snapshot.
    APPEND VALUE #(
      allocation_unit   = 'EA'
      order_id          = 'PARTIAL'
      requested         = 4
      allocated         = 2
      shortage          = 2
      allocation_status = 'P' ) TO lt_snapshot.
    ls_audit-demand_count = 2.
    ls_audit-full_count = 1.
    ls_audit-partial_count = 1.
    ls_audit-requested = 9.
    ls_audit-allocated = 7.
    ls_audit-shortage = 2.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocation_compare.
    ls_reconciliation = lo_cut->reconcile(
      it_snapshot = lt_snapshot
      is_audit    = ls_audit ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_reconciliation-status
      exp = 'OK' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_reconciliation-snapshot_requested
      exp = 9 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_reconciliation-snapshot_rows
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_reconciliation-snapshot_full_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_reconciliation-snapshot_partial_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_reconciliation-snapshot_unallocated_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_reconciliation-snapshot_allocated
      exp = 7 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_reconciliation-snapshot_shortage
      exp = 2 ).
    cl_abap_unit_assert=>assert_initial(
      ls_reconciliation-mismatch_fields ).

    ls_audit-requested = 8.
    ls_reconciliation = lo_cut->reconcile(
      it_snapshot = lt_snapshot
      is_audit    = ls_audit ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_reconciliation-status
      exp = 'MISMATCH' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_reconciliation-mismatch_fields
      exp = 'requested' ).
  ENDMETHOD.

  METHOD rejects_duplicate_keys.
    DATA lo_cut TYPE REF TO zif_stock_allocation_compare.
    DATA lt_old TYPE zif_stock_allocation=>tt_demands.
    DATA lt_new TYPE zif_stock_allocation=>tt_demands.
    DATA lv_raised TYPE abap_bool.

    APPEND VALUE #( allocation_unit = 'EA' order_id = 'DUPLICATE'
                    requested = 1 ) TO lt_old.
    APPEND VALUE #( allocation_unit = 'EA' order_id = 'DUPLICATE'
                    requested = 2 ) TO lt_old.
    CREATE OBJECT lo_cut TYPE zcl_stock_allocation_compare.
    TRY.
        lo_cut->compare(
          it_old = lt_old
          it_new = lt_new ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_error->message
          exp = 'Comparison old snapshot has duplicate keys' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lo_cut->compare(
          it_old         = lt_old
          it_new         = lt_new
          iv_change_type = 'X' ).
      CATCH zcx_stock_allocation INTO DATA(lo_change_type_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_change_type_error->message
          exp = 'Comparison change type is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    CLEAR lv_raised.
    TRY.
        lo_cut->compare(
          it_old    = lt_old
          it_new    = lt_new
          iv_reason = 'not_a_reason' ).
      CATCH zcx_stock_allocation INTO DATA(lo_reason_error).
        lv_raised = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = lo_reason_error->message
          exp = 'Comparison change reason is invalid' ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.
ENDCLASS.
