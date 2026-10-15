CLASS ltcl_alloc_restock_fee DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_restock_fee.

    METHODS setup.

    METHODS computes_fee      FOR TESTING.
    METHODS guards_fee        FOR TESTING.
    METHODS computes_percent  FOR TESTING.
    METHODS applies_only_commercial FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_restock_fee IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_restock_fee( ).
  ENDMETHOD.

  METHOD computes_fee.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->fee( iv_value = 200 iv_fee_percent = 10 )
      exp = 20 ).
  ENDMETHOD.

  METHOD guards_fee.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->fee( iv_value = 200 iv_fee_percent = -1 )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->fee( iv_value = 0 iv_fee_percent = 10 )
      exp = 0 ).
  ENDMETHOD.

  METHOD computes_percent.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->fee_percent( iv_value = 200 iv_fee = 20 )
      exp = 10 ).
  ENDMETHOD.

  METHOD applies_only_commercial.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->applies( 'COMMERCIAL' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->applies( 'QUALITY' ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->applies( 'LOGISTICS' ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
