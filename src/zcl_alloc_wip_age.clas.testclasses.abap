CLASS ltcl_alloc_wip_age DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_wip_age.

    METHODS setup.

    METHODS computes_days FOR TESTING.
    METHODS stale_rule    FOR TESTING.
    METHODS reads_bucket  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_wip_age IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_wip_age( ).
  ENDMETHOD.

  METHOD computes_days.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->days_old( iv_created = 10 iv_today = 40 )
      exp = 30 ).
  ENDMETHOD.

  METHOD stale_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_stale( iv_days_old = 100 iv_limit = 90 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_stale( iv_days_old = 50 iv_limit = 90 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD reads_bucket.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->bucket( 20 ) exp = 'FRESH' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->bucket( 60 ) exp = 'AGING' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->bucket( 120 ) exp = 'STALE' ).
  ENDMETHOD.

ENDCLASS.
