CLASS ltcl_stock_allocation_watch DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS sorts_by_shortage FOR TESTING.
    METHODS sorts_by_coverage FOR TESTING.
    METHODS sorts_by_newest FOR TESTING.
    METHODS sorts_by_age_by_default FOR TESTING.
    METHODS limits_alerts_after_sort FOR TESTING.
    METHODS offsets_alerts_after_sort FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_allocation_watch IMPLEMENTATION.
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
