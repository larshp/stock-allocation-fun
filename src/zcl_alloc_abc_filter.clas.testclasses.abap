CLASS ltcl_alloc_abc_filter DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_abc_filter.
    DATA mt_line TYPE zcl_alloc_abc_filter=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_activity TYPE string
        iv_cost     TYPE i.

    METHODS filters_lines FOR TESTING.
    METHODS over_rule     FOR TESTING.
    METHODS counts_over   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_abc_filter IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_abc_filter( ).

    add( iv_activity = 'A' iv_cost = 600 ).
    add( iv_activity = 'B' iv_cost = 300 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_abc_filter=>ty_line.

    ls_line-activity = iv_activity.
    ls_line-cost = iv_cost.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD filters_lines.
    DATA lt_over TYPE zcl_alloc_abc_filter=>ty_line_tt.

    lt_over = mo_cut->filter( it_lines = mt_line iv_limit = 400 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_over ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_over[ 1 ]-activity exp = 'A' ).
  ENDMETHOD.

  METHOD over_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_over( iv_cost = 600 iv_limit = 400 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_over( iv_cost = 300 iv_limit = 400 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD counts_over.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count( it_lines = mt_line iv_limit = 400 )
      exp = 1 ).
  ENDMETHOD.

ENDCLASS.
