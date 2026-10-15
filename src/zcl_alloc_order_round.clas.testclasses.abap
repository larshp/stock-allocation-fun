CLASS ltcl_alloc_order_round DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_order_round.

    METHODS setup.

    METHODS rounds_up    FOR TESTING.
    METHODS rounds_down  FOR TESTING.
    METHODS exact_rule   FOR TESTING.
    METHODS guards_input FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_order_round IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_order_round( ).
  ENDMETHOD.

  METHOD rounds_up.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->round_up( iv_quantity = 13 iv_round_to = 5 )
      exp = 15 ).
  ENDMETHOD.

  METHOD rounds_down.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->round_down( iv_quantity = 13 iv_round_to = 5 )
      exp = 10 ).
  ENDMETHOD.

  METHOD exact_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_exact( iv_quantity = 15 iv_round_to = 5 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_exact( iv_quantity = 13 iv_round_to = 5 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD guards_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->round_up( iv_quantity = 13 iv_round_to = 0 )
      exp = 13 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_exact( iv_quantity = 15 iv_round_to = 0 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
