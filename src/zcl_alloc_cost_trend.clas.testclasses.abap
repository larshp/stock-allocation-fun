CLASS ltcl_alloc_cost_trend DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cost_trend.
    DATA mt_val TYPE zcl_alloc_cost_trend=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS picks_direction FOR TESTING.
    METHODS computes_delta  FOR TESTING.
    METHODS rising_rule     FOR TESTING.
    METHODS single_point    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cost_trend IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cost_trend( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_val.
  ENDMETHOD.

  METHOD picks_direction.
    add( 10 ).
    add( 20 ).
    add( 30 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( mt_val ) exp = 'RISING' ).

    CLEAR mt_val.
    add( 30 ).
    add( 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( mt_val ) exp = 'FALLING' ).
  ENDMETHOD.

  METHOD computes_delta.
    add( 10 ).
    add( 20 ).
    add( 30 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->delta( mt_val ) exp = 20 ).
  ENDMETHOD.

  METHOD rising_rule.
    add( 10 ).
    add( 30 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_rising( mt_val ) exp = abap_true ).

    CLEAR mt_val.
    add( 30 ).
    add( 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_rising( mt_val ) exp = abap_false ).
  ENDMETHOD.

  METHOD single_point.
    add( 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( mt_val ) exp = 'FLAT' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->delta( mt_val ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
