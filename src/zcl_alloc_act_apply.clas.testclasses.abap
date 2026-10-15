CLASS ltcl_alloc_act_apply DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_act_apply.
    DATA mt_line TYPE zcl_alloc_act_apply=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_activity TYPE string
        iv_quantity TYPE i.

    METHODS applies_rate FOR TESTING.
    METHODS costs_one    FOR TESTING.
    METHODS applied_rule FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_act_apply IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_act_apply( ).

    add( iv_activity = 'A' iv_quantity = 100 ).
    add( iv_activity = 'B' iv_quantity = 200 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_act_apply=>ty_line.

    ls_line-activity = iv_activity.
    ls_line-quantity = iv_quantity.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD applies_rate.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->apply( it_lines = mt_line iv_rate = 2 )
      exp = 600 ).
  ENDMETHOD.

  METHOD costs_one.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cost_of( iv_quantity = 100 iv_rate = 2 )
      exp = 200 ).
  ENDMETHOD.

  METHOD applied_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_applied( 600 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_applied( 0 ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
