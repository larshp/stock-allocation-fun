CLASS ltcl_alloc_valm_trend DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_valm_trend.
    DATA mt_values TYPE zcl_alloc_valm_trend=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS reads_direction FOR TESTING.
    METHODS rising_rule     FOR TESTING.
    METHODS counts_streak   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_valm_trend IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_valm_trend( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_values.
  ENDMETHOD.

  METHOD reads_direction.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( iv_previous = 1000 iv_current = 1200 )
      exp = 'UP' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( iv_previous = 1200 iv_current = 1000 )
      exp = 'DOWN' ).
  ENDMETHOD.

  METHOD rising_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_rising( iv_previous = 1000 iv_current = 1200 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_rising( iv_previous = 1200 iv_current = 1000 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD counts_streak.
    add( iv_value = 1000 ).
    add( iv_value = 1050 ).
    add( iv_value = 1100 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->streak( mt_values ) exp = 2 ).

    add( iv_value = 1000 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->streak( mt_values ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
