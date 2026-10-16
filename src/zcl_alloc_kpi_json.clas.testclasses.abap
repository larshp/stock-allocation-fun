CLASS ltcl_alloc_kpi_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_kpi_json.

    METHODS setup.

    METHODS empty_kpi FOR TESTING.
    METHODS values    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_kpi_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_kpi_json( ).
  ENDMETHOD.

  METHOD empty_kpi.
    DATA ls_kpi TYPE zcl_alloc_kpi=>ty_kpi.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( ls_kpi )
      exp = '{"requirements":0,"fully_delivered":0,"short":0,' &&
            '"requested_qty":0.000,"allocated_qty":0.000,' &&
            '"shortage_qty":0.000,"coverage_pct":0,"fill_rate_pct":0}' ).
  ENDMETHOD.

  METHOD values.
    DATA ls_kpi TYPE zcl_alloc_kpi=>ty_kpi.

    ls_kpi-requirements = 3.
    ls_kpi-coverage_pct = 80.
    ls_kpi-fill_rate_pct = 66.

    DATA(lv_json) = mo_cut->build( ls_kpi ).

    cl_abap_unit_assert=>assert_differs(
      act = find( val = lv_json sub = '"requirements":3' )
      exp = -1 ).
    cl_abap_unit_assert=>assert_differs(
      act = find( val = lv_json sub = '"fill_rate_pct":66' )
      exp = -1 ).
  ENDMETHOD.

ENDCLASS.
