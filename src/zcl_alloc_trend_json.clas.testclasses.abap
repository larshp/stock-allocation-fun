CLASS ltcl_alloc_trend_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_trend_json.

    METHODS setup.

    METHODS empty_trend FOR TESTING.
    METHODS values      FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_trend_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_trend_json( ).
  ENDMETHOD.

  METHOD empty_trend.
    DATA ls_trend TYPE zcl_alloc_trend=>ty_trend.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( ls_trend )
      exp = '{"count":0,"first_qty":0.000,"last_qty":0.000,' &&
            '"change_pct":0,"direction":""}' ).
  ENDMETHOD.

  METHOD values.
    DATA ls_trend TYPE zcl_alloc_trend=>ty_trend.

    ls_trend-count = 3.
    ls_trend-first_qty = '10'.
    ls_trend-last_qty = '30'.
    ls_trend-change_pct = 200.
    ls_trend-direction = 'U'.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( ls_trend )
      exp = '{"count":3,"first_qty":10.000,"last_qty":30.000,' &&
            '"change_pct":200,"direction":"U"}' ).
  ENDMETHOD.

ENDCLASS.
