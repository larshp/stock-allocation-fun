CLASS ltcl_alloc_act_step DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_act_step.
    DATA mt_line TYPE zcl_alloc_act_step=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_name TYPE string
        iv_cost TYPE i.

    METHODS computes_step FOR TESTING.
    METHODS stepped_rule  FOR TESTING.
    METHODS counts_steps  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_act_step IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_act_step( ).

    add( iv_name = 'A' iv_cost = 250 ).
    add( iv_name = 'B' iv_cost = 200 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_act_step=>ty_line.

    ls_line-name = iv_name.
    ls_line-cost = iv_cost.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD computes_step.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->step( iv_cost = 250 iv_step_size = 100 )
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->step( iv_cost = 200 iv_step_size = 100 )
      exp = 2 ).
  ENDMETHOD.

  METHOD stepped_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_stepped( iv_cost = 250 iv_step_size = 100 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_stepped( iv_cost = 200 iv_step_size = 100 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD counts_steps.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->step_count( it_lines = mt_line iv_step_size = 100 )
      exp = 5 ).
  ENDMETHOD.

ENDCLASS.
