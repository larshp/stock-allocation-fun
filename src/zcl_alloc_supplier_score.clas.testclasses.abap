CLASS ltcl_alloc_supplier_score DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_supplier_score.

    METHODS setup.

    METHODS computes_score FOR TESTING.
    METHODS grades         FOR TESTING.
    METHODS preferred_rule FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_supplier_score IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_supplier_score( ).
  ENDMETHOD.

  METHOD computes_score.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( iv_otd_percent = 100 iv_quality_percent = 100
                           iv_price_percent = 100 )
      exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( iv_otd_percent = 80 iv_quality_percent = 90
                           iv_price_percent = 70 )
      exp = 81 ).
  ENDMETHOD.

  METHOD grades.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->grade( 95 ) exp = 'A' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->grade( 81 ) exp = 'B' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->grade( 50 ) exp = 'D' ).
  ENDMETHOD.

  METHOD preferred_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_preferred( 95 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_preferred( 81 ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
