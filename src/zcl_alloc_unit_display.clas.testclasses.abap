CLASS ltcl_alloc_unit_display DEFINITION
  FOR TESTING
    DURATION SHORT
    RISK LEVEL HARMLESS
    FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_unit_display.

    METHODS setup.

    METHODS make_input
      IMPORTING
        iv_qty          TYPE menge_d
        iv_unit         TYPE meins
        iv_dec          TYPE i
      RETURNING
        VALUE(rs_input) TYPE zcl_alloc_unit_display=>ty_input.

    METHODS whole_number   FOR TESTING.
    METHODS one_decimal    FOR TESTING.
    METHODS two_decimals   FOR TESTING.
    METHODS clamps_low     FOR TESTING.
    METHODS clamps_high    FOR TESTING.
    METHODS keeps_unit     FOR TESTING.
    METHODS zero_quantity  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_unit_display IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_unit_display( ).
  ENDMETHOD.

  METHOD make_input.
    rs_input-quantity = iv_qty.
    rs_input-unit = iv_unit.
    rs_input-decimals = iv_dec.
  ENDMETHOD.

  METHOD whole_number.
    DATA(ls_input) = make_input( iv_qty = '12.5' iv_unit = 'STK' iv_dec = 0 ).
    DATA(ls_result) = mo_cut->format( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-factor exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-scaled exp = 12 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-decimals exp = 0 ).
  ENDMETHOD.

  METHOD one_decimal.
    DATA(ls_input) = make_input( iv_qty = '12.5' iv_unit = 'STK' iv_dec = 1 ).
    DATA(ls_result) = mo_cut->format( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-factor exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-scaled exp = 125 ).
  ENDMETHOD.

  METHOD two_decimals.
    DATA(ls_input) = make_input( iv_qty = '12.5' iv_unit = 'STK' iv_dec = 2 ).
    DATA(ls_result) = mo_cut->format( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-factor exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-scaled exp = 1250 ).
  ENDMETHOD.

  METHOD clamps_low.
    DATA(ls_input) = make_input( iv_qty = '7.9' iv_unit = 'KG' iv_dec = -2 ).
    DATA(ls_result) = mo_cut->format( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-decimals exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-factor exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-scaled exp = 7 ).
  ENDMETHOD.

  METHOD clamps_high.
    DATA(ls_input) = make_input( iv_qty = '12.5' iv_unit = 'STK' iv_dec = 9 ).
    DATA(ls_result) = mo_cut->format( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-decimals exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-factor exp = 1000 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-scaled exp = 12500 ).
  ENDMETHOD.

  METHOD keeps_unit.
    DATA(ls_input) = make_input( iv_qty = 1 iv_unit = 'STK' iv_dec = 0 ).
    DATA(ls_result) = mo_cut->format( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-unit exp = 'STK' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-quantity exp = 1 ).
  ENDMETHOD.

  METHOD zero_quantity.
    DATA(ls_input) = make_input( iv_qty = 0 iv_unit = 'KG' iv_dec = 2 ).
    DATA(ls_result) = mo_cut->format( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-scaled exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-factor exp = 100 ).
  ENDMETHOD.

ENDCLASS.
