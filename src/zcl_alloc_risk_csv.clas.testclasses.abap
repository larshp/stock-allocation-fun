CLASS ltcl_alloc_risk_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_risk_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS values_row  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_risk_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_risk_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA ls_risk TYPE zcl_alloc_risk=>ty_risk.

    DATA(lt_lines) = mo_cut->build( ls_risk ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ]
      exp = 'LINES;SHORTAGE_QTY;RISK_PCT;LEVEL' ).
  ENDMETHOD.

  METHOD values_row.
    DATA ls_risk TYPE zcl_alloc_risk=>ty_risk.

    ls_risk-lines = 2.
    ls_risk-shortage_qty = '6'.
    ls_risk-risk_pct = 20.
    ls_risk-level = 'L'.

    DATA(lt_lines) = mo_cut->build( ls_risk ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = '2;6.000;20;L' ).
  ENDMETHOD.

ENDCLASS.
