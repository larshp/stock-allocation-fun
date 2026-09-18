CLASS ltcl_alloc_forecast_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_forecast_csv.

    METHODS setup.

    METHODS empty_values   FOR TESTING.
    METHODS three_values   FOR TESTING.
    METHODS explicit_window FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_forecast_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_forecast_csv( ).
  ENDMETHOD.

  METHOD empty_values.
    DATA ls_input TYPE zcl_alloc_forecast_csv=>ty_input.

    DATA(lt_lines) = mo_cut->build( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]
                                        exp = 'INDEX;QUANTITY' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = 'FORECAST;0.000' ).
  ENDMETHOD.

  METHOD three_values.
    DATA ls_input TYPE zcl_alloc_forecast_csv=>ty_input.

    APPEND '10' TO ls_input-values.
    APPEND '20' TO ls_input-values.
    APPEND '30' TO ls_input-values.
    ls_input-window = 3.

    DATA(lt_lines) = mo_cut->build( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = '1;10.000' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 4 ]
                                        exp = '3;30.000' ).
  ENDMETHOD.

  METHOD explicit_window.
    DATA ls_input TYPE zcl_alloc_forecast_csv=>ty_input.

    APPEND '10' TO ls_input-values.
    APPEND '20' TO ls_input-values.
    ls_input-window = 1.

    DATA(lt_lines) = mo_cut->build( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 4 ]
                                        exp = 'FORECAST;20.000' ).
  ENDMETHOD.

ENDCLASS.
