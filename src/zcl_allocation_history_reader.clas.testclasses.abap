CLASS ltcl_allocation_history_reader DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_allocation_history_reader.

    METHODS setup.
    METHODS rejects_initial_dates FOR TESTING.
    METHODS rejects_inverted_dates FOR TESTING.
    METHODS rejects_inverted_times FOR TESTING.
    METHODS rejects_invalid_req_range FOR TESTING.
    METHODS rejects_invalid_horizon FOR TESTING.
    METHODS rejects_invalid_policy_filter FOR TESTING.
    METHODS rejects_invalid_stock_filter FOR TESTING.
    METHODS rejects_conflicting_stock FOR TESTING.
    METHODS rejects_conflicting_qty FOR TESTING.
    METHODS rejects_bad_shortfall_filter FOR TESTING.
    METHODS rejects_invalid_fill_filter FOR TESTING.
    METHODS rejects_invalid_fill_range FOR TESTING.
    METHODS rejects_invalid_min_fill FOR TESTING.
    METHODS rejects_invalid_qty_range FOR TESTING.
    METHODS rejects_invalid_numeric_range FOR TESTING.
    METHODS rejects_invalid_limit FOR TESTING.
ENDCLASS.

CLASS ltcl_allocation_history_reader IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD rejects_initial_dates.
    DATA(ls_result) = mo_cut->zif_allocation_history_reader~read(
      iv_from_date = '00000000'
      iv_to_date   = '20260820'
      iv_max_rows  = 100 ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Audit history date range is invalid' ).
    cl_abap_unit_assert=>assert_initial( ls_result-entries ).
  ENDMETHOD.

  METHOD rejects_inverted_dates.
    DATA(ls_result) = mo_cut->zif_allocation_history_reader~read(
      iv_from_date = '20260820'
      iv_to_date   = '20260819'
      iv_max_rows  = 100 ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Audit history date range is invalid' ).
  ENDMETHOD.

  METHOD rejects_inverted_times.
    DATA(ls_result) = mo_cut->zif_allocation_history_reader~read(
      iv_from_date = '20260820'
      iv_to_date   = '20260820'
      iv_from_time = '120001'
      iv_to_time   = '120000'
      iv_max_rows  = 100 ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Audit history time range is invalid' ).
    cl_abap_unit_assert=>assert_initial( ls_result-entries ).
  ENDMETHOD.

  METHOD rejects_invalid_req_range.
    DATA(ls_result) = mo_cut->zif_allocation_history_reader~read(
      iv_from_date        = '20260801'
      iv_to_date          = '20260820'
      iv_requirement_from = '20260820'
      iv_requirement_to   = '20260819'
      iv_max_rows         = 100 ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Audit requirement date range is invalid' ).
  ENDMETHOD.

  METHOD rejects_invalid_horizon.
    DATA(ls_result) = mo_cut->zif_allocation_history_reader~read(
      iv_from_date    = '20260801'
      iv_to_date      = '20260820'
      iv_horizon_from = '20260901'
      iv_horizon_to   = '20260831'
      iv_max_rows     = 100 ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Audit horizon date range is invalid' ).
    cl_abap_unit_assert=>assert_initial( ls_result-entries ).
  ENDMETHOD.

  METHOD rejects_invalid_policy_filter.
    DATA(ls_result) = mo_cut->zif_allocation_history_reader~read(
      iv_from_date         = '20260801'
      iv_to_date           = '20260820'
      iv_full_batch_filter = 'Y'
      iv_max_rows          = 100 ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Audit policy filter is invalid' ).
    cl_abap_unit_assert=>assert_initial( ls_result-entries ).
  ENDMETHOD.

  METHOD rejects_invalid_stock_filter.
    DATA(ls_result) = mo_cut->zif_allocation_history_reader~read(
      iv_from_date    = '20260801'
      iv_to_date      = '20260820'
      iv_stock_filter = 'Y'
      iv_max_rows     = 100 ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Audit policy filter is invalid' ).
    cl_abap_unit_assert=>assert_initial( ls_result-entries ).
  ENDMETHOD.

  METHOD rejects_conflicting_stock.
    DATA(ls_result) = mo_cut->zif_allocation_history_reader~read(
      iv_from_date           = '20260801'
      iv_to_date             = '20260820'
      iv_availability_filter = '-'
      iv_stock_filter        = 'X'
      iv_max_rows            = 100 ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Audit availability filters conflict' ).
    cl_abap_unit_assert=>assert_initial( ls_result-entries ).
  ENDMETHOD.

  METHOD rejects_bad_shortfall_filter.
    DATA(ls_result) = mo_cut->zif_allocation_history_reader~read(
      iv_from_date        = '20260801'
      iv_to_date          = '20260820'
      iv_shortfall_filter = 'Y'
      iv_max_rows         = 100 ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Audit policy filter is invalid' ).
    cl_abap_unit_assert=>assert_initial( ls_result-entries ).
  ENDMETHOD.

  METHOD rejects_invalid_fill_filter.
    DATA(ls_result) = mo_cut->zif_allocation_history_reader~read(
      iv_from_date   = '20260801'
      iv_to_date     = '20260820'
      iv_fill_filter = 'X'
      iv_max_rows    = 100 ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Audit fill filter is invalid' ).
    cl_abap_unit_assert=>assert_initial( ls_result-entries ).
  ENDMETHOD.

  METHOD rejects_conflicting_qty.
    DATA(ls_result) = mo_cut->zif_allocation_history_reader~read(
      iv_from_date           = '20260801'
      iv_to_date             = '20260820'
      iv_availability_filter = '-'
      iv_available_qty_to    = 10
      iv_max_rows            = 100 ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Audit availability filters conflict' ).
    cl_abap_unit_assert=>assert_initial( ls_result-entries ).
  ENDMETHOD.

  METHOD rejects_invalid_fill_range.
    DATA(ls_result) = mo_cut->zif_allocation_history_reader~read(
      iv_from_date     = '20260801'
      iv_to_date       = '20260820'
      iv_fill_pct_from = 95
      iv_fill_pct_to   = 80
      iv_max_rows      = 100 ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Audit fill percentage range is invalid' ).
    cl_abap_unit_assert=>assert_initial( ls_result-entries ).
  ENDMETHOD.

  METHOD rejects_invalid_min_fill.
    DATA(ls_result) = mo_cut->zif_allocation_history_reader~read(
      iv_from_date     = '20260801'
      iv_to_date       = '20260820'
      iv_min_fill_from = 75
      iv_min_fill_to   = 50
      iv_max_rows      = 100 ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Audit minimum fill range is invalid' ).
    cl_abap_unit_assert=>assert_initial( ls_result-entries ).
  ENDMETHOD.

  METHOD rejects_invalid_qty_range.
    DATA(ls_result) = mo_cut->zif_allocation_history_reader~read(
      iv_from_date          = '20260801'
      iv_to_date            = '20260820'
      iv_shortfall_qty_from = 10
      iv_shortfall_qty_to   = 5
      iv_max_rows           = 100 ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Audit quantity range is invalid' ).
    cl_abap_unit_assert=>assert_initial( ls_result-entries ).
  ENDMETHOD.

  METHOD rejects_invalid_numeric_range.
    DATA(ls_result) = mo_cut->zif_allocation_history_reader~read(
      iv_from_date          = '20260801'
      iv_to_date            = '20260820'
      iv_allocated_qty_from = 11
      iv_allocated_qty_to   = 10
      iv_max_rows           = 100 ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Audit numeric range is invalid' ).
    cl_abap_unit_assert=>assert_initial( ls_result-entries ).
  ENDMETHOD.

  METHOD rejects_invalid_limit.
    DATA(ls_result) = mo_cut->zif_allocation_history_reader~read(
      iv_from_date = '20260801'
      iv_to_date   = '20260820'
      iv_max_rows  =
        zif_allocation_history_reader=>gc_max_rows_with_sentinel + 1 ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Audit history row limit is invalid' ).
  ENDMETHOD.
ENDCLASS.
