CLASS lcl_allocation_history_store DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_history_store.
    DATA ms_result TYPE zif_allocation_history_store=>ty_result.
    DATA mv_cutoff_date TYPE d.
    DATA mv_simulation TYPE abap_bool.
    DATA mv_calls TYPE i.
ENDCLASS.

CLASS lcl_allocation_history_store IMPLEMENTATION.
  METHOD zif_allocation_history_store~remove_before.
    mv_calls = mv_calls + 1.
    mv_cutoff_date = iv_cutoff_date.
    mv_simulation = iv_simulation.
    rs_result = ms_result.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_allocation_log_retention DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_store TYPE REF TO lcl_allocation_history_store.
    DATA mo_cut TYPE REF TO zcl_allocation_log_retention.

    METHODS setup.
    METHODS calculates_simulation_cutoff FOR TESTING.
    METHODS delegates_productive_cleanup FOR TESTING.
    METHODS rejects_invalid_retention FOR TESTING.
    METHODS rejects_excessive_retention FOR TESTING.
    METHODS rejects_invalid_simulation FOR TESTING.
    METHODS rejects_future_effective_date FOR TESTING.
    METHODS rejects_invalid_store_state FOR TESTING.
    METHODS rejects_negative_store_count FOR TESTING.
    METHODS rejects_failed_store_count FOR TESTING.
    METHODS rejects_missing_store FOR TESTING.
    METHODS validates_before_store FOR TESTING.
    METHODS normalizes_empty_store_failure FOR TESTING.
    METHODS creates_sap_composition FOR TESTING.
ENDCLASS.

CLASS ltcl_allocation_log_retention IMPLEMENTATION.
  METHOD setup.
    mo_store = NEW #( ).
    mo_store->ms_result = VALUE #(
      is_success    = abap_true
      affected_rows = 7
      message       = 'Retention completed' ).
    mo_cut = NEW #( mo_store ).
  ENDMETHOD.

  METHOD calculates_simulation_cutoff.
    DATA(ls_result) = mo_cut->run(
      iv_retention_days = 30
      iv_simulation     = abap_true
      iv_today          = '20260818' ).

    cl_abap_unit_assert=>assert_true( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-affected_rows
      exp = 7 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mv_cutoff_date
      exp = '20260719' ).
    cl_abap_unit_assert=>assert_true( mo_store->mv_simulation ).
  ENDMETHOD.

  METHOD delegates_productive_cleanup.
    DATA(ls_result) = mo_cut->run(
      iv_retention_days = 365
      iv_simulation     = abap_false
      iv_today          = '20260818' ).

    cl_abap_unit_assert=>assert_true( ls_result-is_success ).
    cl_abap_unit_assert=>assert_false( mo_store->mv_simulation ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mv_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD rejects_invalid_retention.
    DATA(ls_result) = mo_cut->run(
      iv_retention_days = 0
      iv_today          = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Retention days must be between 1 and 36500' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mv_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_excessive_retention.
    DATA(ls_result) = mo_cut->run(
      iv_retention_days =
        zcl_allocation_log_retention=>gc_max_retention_days + 1
      iv_today          = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Retention days must be between 1 and 36500' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mv_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_invalid_simulation.
    DATA(ls_result) = mo_cut->run(
      iv_retention_days = 30
      iv_simulation     = 'Y'
      iv_today          = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Retention simulation flag must be X or blank' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mv_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_future_effective_date.
    DATA(ls_result) = mo_cut->run(
      iv_retention_days = 30
      iv_simulation     = abap_true
      iv_today          = '99991231' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Retention effective date must not be in the future' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mv_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_invalid_store_state.
    mo_store->ms_result = VALUE #(
      is_success    = 'Y'
      affected_rows = 7
      message       = 'Misleading success' ).

    DATA(ls_result) = mo_cut->run(
      iv_retention_days = 30
      iv_simulation     = abap_true
      iv_today          = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_initial( ls_result-affected_rows ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Retention store returned invalid state' ).
  ENDMETHOD.

  METHOD rejects_negative_store_count.
    mo_store->ms_result = VALUE #(
      is_success    = abap_true
      affected_rows = -1
      message       = 'Misleading count' ).

    DATA(ls_result) = mo_cut->run(
      iv_retention_days = 30
      iv_simulation     = abap_true
      iv_today          = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_initial( ls_result-affected_rows ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Retention store returned invalid state' ).
  ENDMETHOD.

  METHOD rejects_failed_store_count.
    mo_store->ms_result = VALUE #(
      is_success    = abap_false
      affected_rows = 7
      message       = 'Failed after rows' ).

    DATA(ls_result) = mo_cut->run(
      iv_retention_days = 30
      iv_simulation     = abap_false
      iv_today          = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_initial( ls_result-affected_rows ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Retention store returned invalid state' ).
  ENDMETHOD.

  METHOD rejects_missing_store.
    DATA lo_store TYPE REF TO zif_allocation_history_store.
    mo_cut = NEW #( lo_store ).

    DATA(ls_result) = mo_cut->run(
      iv_retention_days = 30
      iv_simulation     = abap_true
      iv_today          = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Retention store is required' ).
    cl_abap_unit_assert=>assert_initial( ls_result-affected_rows ).
  ENDMETHOD.

  METHOD validates_before_store.
    DATA lo_store TYPE REF TO zif_allocation_history_store.
    mo_cut = NEW #( lo_store ).

    DATA(ls_result) = mo_cut->run(
      iv_retention_days = 0
      iv_simulation     = abap_true
      iv_today          = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Retention days must be between 1 and 36500' ).
  ENDMETHOD.

  METHOD normalizes_empty_store_failure.
    mo_store->ms_result = VALUE #(
      is_success    = abap_false
      affected_rows = 0 ).

    DATA(ls_result) = mo_cut->run(
      iv_retention_days = 30
      iv_simulation     = abap_true
      iv_today          = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Retention cleanup failed' ).
    cl_abap_unit_assert=>assert_initial( ls_result-affected_rows ).
  ENDMETHOD.

  METHOD creates_sap_composition.
    DATA(lo_retention) = zcl_allocation_log_retention=>create_sap( ).

    cl_abap_unit_assert=>assert_bound( lo_retention ).
  ENDMETHOD.
ENDCLASS.
