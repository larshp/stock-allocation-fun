CLASS ltcl_alloc_forecast_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_forecast_json.

    METHODS setup.

    METHODS empty_values FOR TESTING.
    METHODS one_value    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_forecast_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_forecast_json( ).
  ENDMETHOD.

  METHOD empty_values.
    DATA ls_input TYPE zcl_alloc_forecast_json=>ty_input.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( ls_input )
      exp = '{"forecast":0.000,"window":0,"values":[]}' ).
  ENDMETHOD.

  METHOD one_value.
    DATA ls_input TYPE zcl_alloc_forecast_json=>ty_input.

    APPEND '20' TO ls_input-values.
    ls_input-window = 1.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( ls_input )
      exp = '{"forecast":20.000,"window":1,"values":[20.000]}' ).
  ENDMETHOD.

ENDCLASS.
