CLASS ltcl_alloc_margin_delta DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_margin_delta.

    METHODS setup.

    METHODS computes_delta FOR TESTING.
    METHODS up_rule        FOR TESTING.
    METHODS computes_percent FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_margin_delta IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_margin_delta( ).
  ENDMETHOD.

  METHOD computes_delta.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->delta( iv_old_margin = 500 iv_new_margin = 600 )
      exp = 100 ).
  ENDMETHOD.

  METHOD up_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_up( iv_old_margin = 500 iv_new_margin = 600 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_up( iv_old_margin = 600 iv_new_margin = 500 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_percent.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->percent( iv_old_margin = 500 iv_new_margin = 600 )
      exp = 20 ).
  ENDMETHOD.

ENDCLASS.
