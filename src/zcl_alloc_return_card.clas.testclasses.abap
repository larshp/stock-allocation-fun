CLASS ltcl_alloc_return_card DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_card.

    METHODS setup.

    METHODS builds_card    FOR TESTING.
    METHODS maps_over      FOR TESTING.
    METHODS total_value    FOR TESTING.
    METHODS target_rule    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_card IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_card( ).
  ENDMETHOD.

  METHOD builds_card.
    DATA ls_card TYPE zcl_alloc_return_card=>ty_card.

    ls_card = mo_cut->build( iv_returns = 25 iv_target = 30
                             iv_unit_value = 10 ).

    cl_abap_unit_assert=>assert_equals( act = ls_card-total exp = 250 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_card-on_target exp = abap_true ).
  ENDMETHOD.

  METHOD maps_over.
    DATA ls_card TYPE zcl_alloc_return_card=>ty_card.

    ls_card = mo_cut->build( iv_returns = 40 iv_target = 30
                             iv_unit_value = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_card-on_target exp = abap_false ).
  ENDMETHOD.

  METHOD total_value.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( iv_returns = 25 iv_unit_value = 10 )
      exp = 250 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( iv_returns = 0 iv_unit_value = 10 )
      exp = 0 ).
  ENDMETHOD.

  METHOD target_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->on_target( iv_returns = 30 iv_target = 30 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->on_target( iv_returns = 31 iv_target = 30 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
