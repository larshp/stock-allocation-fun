CLASS ltcl_allocation_log_store_sap DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_allocation_log_store_sap.

    METHODS setup.
    METHODS rejects_invalid_simulation FOR TESTING.
    METHODS rejects_initial_cutoff FOR TESTING.
    METHODS rejects_current_cutoff FOR TESTING.
ENDCLASS.

CLASS ltcl_allocation_log_store_sap IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD rejects_invalid_simulation.
    DATA(ls_result) = mo_cut->zif_allocation_history_store~remove_before(
      iv_cutoff_date = '20260801'
      iv_simulation  = 'Y' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Retention simulation flag must be X or blank' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-affected_rows
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_initial_cutoff.
    DATA(ls_result) = mo_cut->zif_allocation_history_store~remove_before(
      iv_cutoff_date = '00000000'
      iv_simulation  = abap_true ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Retention cutoff date must not be initial' ).
  ENDMETHOD.

  METHOD rejects_current_cutoff.
    DATA(ls_result) = mo_cut->zif_allocation_history_store~remove_before(
      iv_cutoff_date = sy-datum
      iv_simulation  = abap_true ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Retention cutoff date must be before today' ).
  ENDMETHOD.
ENDCLASS.
