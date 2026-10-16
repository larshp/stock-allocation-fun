CLASS ltcl_alloc_space_util DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_space_util.

    METHODS setup.

    METHODS percent_half    FOR TESTING.
    METHODS percent_zero    FOR TESTING.
    METHODS percent_full    FOR TESTING.
    METHODS over_threshold  FOR TESTING.
    METHODS under_threshold FOR TESTING.
    METHODS classify_empty  FOR TESTING.
    METHODS classify_low    FOR TESTING.
    METHODS classify_full   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_space_util IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_space_util( ).
  ENDMETHOD.

  METHOD percent_half.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->percent( iv_used = 50 iv_total = 100 ) exp = 50 ).
  ENDMETHOD.

  METHOD percent_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->percent( iv_used = 10 iv_total = 0 ) exp = 0 ).
  ENDMETHOD.

  METHOD percent_full.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->percent( iv_used = 100 iv_total = 100 ) exp = 100 ).
  ENDMETHOD.

  METHOD over_threshold.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->above_threshold( iv_used = 90 iv_total = 100
                                     iv_threshold = 80 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD under_threshold.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->above_threshold( iv_used = 50 iv_total = 100
                                     iv_threshold = 80 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD classify_empty.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( iv_used = 0 iv_total = 100 ) exp = 'EMPTY' ).
  ENDMETHOD.

  METHOD classify_low.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( iv_used = 25 iv_total = 100 ) exp = 'LOW' ).
  ENDMETHOD.

  METHOD classify_full.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( iv_used = 100 iv_total = 100 ) exp = 'FULL' ).
  ENDMETHOD.

ENDCLASS.
