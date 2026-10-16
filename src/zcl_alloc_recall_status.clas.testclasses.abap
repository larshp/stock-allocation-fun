CLASS ltcl_alloc_recall_status DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_recall_status.

    METHODS setup.

    METHODS status_stages     FOR TESTING.
    METHODS none_status       FOR TESTING.
    METHODS percent_value     FOR TESTING.
    METHODS percent_capped    FOR TESTING.
    METHODS completion_rule   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_recall_status IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_recall_status( ).
  ENDMETHOD.

  METHOD status_stages.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->status( iv_expected = 100 iv_recovered = 100 )
      exp = 'COMPLETE' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->status( iv_expected = 100 iv_recovered = 40 )
      exp = 'IN_PROGRESS' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->status( iv_expected = 100 iv_recovered = 0 )
      exp = 'OPEN' ).
  ENDMETHOD.

  METHOD none_status.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->status( iv_expected = 0 iv_recovered = 0 )
      exp = 'NONE' ).
  ENDMETHOD.

  METHOD percent_value.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->recovered_percent( iv_expected = 100 iv_recovered = 40 )
      exp = 40 ).
  ENDMETHOD.

  METHOD percent_capped.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->recovered_percent( iv_expected = 100 iv_recovered = 150 )
      exp = 100 ).
  ENDMETHOD.

  METHOD completion_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_complete( iv_expected = 100 iv_recovered = 100 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_complete( iv_expected = 100 iv_recovered = 40 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
