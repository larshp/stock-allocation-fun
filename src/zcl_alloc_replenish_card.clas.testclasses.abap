CLASS ltcl_alloc_replenish_card DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_replenish_card.
    DATA mt_line TYPE zcl_alloc_replenish_card=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_quantity TYPE i.

    METHODS builds_card    FOR TESTING.
    METHODS sums_quantity  FOR TESTING.
    METHODS target_rule    FOR TESTING.
    METHODS empty_input    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_replenish_card IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_replenish_card( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_replenish_card=>ty_line.

    ls_line-material = iv_material.
    ls_line-quantity = iv_quantity.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_card.
    DATA ls_plan TYPE zcl_alloc_replenish_card=>ty_plan.

    add( iv_material = 'M1' iv_quantity = 10 ).
    add( iv_material = 'M2' iv_quantity = 5 ).

    ls_plan = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = ls_plan-plan_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_plan-total_quantity exp = 15 ).
  ENDMETHOD.

  METHOD sums_quantity.
    add( iv_material = 'M1' iv_quantity = 10 ).
    add( iv_material = 'M2' iv_quantity = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_quantity( mt_line ) exp = 15 ).
  ENDMETHOD.

  METHOD target_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->on_target( iv_total_quantity  = 15
                               iv_target_quantity = 10 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->on_target( iv_total_quantity  = 5
                               iv_target_quantity = 10 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_quantity( mt_line ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
