CLASS ltcl_alloc_margin_pct DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_margin_pct.

    METHODS setup.

    METHODS reads_share   FOR TESTING.
    METHODS applies_rate  FOR TESTING.
    METHODS improvement   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_margin_pct IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_margin_pct( ).
  ENDMETHOD.

  METHOD reads_share.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->of_revenue( iv_margin = 500 iv_revenue = 1500 )
      exp = 33 ).
  ENDMETHOD.

  METHOD applies_rate.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->apply( iv_revenue = 1500 iv_percent = 33 )
      exp = 495 ).
  ENDMETHOD.

  METHOD improvement.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_improved( iv_old_percent = 30 iv_new_percent = 35 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_improved( iv_old_percent = 35 iv_new_percent = 30 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
