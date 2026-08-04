CLASS ltcl_stock_allocation_compare DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS classifies_snapshot_changes FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS filters_by_allocation_status FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS filters_coverage_reason_safely FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS sorts_by_shortage FOR TESTING.
    METHODS sorts_by_shortage_worsening FOR TESTING.
    METHODS sorts_by_requested_delta FOR TESTING.
    METHODS sorts_by_requested_quantity FOR TESTING.
    METHODS sorts_by_allocated_quantity FOR TESTING.
    METHODS sorts_by_requested_date FOR TESTING.
    METHODS sorts_by_reservation_date FOR TESTING.
    METHODS sorts_by_coverage FOR TESTING.
    METHODS sorts_by_coverage_worsening FOR TESTING.
    METHODS sorts_by_spct_worsening FOR TESTING.
    METHODS sorts_by_status_regression FOR TESTING.
    METHODS sorts_by_shortage_percentage FOR TESTING.
    METHODS ignores_unit_case FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS detects_metadata_changes FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS suppresses_mixed_unit_totals FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS reconciles_snapshot_metrics FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS classifies_recon_transitions FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS calculates_running_age FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS classifies_running_age_trend FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS classifies_audit_metadata FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_duplicate_keys FOR TESTING
      RAISING zcx_stock_allocation.
ENDCLASS.

CLASS ltcl_stock_allocation_compare IMPLEMENTATION.
  METHOD sorts_by_shortage.
    DATA lo_cut TYPE REF TO zif_stock_allocation_compare.
    DATA lt_changes TYPE zif_stock_allocation_compare=>tt_changes.
    DATA lt_sorted TYPE zif_stock_allocation_compare=>tt_changes.

    APPEND VALUE #(
      change_type      = 'C'
      allocation_unit  = 'EA'
      order_id         = 'LOW'
      new_requested_on = '20260105'
      new_shortage     = 1 ) TO lt_changes.
    APPEND VALUE #(
      change_type      = 'A'
      allocation_unit  = 'EA'
      order_id         = 'HIGH-LATE'
      new_requested_on = '20260106'
      new_shortage     = 8 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'A'
      allocation_unit = 'EA'
      order_id        = 'NEW-BLANK-DATE'
      new_shortage    = 9 ) TO lt_changes.
    APPEND VALUE #(
      change_type      = 'R'
      allocation_unit  = 'EA'
      order_id         = 'HIGH-EARLY'
      old_requested_on = '20260101'
      old_shortage     = 8 ) TO lt_changes.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocation_compare.
    lt_sorted = lo_cut->sort_by_shortage( lt_changes ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 1 ]-order_id
      exp = 'NEW-BLANK-DATE' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 2 ]-order_id
      exp = 'HIGH-EARLY' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 3 ]-order_id
      exp = 'HIGH-LATE' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 4 ]-order_id
      exp = 'LOW' ).
  ENDMETHOD.

  METHOD sorts_by_shortage_worsening.
    DATA lo_cut TYPE REF TO zif_stock_allocation_compare.
    DATA lt_changes TYPE zif_stock_allocation_compare=>tt_changes.
    DATA lt_sorted TYPE zif_stock_allocation_compare=>tt_changes.

    APPEND VALUE #(
      change_type     = 'C'
      allocation_unit = 'EA'
      order_id        = 'WORSENED'
      old_shortage    = 1
      new_shortage    = 9
      delta_shortage  = 8 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'A'
      allocation_unit = 'EA'
      order_id        = 'ADDED'
      new_shortage    = 5
      delta_shortage  = 5 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'U'
      allocation_unit = 'EA'
      order_id        = 'UNCHANGED'
      old_shortage    = 4
      new_shortage    = 4
      delta_shortage  = 0 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'R'
      allocation_unit = 'EA'
      order_id        = 'REMOVED'
      old_shortage    = 7
      delta_shortage  = -7 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'C'
      allocation_unit = 'EA'
      order_id        = 'IMPROVED'
      old_shortage    = 10
      new_shortage    = 2
      delta_shortage  = -8 ) TO lt_changes.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocation_compare.
    lt_sorted = lo_cut->sort_by_shortage_worsening( lt_changes ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 1 ]-order_id
      exp = 'WORSENED' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 2 ]-order_id
      exp = 'ADDED' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 3 ]-order_id
      exp = 'UNCHANGED' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 4 ]-order_id
      exp = 'REMOVED' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 5 ]-order_id
      exp = 'IMPROVED' ).
  ENDMETHOD.

  METHOD sorts_by_requested_delta.
    DATA lo_cut TYPE REF TO zif_stock_allocation_compare.
    DATA lt_changes TYPE zif_stock_allocation_compare=>tt_changes.
    DATA lt_sorted TYPE zif_stock_allocation_compare=>tt_changes.

    APPEND VALUE #(
      change_type     = 'C'
      allocation_unit = 'EA'
      order_id        = 'GROWTH'
      old_requested   = 10
      new_requested   = 30
      delta_requested = 20
      new_shortage    = 4 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'A'
      allocation_unit = 'EA'
      order_id        = 'ADDED'
      new_requested   = 15
      delta_requested = 15
      new_shortage    = 8 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'U'
      allocation_unit = 'EA'
      order_id        = 'STABLE'
      old_requested   = 20
      new_requested   = 20
      delta_requested = 0 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'R'
      allocation_unit = 'EA'
      order_id        = 'REMOVED'
      old_requested   = 12
      delta_requested = -12 ) TO lt_changes.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocation_compare.
    lt_sorted = lo_cut->sort_by_requested_delta( lt_changes ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 1 ]-order_id
      exp = 'GROWTH' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 2 ]-order_id
      exp = 'ADDED' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 3 ]-order_id
      exp = 'STABLE' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 4 ]-order_id
      exp = 'REMOVED' ).
  ENDMETHOD.

  METHOD sorts_by_requested_quantity.
    DATA lo_cut TYPE REF TO zif_stock_allocation_compare.
    DATA lt_changes TYPE zif_stock_allocation_compare=>tt_changes.
    DATA lt_sorted TYPE zif_stock_allocation_compare=>tt_changes.

    APPEND VALUE #(
      change_type     = 'C'
      allocation_unit = 'EA'
      order_id        = 'LARGE'
      new_requested   = 80
      new_shortage    = 2 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'R'
      allocation_unit = 'EA'
      order_id        = 'REMOVED'
      old_requested   = 90
      old_shortage    = 1 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'A'
      allocation_unit = 'EA'
      order_id        = 'ADDED'
      new_requested   = 70
      new_shortage    = 8 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'A'
      allocation_unit = 'EA'
      order_id        = 'SMALL'
      new_requested   = 10
      new_shortage    = 4 ) TO lt_changes.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocation_compare.
    lt_sorted = lo_cut->sort_by_requested_quantity( lt_changes ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 1 ]-order_id
      exp = 'REMOVED' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 2 ]-order_id
      exp = 'LARGE' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 3 ]-order_id
      exp = 'ADDED' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 4 ]-order_id
      exp = 'SMALL' ).
  ENDMETHOD.

  METHOD sorts_by_allocated_quantity.
    DATA lo_cut TYPE REF TO zif_stock_allocation_compare.
    DATA lt_changes TYPE zif_stock_allocation_compare=>tt_changes.
    DATA lt_sorted TYPE zif_stock_allocation_compare=>tt_changes.

    APPEND VALUE #(
      change_type     = 'C'
      allocation_unit = 'EA'
      order_id        = 'LARGE'
      new_allocated   = 80
      new_shortage    = 2 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'R'
      allocation_unit = 'EA'
      order_id        = 'REMOVED'
      old_allocated   = 95
      old_shortage    = 1 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'A'
      allocation_unit = 'EA'
      order_id        = 'ADDED'
      new_allocated   = 60
      new_shortage    = 8 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'A'
      allocation_unit = 'EA'
      order_id        = 'SMALL'
      new_allocated   = 10
      new_shortage    = 4 ) TO lt_changes.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocation_compare.
    lt_sorted = lo_cut->sort_by_allocated_quantity( lt_changes ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 1 ]-order_id
      exp = 'REMOVED' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 2 ]-order_id
      exp = 'LARGE' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 3 ]-order_id
      exp = 'ADDED' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 4 ]-order_id
      exp = 'SMALL' ).
  ENDMETHOD.

  METHOD sorts_by_requested_date.
    DATA lo_cut TYPE REF TO zif_stock_allocation_compare.
    DATA lt_changes TYPE zif_stock_allocation_compare=>tt_changes.
    DATA lt_sorted TYPE zif_stock_allocation_compare=>tt_changes.

    APPEND VALUE #(
      change_type      = 'C'
      allocation_unit  = 'EA'
      order_id         = 'LATE'
      new_requested_on = '20260105'
      new_shortage     = 9 ) TO lt_changes.
    APPEND VALUE #(
      change_type      = 'A'
      allocation_unit  = 'EA'
      order_id         = 'EARLY'
      new_requested_on = '20260101'
      new_shortage     = 2 ) TO lt_changes.
    APPEND VALUE #(
      change_type      = 'R'
      allocation_unit  = 'EA'
      order_id         = 'REMOVED'
      old_requested_on = '20260103'
      old_shortage     = 20 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'A'
      allocation_unit = 'EA'
      order_id        = 'NO-DATE'
      new_shortage    = 100 ) TO lt_changes.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocation_compare.
    lt_sorted = lo_cut->sort_by_requested_date( lt_changes ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 1 ]-order_id
      exp = 'EARLY' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 2 ]-order_id
      exp = 'REMOVED' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 3 ]-order_id
      exp = 'LATE' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 4 ]-order_id
      exp = 'NO-DATE' ).
  ENDMETHOD.

  METHOD sorts_by_reservation_date.
    DATA lo_cut TYPE REF TO zif_stock_allocation_compare.
    DATA lt_changes TYPE zif_stock_allocation_compare=>tt_changes.
    DATA lt_sorted TYPE zif_stock_allocation_compare=>tt_changes.

    APPEND VALUE #(
      change_type          = 'C'
      allocation_unit      = 'EA'
      order_id             = 'LATE'
      new_reservation_date = '20260105'
      new_shortage         = 9 ) TO lt_changes.
    APPEND VALUE #(
      change_type          = 'A'
      allocation_unit      = 'EA'
      order_id             = 'EARLY'
      new_reservation_date = '20260101'
      new_shortage         = 2 ) TO lt_changes.
    APPEND VALUE #(
      change_type          = 'R'
      allocation_unit      = 'EA'
      order_id             = 'REMOVED'
      old_reservation_date = '20260103'
      old_shortage         = 20 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'A'
      allocation_unit = 'EA'
      order_id        = 'NO-DATE'
      new_shortage    = 100 ) TO lt_changes.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocation_compare.
    lt_sorted = lo_cut->sort_by_reservation_date( lt_changes ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 1 ]-order_id
      exp = 'EARLY' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 2 ]-order_id
      exp = 'REMOVED' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 3 ]-order_id
      exp = 'LATE' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 4 ]-order_id
      exp = 'NO-DATE' ).
  ENDMETHOD.

  METHOD sorts_by_coverage.
    DATA lo_cut TYPE REF TO zif_stock_allocation_compare.
    DATA lt_changes TYPE zif_stock_allocation_compare=>tt_changes.
    DATA lt_sorted TYPE zif_stock_allocation_compare=>tt_changes.

    APPEND VALUE #(
      change_type     = 'C'
      allocation_unit = 'EA'
      order_id        = 'HIGH-COVERAGE'
      new_requested   = 10
      new_allocated   = 8
      new_shortage    = 2 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'A'
      allocation_unit = 'EA'
      order_id        = 'LOW-COVERAGE'
      new_requested   = 10
      new_allocated   = 2
      new_shortage    = 8 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'R'
      allocation_unit = 'EA'
      order_id        = 'REMOVED'
      old_requested   = 10
      old_allocated   = 0
      old_shortage    = 10 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'A'
      allocation_unit = 'EA'
      order_id        = 'ZERO-REQUEST'
      new_allocated   = 0 ) TO lt_changes.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocation_compare.
    lt_sorted = lo_cut->sort_by_coverage( lt_changes ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 1 ]-order_id
      exp = 'REMOVED' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 2 ]-order_id
      exp = 'LOW-COVERAGE' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 3 ]-order_id
      exp = 'HIGH-COVERAGE' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 4 ]-order_id
      exp = 'ZERO-REQUEST' ).
  ENDMETHOD.

  METHOD sorts_by_shortage_percentage.
    DATA lo_cut TYPE REF TO zif_stock_allocation_compare.
    DATA lt_changes TYPE zif_stock_allocation_compare=>tt_changes.
    DATA lt_sorted TYPE zif_stock_allocation_compare=>tt_changes.

    APPEND VALUE #(
      change_type     = 'C'
      allocation_unit = 'EA'
      order_id        = 'HIGH-PCT'
      new_requested   = 10
      new_shortage    = 8 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'A'
      allocation_unit = 'EA'
      order_id        = 'LOW-PCT'
      new_requested   = 10
      new_shortage    = 2 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'R'
      allocation_unit = 'EA'
      order_id        = 'REMOVED'
      old_requested   = 10
      old_shortage    = 10 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'A'
      allocation_unit = 'EA'
      order_id        = 'ZERO-REQUEST'
      new_shortage    = 5 ) TO lt_changes.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocation_compare.
    lt_sorted = lo_cut->sort_by_shortage_percentage( lt_changes ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 1 ]-order_id
      exp = 'REMOVED' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 2 ]-order_id
      exp = 'HIGH-PCT' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 3 ]-order_id
      exp = 'LOW-PCT' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 4 ]-order_id
      exp = 'ZERO-REQUEST' ).
  ENDMETHOD.

  METHOD sorts_by_coverage_worsening.
    DATA lo_cut TYPE REF TO zif_stock_allocation_compare.
    DATA lt_changes TYPE zif_stock_allocation_compare=>tt_changes.
    DATA lt_sorted TYPE zif_stock_allocation_compare=>tt_changes.

    APPEND VALUE #(
      change_type     = 'C'
      allocation_unit = 'EA'
      order_id        = 'DROPPED'
      old_requested   = 10
      old_allocated   = 8
      new_requested   = 10
      new_allocated   = 2
      new_shortage    = 8 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'C'
      allocation_unit = 'EA'
      order_id        = 'IMPROVED'
      old_requested   = 10
      old_allocated   = 2
      old_shortage    = 8
      new_requested   = 10
      new_allocated   = 8
      new_shortage    = 2 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'C'
      allocation_unit = 'EA'
      order_id        = 'STABLE'
      old_requested   = 10
      old_allocated   = 5
      new_requested   = 10
      new_allocated   = 5 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'A'
      allocation_unit = 'EA'
      order_id        = 'ADDED'
      new_requested   = 10
      new_allocated   = 1 ) TO lt_changes.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocation_compare.
    lt_sorted = lo_cut->sort_by_coverage_worsening( lt_changes ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 1 ]-order_id
      exp = 'DROPPED' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 2 ]-order_id
      exp = 'STABLE' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 3 ]-order_id
      exp = 'IMPROVED' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 4 ]-order_id
      exp = 'ADDED' ).
  ENDMETHOD.

  METHOD sorts_by_spct_worsening.
    DATA lo_cut TYPE REF TO zif_stock_allocation_compare.
    DATA lt_changes TYPE zif_stock_allocation_compare=>tt_changes.
    DATA lt_sorted TYPE zif_stock_allocation_compare=>tt_changes.

    APPEND VALUE #(
      change_type     = 'C'
      allocation_unit = 'EA'
      order_id        = 'WORSENED'
      old_requested   = 10
      old_shortage    = 2
      new_requested   = 10
      new_shortage    = 8 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'C'
      allocation_unit = 'EA'
      order_id        = 'IMPROVED'
      old_requested   = 10
      old_shortage    = 8
      new_requested   = 10
      new_shortage    = 2 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'C'
      allocation_unit = 'EA'
      order_id        = 'STABLE'
      old_requested   = 10
      old_shortage    = 5
      new_requested   = 10
      new_shortage    = 5 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'A'
      allocation_unit = 'EA'
      order_id        = 'ADDED'
      new_requested   = 10
      new_shortage    = 1 ) TO lt_changes.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocation_compare.
    lt_sorted = lo_cut->sort_by_spct_worsening( lt_changes ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 1 ]-order_id
      exp = 'WORSENED' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 2 ]-order_id
      exp = 'STABLE' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 3 ]-order_id
      exp = 'IMPROVED' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 4 ]-order_id
      exp = 'ADDED' ).
  ENDMETHOD.

  METHOD sorts_by_status_regression.
    DATA lo_cut TYPE REF TO zif_stock_allocation_compare.
    DATA lt_changes TYPE zif_stock_allocation_compare=>tt_changes.
    DATA lt_sorted TYPE zif_stock_allocation_compare=>tt_changes.

    APPEND VALUE #(
      change_type     = 'C'
      allocation_unit = 'EA'
      order_id        = 'REGRESSED-TWICE'
      old_status      = 'F'
      new_status      = 'U'
      new_shortage    = 10 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'C'
      allocation_unit = 'EA'
      order_id        = 'REGRESSED-ONCE'
      old_status      = 'F'
      new_status      = 'P'
      new_shortage    = 5 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'C'
      allocation_unit = 'EA'
      order_id        = 'STABLE'
      old_status      = 'P'
      new_status      = 'P'
      new_shortage    = 4 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'C'
      allocation_unit = 'EA'
      order_id        = 'IMPROVED'
      old_status      = 'U'
      new_status      = 'F'
      new_shortage    = 0 ) TO lt_changes.
    APPEND VALUE #(
      change_type     = 'A'
      allocation_unit = 'EA'
      order_id        = 'ADDED'
      new_status      = 'U'
      new_shortage    = 20 ) TO lt_changes.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocation_compare.
    lt_sorted = lo_cut->sort_by_status_regression( lt_changes ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 1 ]-order_id
      exp = 'REGRESSED-TWICE' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 2 ]-order_id
      exp = 'REGRESSED-ONCE' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 3 ]-order_id
      exp = 'STABLE' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 4 ]-order_id
      exp = 'IMPROVED' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_sorted[ 5 ]-order_id
      exp = 'ADDED' ).
  ENDMETHOD.

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
    ls_old_run-safety_stock = 3.
    ls_new_run-safety_stock = 4.
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
      exp = 'status|strategy|unit|movement_type|shelf_life|safety_stock|horizon|timestamps|message' ).

    CLEAR: ls_old_run, ls_new_run.
    ls_old_run-status = 'r'.
    ls_new_run-status = 'R'.
    ls_old_run-strategy = 'p'.
    ls_new_run-strategy = 'P'.
    ls_old_run-unit = 'ea'.
    ls_new_run-unit = 'EA'.
    cl_abap_unit_assert=>assert_initial(
      lo_cut->get_audit_metadata_reasons(
        iv_old_run = ls_old_run
        iv_new_run = ls_new_run ) ).
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

    ls_run-status = 'r'.
    ls_age = lo_cut->get_running_age( ls_run ).
    cl_abap_unit_assert=>assert_true( ls_age-available ).

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

  METHOD filters_by_allocation_status.
    DATA lo_cut TYPE REF TO zif_stock_allocation_compare.
    DATA lt_old TYPE zif_stock_allocation=>tt_demands.
    DATA lt_new TYPE zif_stock_allocation=>tt_demands.
    DATA lt_changes TYPE zif_stock_allocation_compare=>tt_changes.

    APPEND VALUE #(
      allocation_unit   = 'EA'
      order_id          = 'REGRESSED'
      requested         = 10
      allocated         = 10
      allocation_status = 'F' ) TO lt_old.
    APPEND VALUE #(
      allocation_unit   = 'EA'
      order_id          = 'RECOVERED'
      requested         = 10
      allocated         = 0
      shortage          = 10
      allocation_status = 'U' ) TO lt_old.
    APPEND VALUE #(
      allocation_unit   = 'EA'
      order_id          = 'REGRESSED'
      requested         = 10
      allocated         = 5
      shortage          = 5
      allocation_status = 'P' ) TO lt_new.
    APPEND VALUE #(
      allocation_unit   = 'EA'
      order_id          = 'RECOVERED'
      requested         = 10
      allocated         = 10
      allocation_status = 'F' ) TO lt_new.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocation_compare.
    lt_changes = lo_cut->compare(
      EXPORTING
        it_old        = lt_old
        it_new        = lt_new
        iv_old_status = 'f'
        iv_new_status = 'p' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_changes )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_changes[ 1 ]-order_id
      exp = 'REGRESSED' ).

    TRY.
        lo_cut->compare(
          EXPORTING
            it_old        = lt_old
            it_new        = lt_new
            iv_old_status = 'X' ).
        cl_abap_unit_assert=>fail(
          'Invalid comparison allocation status was accepted' ).
      CATCH zcx_stock_allocation.
    ENDTRY.
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
    cl_abap_unit_assert=>assert_true(
      lt_changes[ order_id = 'CHANGED' ]-old_coverage_available ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_changes[ order_id = 'CHANGED' ]-old_coverage
      exp = 40 ).
    cl_abap_unit_assert=>assert_true(
      lt_changes[ order_id = 'CHANGED' ]-new_coverage_available ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_changes[ order_id = 'CHANGED' ]-new_coverage
      exp = 80 ).
    cl_abap_unit_assert=>assert_true(
      lt_changes[ order_id = 'CHANGED' ]-old_shortage_pct_available ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_changes[ order_id = 'CHANGED' ]-old_shortage_pct
      exp = 60 ).
    cl_abap_unit_assert=>assert_true(
      lt_changes[ order_id = 'CHANGED' ]-new_shortage_pct_available ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_changes[ order_id = 'CHANGED' ]-new_shortage_pct
      exp = 20 ).
    cl_abap_unit_assert=>assert_true(
      lt_changes[ order_id = 'CHANGED' ]-coverage_delta_available ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_changes[ order_id = 'CHANGED' ]-coverage_delta
      exp = 40 ).
    cl_abap_unit_assert=>assert_true(
      lt_changes[ order_id = 'CHANGED' ]-shortage_pct_delta_available ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_changes[ order_id = 'CHANGED' ]-shortage_pct_delta
      exp = -40 ).
    cl_abap_unit_assert=>assert_false(
      lt_changes[ order_id = 'REMOVED' ]-new_coverage_available ).
    cl_abap_unit_assert=>assert_false(
      lt_changes[ order_id = 'REMOVED' ]-new_shortage_pct_available ).
    cl_abap_unit_assert=>assert_false(
      lt_changes[ order_id = 'REMOVED' ]-coverage_delta_available ).
    cl_abap_unit_assert=>assert_false(
      lt_changes[ order_id = 'REMOVED' ]-shortage_pct_delta_available ).
    lt_changes = lo_cut->compare(
      EXPORTING
        it_old        = lt_old
        it_new        = lt_new
        iv_reason     = 'coverage'
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
        it_old        = lt_old
        it_new        = lt_new
        iv_reason     = 'shortage_pct'
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
    cl_abap_unit_assert=>assert_true( ls_summary-old_coverage_available ).
    cl_abap_unit_assert=>assert_true( ls_summary-new_coverage_available ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-old_coverage
      exp = '50.00' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-new_coverage
      exp = '50.00' ).
    cl_abap_unit_assert=>assert_true( ls_summary-coverage_delta_available ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-coverage_delta
      exp = '0.00' ).
    cl_abap_unit_assert=>assert_true(
      ls_summary-old_shortage_pct_available ).
    cl_abap_unit_assert=>assert_true(
      ls_summary-new_shortage_pct_available ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-old_shortage_pct
      exp = '50.00' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-new_shortage_pct
      exp = '50.00' ).
    cl_abap_unit_assert=>assert_true(
      ls_summary-shortage_pct_delta_available ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-shortage_pct_delta
      exp = '0.00' ).
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

  METHOD filters_coverage_reason_safely.
    DATA lo_cut TYPE REF TO zif_stock_allocation_compare.
    DATA lt_old TYPE zif_stock_allocation=>tt_demands.
    DATA lt_new TYPE zif_stock_allocation=>tt_demands.
    DATA lt_changes TYPE zif_stock_allocation_compare=>tt_changes.

    APPEND VALUE #(
      allocation_unit   = 'EA'
      order_id          = 'SAME-RATIO'
      requested         = 5
      allocated         = 2
      shortage          = 3
      allocation_status = 'P'
      reservation_id    = 'OLD' ) TO lt_old.
    APPEND VALUE #(
      allocation_unit   = 'EA'
      order_id          = 'SAME-RATIO'
      requested         = 10
      allocated         = 4
      shortage          = 6
      allocation_status = 'P'
      reservation_id    = 'NEW' ) TO lt_new.
    APPEND VALUE #(
      allocation_unit = 'EA'
      order_id        = 'ZERO-RATIO'
      reservation_id  = 'OLD-ZERO' ) TO lt_old.
    APPEND VALUE #(
      allocation_unit = 'EA'
      order_id        = 'ZERO-RATIO'
      reservation_id  = 'NEW-ZERO' ) TO lt_new.
    APPEND VALUE #(
      allocation_unit = 'EA'
      order_id        = 'BECAME-APPLICABLE'
      reservation_id  = 'OLD-NONE' ) TO lt_old.
    APPEND VALUE #(
      allocation_unit   = 'EA'
      order_id          = 'BECAME-APPLICABLE'
      requested         = 5
      allocated         = 2
      shortage          = 3
      allocation_status = 'P'
      reservation_id    = 'NEW-SOME' ) TO lt_new.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocation_compare.
    lt_changes = lo_cut->compare(
      it_old    = lt_old
      it_new    = lt_new
      iv_reason = 'coverage' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_changes )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_changes[ 1 ]-order_id
      exp = 'BECAME-APPLICABLE' ).
    lt_changes = lo_cut->compare(
      it_old    = lt_old
      it_new    = lt_new
      iv_reason = 'shortage_pct' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_changes )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_changes[ 1 ]-order_id
      exp = 'BECAME-APPLICABLE' ).
  ENDMETHOD.

  METHOD ignores_unit_case.
    DATA lo_cut TYPE REF TO zif_stock_allocation_compare.
    DATA lt_old TYPE zif_stock_allocation=>tt_demands.
    DATA lt_new TYPE zif_stock_allocation=>tt_demands.
    DATA lt_changes TYPE zif_stock_allocation_compare=>tt_changes.
    DATA ls_summary TYPE zif_stock_allocation_compare=>ty_summary.

    APPEND VALUE #(
      allocation_unit     = 'ea'
      order_id            = 'CASE-UNIT'
      allocation_strategy = 'p'
      order_unit          = 'box'
      requested           = 2
      allocated           = 2
      allocation_status   = 'f'
      reservation_id      = 'RES-CASE'
      reservation_unit    = 'box' ) TO lt_old.
    APPEND VALUE #(
      allocation_unit     = 'EA'
      order_id            = 'CASE-UNIT'
      allocation_strategy = 'P'
      order_unit          = 'BOX'
      requested           = 2
      allocated           = 2
      allocation_status   = 'F'
      reservation_id      = 'RES-CASE'
      reservation_unit    = 'BOX' ) TO lt_new.

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
    cl_abap_unit_assert=>assert_false( ls_summary-old_coverage_available ).
    cl_abap_unit_assert=>assert_false( ls_summary-new_coverage_available ).
    cl_abap_unit_assert=>assert_false( ls_summary-coverage_delta_available ).
    cl_abap_unit_assert=>assert_false(
      ls_summary-old_shortage_pct_available ).
    cl_abap_unit_assert=>assert_false(
      ls_summary-new_shortage_pct_available ).
    cl_abap_unit_assert=>assert_false(
      ls_summary-shortage_pct_delta_available ).
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

    CLEAR lt_snapshot.
    APPEND VALUE #(
      allocation_unit   = 'EA'
      order_id          = 'INVALID-STATUS'
      requested         = 1
      shortage          = 1
      allocation_status = 'X' ) TO lt_snapshot.
    CLEAR ls_audit.
    ls_audit-demand_count = 1.
    ls_audit-requested = 1.
    ls_audit-shortage = 1.
    ls_reconciliation = lo_cut->reconcile(
      it_snapshot = lt_snapshot
      is_audit    = ls_audit ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_reconciliation-status
      exp = 'MISMATCH' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_reconciliation-mismatch_fields
      exp = 'status' ).

    CLEAR lt_snapshot.
    APPEND VALUE #(
      allocation_unit   = 'EA'
      order_id          = 'INVALID-METRICS'
      requested         = 2
      allocated         = 1
      shortage          = 1
      allocation_status = 'F' ) TO lt_snapshot.
    CLEAR ls_audit.
    ls_audit-demand_count = 1.
    ls_audit-full_count = 1.
    ls_audit-requested = 2.
    ls_audit-allocated = 1.
    ls_audit-shortage = 1.
    ls_reconciliation = lo_cut->reconcile(
      it_snapshot = lt_snapshot
      is_audit    = ls_audit ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_reconciliation-status
      exp = 'MISMATCH' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_reconciliation-mismatch_fields
      exp = 'snapshot' ).

    CLEAR lt_snapshot.
    APPEND VALUE #(
      allocation_unit   = 'EA'
      order_id          = 'WRONG-UNIT'
      requested         = 1
      allocated         = 1
      allocation_status = 'F' ) TO lt_snapshot.
    CLEAR ls_audit.
    ls_audit-unit = 'BOX'.
    ls_audit-demand_count = 1.
    ls_audit-full_count = 1.
    ls_audit-requested = 1.
    ls_audit-allocated = 1.
    ls_reconciliation = lo_cut->reconcile(
      it_snapshot = lt_snapshot
      is_audit    = ls_audit ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_reconciliation-status
      exp = 'MISMATCH' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_reconciliation-mismatch_fields
      exp = 'unit' ).
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
