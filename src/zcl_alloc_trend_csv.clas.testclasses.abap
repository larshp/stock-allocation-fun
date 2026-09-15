CLASS ltcl_alloc_trend_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_trend_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS values_row  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_trend_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_trend_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA ls_trend TYPE zcl_alloc_trend=>ty_trend.

    DATA(lt_lines) = mo_cut->build( ls_trend ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ]
      exp = 'COUNT;FIRST_QTY;LAST_QTY;CHANGE_PCT;DIRECTION' ).
  ENDMETHOD.

  METHOD values_row.
    DATA ls_trend TYPE zcl_alloc_trend=>ty_trend.

    ls_trend-count = 3.
    ls_trend-first_qty = '10'.
    ls_trend-last_qty = '30'.
    ls_trend-change_pct = 200.
    ls_trend-direction = 'U'.

    DATA(lt_lines) = mo_cut->build( ls_trend ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = '3;10.000;30.000;200;U' ).
  ENDMETHOD.

ENDCLASS.
