CLASS ltcl_alloc_mavg_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_mavg_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS one_line   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_mavg_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_mavg_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_avgs TYPE zcl_alloc_moving_average=>ty_line_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_avgs )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_avgs TYPE zcl_alloc_moving_average=>ty_line_tt.
    DATA ls_avg  TYPE zcl_alloc_moving_average=>ty_line.

    ls_avg-index = 2.
    ls_avg-quantity = '20'.
    ls_avg-average = '15'.
    APPEND ls_avg TO lt_avgs.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_avgs )
      exp = '[{"index":2,"quantity":20.000,"average":15.000}]' ).
  ENDMETHOD.

ENDCLASS.
