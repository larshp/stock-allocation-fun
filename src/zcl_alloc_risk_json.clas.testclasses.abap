CLASS ltcl_alloc_risk_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_risk_json.

    METHODS setup.

    METHODS empty_risk FOR TESTING.
    METHODS values     FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_risk_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_risk_json( ).
  ENDMETHOD.

  METHOD empty_risk.
    DATA ls_risk TYPE zcl_alloc_risk=>ty_risk.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( ls_risk )
      exp = '{"lines":0,"shortage_qty":0.000,"risk_pct":0,"level":""}' ).
  ENDMETHOD.

  METHOD values.
    DATA ls_risk TYPE zcl_alloc_risk=>ty_risk.

    ls_risk-lines = 2.
    ls_risk-shortage_qty = '6'.
    ls_risk-risk_pct = 20.
    ls_risk-level = 'L'.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( ls_risk )
      exp = '{"lines":2,"shortage_qty":6.000,"risk_pct":20,"level":"L"}' ).
  ENDMETHOD.

ENDCLASS.
