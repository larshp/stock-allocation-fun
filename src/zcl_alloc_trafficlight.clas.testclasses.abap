CLASS ltcl_alloc_trafficlight DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_trafficlight.

    METHODS setup.

    METHODS make_limits
      IMPORTING
        iv_warn          TYPE menge_d
        iv_error         TYPE menge_d
      RETURNING
        VALUE(rs_limits) TYPE zcl_alloc_trafficlight=>ty_limits.

    METHODS green_inside  FOR TESTING.
    METHODS yellow_band   FOR TESTING.
    METHODS red_above     FOR TESTING.
    METHODS edges_are_in  FOR TESTING.
    METHODS text_labels   FOR TESTING.
    METHODS unknown_light FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_trafficlight IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_trafficlight( ).
  ENDMETHOD.

  METHOD make_limits.
    rs_limits-warning_max = iv_warn.
    rs_limits-error_max = iv_error.
  ENDMETHOD.

  METHOD green_inside.
    DATA(ls_limits) = make_limits( iv_warn = 10 iv_error = 20 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->of_value( is_limits = ls_limits iv_value = 5 ) exp = 1 ).
  ENDMETHOD.

  METHOD yellow_band.
    DATA(ls_limits) = make_limits( iv_warn = 10 iv_error = 20 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->of_value( is_limits = ls_limits iv_value = 15 ) exp = 2 ).
  ENDMETHOD.

  METHOD red_above.
    DATA(ls_limits) = make_limits( iv_warn = 10 iv_error = 20 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->of_value( is_limits = ls_limits iv_value = 25 ) exp = 3 ).
  ENDMETHOD.

  METHOD edges_are_in.
    DATA(ls_limits) = make_limits( iv_warn = 10 iv_error = 20 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->of_value( is_limits = ls_limits iv_value = 10 ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->of_value( is_limits = ls_limits iv_value = 20 ) exp = 2 ).
  ENDMETHOD.

  METHOD text_labels.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->text_of( 1 ) exp = 'green' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->text_of( 2 ) exp = 'yellow' ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->text_of( 3 ) exp = 'red' ).
  ENDMETHOD.

  METHOD unknown_light.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->text_of( 0 ) exp = 'unknown' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->text_of( 9 ) exp = 'unknown' ).
  ENDMETHOD.

ENDCLASS.
