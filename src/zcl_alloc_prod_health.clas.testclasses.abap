CLASS ltcl_alloc_prod_health DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_prod_health.
    DATA mt_line TYPE zcl_alloc_prod_health=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_order   TYPE string
        iv_cost    TYPE i
        iv_planned TYPE i.

    METHODS healthy_rule FOR TESTING.
    METHODS counts_issues FOR TESTING.
    METHODS computes_score FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_prod_health IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_prod_health( ).

    add( iv_order = 'O1' iv_cost = 100 iv_planned = 100 ).
    add( iv_order = 'O2' iv_cost = 130 iv_planned = 100 ).
    add( iv_order = 'O3' iv_cost = 105 iv_planned = 100 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_prod_health=>ty_line.

    ls_line-order_id = iv_order.
    ls_line-cost = iv_cost.
    ls_line-planned = iv_planned.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD healthy_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_healthy( it_lines = mt_line iv_tolerance = 50 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_healthy( it_lines = mt_line iv_tolerance = 10 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD counts_issues.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->issue_count( it_lines = mt_line iv_tolerance = 10 )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->issue_count( it_lines = mt_line iv_tolerance = 50 )
      exp = 0 ).
  ENDMETHOD.

  METHOD computes_score.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( it_lines = mt_line iv_tolerance = 10 )
      exp = 66 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( it_lines = mt_line iv_tolerance = 50 )
      exp = 100 ).
  ENDMETHOD.

ENDCLASS.
