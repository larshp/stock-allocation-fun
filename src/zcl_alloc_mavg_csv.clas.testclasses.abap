CLASS ltcl_alloc_mavg_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_mavg_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS one_line    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_mavg_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_mavg_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA lt_avgs TYPE zcl_alloc_moving_average=>ty_line_tt.

    DATA(lt_lines) = mo_cut->build( lt_avgs ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]
                                        exp = 'INDEX;QUANTITY;AVERAGE' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_avgs TYPE zcl_alloc_moving_average=>ty_line_tt.
    DATA ls_avg  TYPE zcl_alloc_moving_average=>ty_line.

    ls_avg-index = 2.
    ls_avg-quantity = '20'.
    ls_avg-average = '15'.
    APPEND ls_avg TO lt_avgs.

    DATA(lt_lines) = mo_cut->build( lt_avgs ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = '2;20.000;15.000' ).
  ENDMETHOD.

ENDCLASS.
