CLASS ltcl_alloc_stock_projection DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_stock_projection.
    DATA mt_dem TYPE zcl_alloc_stock_projection=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS projects_stock FOR TESTING.
    METHODS finds_zero     FOR TESTING.
    METHODS never_runs_out FOR TESTING.
    METHODS empty_input    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_stock_projection IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_stock_projection( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_dem.
  ENDMETHOD.

  METHOD projects_stock.
    DATA lt_stock TYPE zcl_alloc_stock_projection=>ty_values_tt.

    add( 30 ).
    add( 40 ).
    add( 40 ).

    lt_stock = mo_cut->project( it_demands = mt_dem iv_start_stock = 100 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_stock ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_stock[ 1 ] exp = 70 ).
    cl_abap_unit_assert=>assert_equals( act = lt_stock[ 2 ] exp = 30 ).
    cl_abap_unit_assert=>assert_equals( act = lt_stock[ 3 ] exp = -10 ).
  ENDMETHOD.

  METHOD finds_zero.
    add( 30 ).
    add( 40 ).
    add( 40 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->first_zero( it_demands = mt_dem iv_start_stock = 100 )
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->runs_out( it_demands = mt_dem iv_start_stock = 100 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD never_runs_out.
    add( 10 ).
    add( 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->first_zero( it_demands = mt_dem iv_start_stock = 100 )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->runs_out( it_demands = mt_dem iv_start_stock = 100 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->runs_out( it_demands = mt_dem iv_start_stock = 100 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
