CLASS ltcl_alloc_prep_filter DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_prep_filter.
    DATA mt_line TYPE zcl_alloc_prep_filter=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_order TYPE string
        iv_cost  TYPE i.

    METHODS filters_rows FOR TESTING.
    METHODS over_rule    FOR TESTING.
    METHODS counts_rows  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_prep_filter IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_prep_filter( ).

    add( iv_order = 'O1' iv_cost = 100 ).
    add( iv_order = 'O2' iv_cost = 50 ).
    add( iv_order = 'O3' iv_cost = 200 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_prep_filter=>ty_line.

    ls_line-order_id = iv_order.
    ls_line-cost = iv_cost.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD filters_rows.
    DATA lt_lines TYPE zcl_alloc_prep_filter=>ty_line_tt.

    lt_lines = mo_cut->filter( it_lines = mt_line iv_min_cost = 100 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-cost exp = 100 ).
  ENDMETHOD.

  METHOD over_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_over( iv_cost = 100 iv_min_cost = 100 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_over( iv_cost = 50 iv_min_cost = 100 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD counts_rows.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count( it_lines = mt_line iv_min_cost = 100 ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
