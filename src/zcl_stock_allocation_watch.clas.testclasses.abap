CLASS ltcl_stock_allocation_watch DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS sorts_by_shortage FOR TESTING.
    METHODS sorts_by_coverage FOR TESTING.
    METHODS sorts_by_shortage_pct FOR TESTING.
    METHODS sorts_by_demand_count FOR TESTING.
    METHODS sorts_by_deadline_age FOR TESTING.
    METHODS sorts_by_requested_date FOR TESTING.
    METHODS summarizes_units FOR TESTING.
    METHODS summarizes_current_due FOR TESTING.
    METHODS sorts_by_newest FOR TESTING.
    METHODS sorts_by_age_by_default FOR TESTING.
    METHODS limits_alerts_after_sort FOR TESTING.
    METHODS offsets_alerts_after_sort FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_allocation_watch IMPLEMENTATION.
  METHOD summarizes_units.
    DATA lt_alerts TYPE zcl_stock_allocation_watch=>tt_alerts.
    DATA ls_summary TYPE zcl_stock_allocation_watch=>ty_unit_summary.

    APPEND VALUE #( unit               = 'EA'
                    strategy           = 'W'
                    preview            = abap_true
                    demand_count       = 2
                    full_count         = 1
                    partial_count      = 1
                    available          = '10'
                    requested          = '8'
                    allocated          = '5'
                    shortage           = '3'
                    age_seconds        = 100
                    requested_deadline = '20260820'
                    deadline_age_days  = -2
                    deadline_age_ref   = sy-datum ) TO lt_alerts.
    APPEND VALUE #( unit               = 'ea'
                    preview            = abap_false
                    demand_count       = 3
                    full_count         = 2
                    partial_count      = 1
                    available          = '20'
                    requested          = '18'
                    allocated          = '12'
                    shortage           = '6'
                    age_seconds        = 500
                    requested_deadline = '20260815'
                    deadline_age_days  = 3
                    deadline_age_ref   = sy-datum ) TO lt_alerts.
    ls_summary = zcl_stock_allocation_watch=>summarize_units( lt_alerts ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-unit
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-mixed_units
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-demand_count
      exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-preview_runs
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-operational_runs
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-preview_mix_pct
      exp = 50 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-operational_mix_pct
      exp = 50 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-full_count
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-partial_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-unallocated_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-full_mix_pct
      exp = 60 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-partial_mix_pct
      exp = 40 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-unallocated_mix_pct
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-deadline_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-deadline_mix_pct
      exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-overdue_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-current_deadline_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-future_deadline_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-overdue_mix_pct
      exp = 50 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-current_deadline_mix_pct
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-future_deadline_mix_pct
      exp = 50 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-weighted_strategy_runs
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-weighted_requested
      exp = '8' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-weighted_allocated
      exp = '5' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-weighted_shortage
      exp = '3' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-total_available
      exp = '30' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-total_requested
      exp = '26' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-total_allocated
      exp = '17' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-total_shortage
      exp = '9' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-oldest_age_seconds
      exp = 500 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-newest_age_seconds
      exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-earliest_requested_deadline
      exp = '20260815' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-latest_requested_deadline
      exp = '20260820' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-oldest_deadline_age_days
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-newest_deadline_age_days
      exp = -2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-oldest_deadline_urgency
      exp = 'overdue' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-newest_deadline_urgency
      exp = 'future' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-deadline_age_reference_date
      exp = sy-datum ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-deadline_age_mixed
      exp = abap_false ).

    APPEND VALUE #( unit         = 'BOX'
                    demand_count = 4 ) TO lt_alerts.
    ls_summary = zcl_stock_allocation_watch=>summarize_units( lt_alerts ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-unit
      exp = 'mixed' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-mixed_units
      exp = abap_true ).
    cl_abap_unit_assert=>assert_initial( ls_summary-total_available ).
    cl_abap_unit_assert=>assert_initial( ls_summary-total_requested ).
    cl_abap_unit_assert=>assert_initial( ls_summary-total_allocated ).
    cl_abap_unit_assert=>assert_initial( ls_summary-total_shortage ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-deadline_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-deadline_mix_pct
      exp = '66.67' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-overdue_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-future_deadline_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-overdue_mix_pct
      exp = '33.33' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-future_deadline_mix_pct
      exp = '33.33' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-deadline_age_mixed
      exp = abap_true ).
    cl_abap_unit_assert=>assert_initial(
      ls_summary-deadline_age_reference_date ).

    CLEAR lt_alerts.
    ls_summary = zcl_stock_allocation_watch=>summarize_units( lt_alerts ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-unit
      exp = 'n/a' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-mixed_units
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-demand_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-weighted_strategy_runs
      exp = 0 ).
    cl_abap_unit_assert=>assert_initial( ls_summary-weighted_requested ).
    cl_abap_unit_assert=>assert_initial( ls_summary-weighted_allocated ).
    cl_abap_unit_assert=>assert_initial( ls_summary-weighted_shortage ).
    cl_abap_unit_assert=>assert_initial( ls_summary-total_available ).
    cl_abap_unit_assert=>assert_initial( ls_summary-total_requested ).
    cl_abap_unit_assert=>assert_initial( ls_summary-total_allocated ).
    cl_abap_unit_assert=>assert_initial( ls_summary-total_shortage ).
    cl_abap_unit_assert=>assert_initial( ls_summary-full_count ).
    cl_abap_unit_assert=>assert_initial( ls_summary-partial_count ).
    cl_abap_unit_assert=>assert_initial( ls_summary-unallocated_count ).
    cl_abap_unit_assert=>assert_initial( ls_summary-full_mix_pct ).
    cl_abap_unit_assert=>assert_initial( ls_summary-partial_mix_pct ).
    cl_abap_unit_assert=>assert_initial( ls_summary-unallocated_mix_pct ).
    cl_abap_unit_assert=>assert_initial( ls_summary-oldest_age_seconds ).
    cl_abap_unit_assert=>assert_initial( ls_summary-newest_age_seconds ).
    cl_abap_unit_assert=>assert_initial( ls_summary-deadline_count ).
    cl_abap_unit_assert=>assert_initial( ls_summary-deadline_mix_pct ).
    cl_abap_unit_assert=>assert_initial( ls_summary-overdue_count ).
    cl_abap_unit_assert=>assert_initial(
      ls_summary-current_deadline_count ).
    cl_abap_unit_assert=>assert_initial( ls_summary-future_deadline_count ).
    cl_abap_unit_assert=>assert_initial( ls_summary-overdue_mix_pct ).
    cl_abap_unit_assert=>assert_initial(
      ls_summary-current_deadline_mix_pct ).
    cl_abap_unit_assert=>assert_initial( ls_summary-future_deadline_mix_pct ).
    cl_abap_unit_assert=>assert_initial(
      ls_summary-oldest_deadline_age_days ).
    cl_abap_unit_assert=>assert_initial(
      ls_summary-newest_deadline_age_days ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-oldest_deadline_urgency
      exp = 'n/a' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-newest_deadline_urgency
      exp = 'n/a' ).
    cl_abap_unit_assert=>assert_initial(
      ls_summary-deadline_age_reference_date ).
    cl_abap_unit_assert=>assert_initial(
      ls_summary-deadline_age_mixed ).
  ENDMETHOD.

  METHOD summarizes_current_due.
    DATA lt_alerts TYPE zcl_stock_allocation_watch=>tt_alerts.
    DATA ls_summary TYPE zcl_stock_allocation_watch=>ty_unit_summary.

    APPEND VALUE #( unit               = 'EA'
                    requested_deadline = sy-datum
                    deadline_age_days  = 0 ) TO lt_alerts.

    ls_summary = zcl_stock_allocation_watch=>summarize_units( lt_alerts ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-current_deadline_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-current_deadline_mix_pct
      exp = 100 ).
    cl_abap_unit_assert=>assert_initial( ls_summary-overdue_count ).
    cl_abap_unit_assert=>assert_initial( ls_summary-future_deadline_count ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-oldest_deadline_urgency
      exp = 'current_day' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-newest_deadline_urgency
      exp = 'current_day' ).
  ENDMETHOD.

  METHOD sorts_by_shortage.
    DATA lt_alerts TYPE zcl_stock_allocation_watch=>tt_alerts.

    APPEND VALUE #( run_id      = 'YOUNG'
                    age_seconds = 900
                    shortage    = '5' ) TO lt_alerts.
    APPEND VALUE #( run_id      = 'OLD'
                    age_seconds = 3600
                    shortage    = '2' ) TO lt_alerts.
    APPEND VALUE #( run_id      = 'BLOCKED'
                    age_seconds = 1200
                    shortage    = '8' ) TO lt_alerts.

    zcl_stock_allocation_watch=>sort_and_limit(
      EXPORTING
        iv_sort_by_shortage = abap_true
        iv_max              = 0
      CHANGING
        ct_alerts           = lt_alerts ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_alerts[ 1 ]-run_id
      exp = 'BLOCKED' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_alerts[ 2 ]-run_id
      exp = 'YOUNG' ).
  ENDMETHOD.

  METHOD sorts_by_coverage.
    DATA lt_alerts TYPE zcl_stock_allocation_watch=>tt_alerts.

    APPEND VALUE #( run_id             = 'HIGH'
                    coverage           = '90'
                    coverage_available = abap_true
                    age_seconds        = 3600 ) TO lt_alerts.
    APPEND VALUE #( run_id             = 'LOW'
                    coverage           = '20'
                    coverage_available = abap_true
                    age_seconds        = 900 ) TO lt_alerts.
    APPEND VALUE #( run_id             = 'NA'
                    coverage_available = abap_false
                    age_seconds        = 7200 ) TO lt_alerts.

    zcl_stock_allocation_watch=>sort_and_limit(
      EXPORTING
        iv_sort_by_shortage = abap_false
        iv_sort_by_coverage = abap_true
        iv_max              = 0
      CHANGING
        ct_alerts           = lt_alerts ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_alerts[ 1 ]-run_id
      exp = 'LOW' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_alerts[ 2 ]-run_id
      exp = 'HIGH' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_alerts[ 3 ]-run_id
      exp = 'NA' ).
  ENDMETHOD.

  METHOD sorts_by_shortage_pct.
    DATA lt_alerts TYPE zcl_stock_allocation_watch=>tt_alerts.

    APPEND VALUE #( run_id                 = 'LOW'
                    shortage_pct           = '20'
                    shortage_pct_available = abap_true
                    shortage               = '2'
                    age_seconds            = 3600 ) TO lt_alerts.
    APPEND VALUE #( run_id                 = 'HIGH'
                    shortage_pct           = '80'
                    shortage_pct_available = abap_true
                    shortage               = '1'
                    age_seconds            = 900 ) TO lt_alerts.
    APPEND VALUE #( run_id                 = 'NA'
                    shortage_pct_available = abap_false
                    age_seconds            = 7200 ) TO lt_alerts.

    zcl_stock_allocation_watch=>sort_and_limit(
      EXPORTING
        iv_sort_by_shortage = abap_false
        iv_sort_by_shrt_pct = abap_true
        iv_max              = 0
      CHANGING
        ct_alerts           = lt_alerts ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_alerts[ 1 ]-run_id
      exp = 'HIGH' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_alerts[ 2 ]-run_id
      exp = 'LOW' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_alerts[ 3 ]-run_id
      exp = 'NA' ).
  ENDMETHOD.

  METHOD sorts_by_demand_count.
    DATA lt_alerts TYPE zcl_stock_allocation_watch=>tt_alerts.

    APPEND VALUE #( run_id       = 'FEW'
                    demand_count = 2
                    shortage     = '9'
                    age_seconds  = 900 ) TO lt_alerts.
    APPEND VALUE #( run_id       = 'MANY'
                    demand_count = 7
                    shortage     = '1'
                    age_seconds  = 100 ) TO lt_alerts.
    APPEND VALUE #( run_id       = 'TIE_OLD'
                    demand_count = 7
                    shortage     = '3'
                    age_seconds  = 1200 ) TO lt_alerts.
    APPEND VALUE #( run_id       = 'TIE_YOUNG'
                    demand_count = 7
                    shortage     = '3'
                    age_seconds  = 300 ) TO lt_alerts.

    zcl_stock_allocation_watch=>sort_and_limit(
      EXPORTING
        iv_sort_by_shortage     = abap_true
        iv_sort_by_demand_count = abap_true
        iv_max                  = 0
      CHANGING
        ct_alerts               = lt_alerts ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_alerts[ 1 ]-run_id
      exp = 'TIE_OLD' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_alerts[ 2 ]-run_id
      exp = 'TIE_YOUNG' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_alerts[ 3 ]-run_id
      exp = 'MANY' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_alerts[ 4 ]-run_id
      exp = 'FEW' ).
  ENDMETHOD.

  METHOD sorts_by_deadline_age.
    DATA lt_alerts TYPE zcl_stock_allocation_watch=>tt_alerts.

    APPEND VALUE #( run_id                 = 'FUTURE'
                    requested_deadline     = '20260820'
                    deadline_age_days      = -5
                    deadline_age_available = abap_true
                    shortage               = '9'
                    age_seconds            = 900 ) TO lt_alerts.
    APPEND VALUE #( run_id                 = 'OVERDUE'
                    requested_deadline     = '20260810'
                    deadline_age_days      = 5
                    deadline_age_available = abap_true
                    shortage               = '1'
                    age_seconds            = 3600 ) TO lt_alerts.
    APPEND VALUE #( run_id                 = 'DUE'
                    requested_deadline     = '20260815'
                    deadline_age_days      = 0
                    deadline_age_available = abap_true
                    shortage               = '3'
                    age_seconds            = 1800 ) TO lt_alerts.
    APPEND VALUE #( run_id      = 'NO_DEADLINE'
                    shortage    = '99'
                    age_seconds = 7200 ) TO lt_alerts.

    zcl_stock_allocation_watch=>sort_and_limit(
      EXPORTING
        iv_sort_by_shortage     = abap_false
        iv_sort_by_deadline_age = abap_true
        iv_max                  = 0
      CHANGING
      ct_alerts                 = lt_alerts ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_alerts[ 1 ]-run_id
      exp = 'OVERDUE' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_alerts[ 2 ]-run_id
      exp = 'DUE' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_alerts[ 3 ]-run_id
      exp = 'FUTURE' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_alerts[ 4 ]-run_id
      exp = 'NO_DEADLINE' ).
  ENDMETHOD.

  METHOD sorts_by_requested_date.
    DATA lt_alerts TYPE zcl_stock_allocation_watch=>tt_alerts.

    APPEND VALUE #( run_id            = 'LATE'
                    requested_on_from = '20260820'
                    requested_on_to   = '20260822'
                    horizon_available = abap_true
                    shortage          = '9'
                    age_seconds       = 900 ) TO lt_alerts.
    APPEND VALUE #( run_id            = 'EARLY'
                    requested_on_from = '20260815'
                    requested_on_to   = '20260816'
                    horizon_available = abap_true
                    shortage          = '1'
                    age_seconds       = 3600 ) TO lt_alerts.
    APPEND VALUE #( run_id          = 'ONLY_TO'
                    requested_on_to = '20260818'
                    shortage        = '99'
                    age_seconds     = 7200 ) TO lt_alerts.
    APPEND VALUE #( run_id      = 'NO_HORIZON'
                    shortage    = '99'
                    age_seconds = 7200 ) TO lt_alerts.

    zcl_stock_allocation_watch=>sort_and_limit(
      EXPORTING
        iv_sort_by_shortage = abap_false
        iv_sort_by_due      = abap_true
        iv_max              = 0
      CHANGING
        ct_alerts           = lt_alerts ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_alerts[ 1 ]-run_id
      exp = 'EARLY' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_alerts[ 2 ]-run_id
      exp = 'ONLY_TO' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_alerts[ 3 ]-run_id
      exp = 'LATE' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_alerts[ 4 ]-run_id
      exp = 'NO_HORIZON' ).
  ENDMETHOD.

  METHOD sorts_by_newest.
    DATA lt_alerts TYPE zcl_stock_allocation_watch=>tt_alerts.

    APPEND VALUE #( run_id      = 'OLD'
                    age_seconds = 3600
                    start_date  = '20260101'
                    start_time  = '080000' ) TO lt_alerts.
    APPEND VALUE #( run_id      = 'NEW'
                    age_seconds = 900
                    start_date  = '20260102'
                    start_time  = '090000' ) TO lt_alerts.

    zcl_stock_allocation_watch=>sort_and_limit(
      EXPORTING
        iv_sort_by_shortage = abap_false
        iv_sort_by_newest   = abap_true
        iv_max              = 0
      CHANGING
        ct_alerts           = lt_alerts ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_alerts[ 1 ]-run_id
      exp = 'NEW' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_alerts[ 2 ]-run_id
      exp = 'OLD' ).
  ENDMETHOD.

  METHOD sorts_by_age_by_default.
    DATA lt_alerts TYPE zcl_stock_allocation_watch=>tt_alerts.

    APPEND VALUE #( run_id      = 'NEW'
                    age_seconds = 100
                    shortage    = '10' ) TO lt_alerts.
    APPEND VALUE #( run_id      = 'OLD'
                    age_seconds = 500
                    shortage    = '1' ) TO lt_alerts.

    zcl_stock_allocation_watch=>sort_and_limit(
      EXPORTING
        iv_sort_by_shortage = abap_false
        iv_max              = 0
      CHANGING
        ct_alerts           = lt_alerts ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_alerts[ 1 ]-run_id
      exp = 'OLD' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_alerts[ 2 ]-run_id
      exp = 'NEW' ).
  ENDMETHOD.

  METHOD limits_alerts_after_sort.
    DATA lt_alerts TYPE zcl_stock_allocation_watch=>tt_alerts.

    APPEND VALUE #( run_id      = 'FIRST'
                    age_seconds = 100 ) TO lt_alerts.
    APPEND VALUE #( run_id      = 'SECOND'
                    age_seconds = 200 ) TO lt_alerts.
    APPEND VALUE #( run_id      = 'THIRD'
                    age_seconds = 300 ) TO lt_alerts.

    zcl_stock_allocation_watch=>sort_and_limit(
      EXPORTING
        iv_sort_by_shortage = abap_false
        iv_max              = 2
      CHANGING
        ct_alerts           = lt_alerts ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_alerts )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_alerts[ 1 ]-run_id
      exp = 'THIRD' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_alerts[ 2 ]-run_id
      exp = 'SECOND' ).
  ENDMETHOD.

  METHOD offsets_alerts_after_sort.
    DATA lt_alerts TYPE zcl_stock_allocation_watch=>tt_alerts.

    APPEND VALUE #( run_id      = 'FIRST'
                    age_seconds = 100 ) TO lt_alerts.
    APPEND VALUE #( run_id      = 'SECOND'
                    age_seconds = 200 ) TO lt_alerts.
    APPEND VALUE #( run_id      = 'THIRD'
                    age_seconds = 300 ) TO lt_alerts.

    zcl_stock_allocation_watch=>sort_and_limit(
      EXPORTING
        iv_sort_by_shortage = abap_false
        iv_max              = 1
        iv_offset           = 1
      CHANGING
        ct_alerts           = lt_alerts ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_alerts )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_alerts[ 1 ]-run_id
      exp = 'SECOND' ).
  ENDMETHOD.
ENDCLASS.
