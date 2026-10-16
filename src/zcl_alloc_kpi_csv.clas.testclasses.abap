CLASS ltcl_alloc_kpi_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_kpi_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS values_row  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_kpi_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_kpi_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA ls_kpi TYPE zcl_alloc_kpi=>ty_kpi.

    DATA(lt_lines) = mo_cut->build( ls_kpi ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ]
      exp = 'REQUIREMENTS;FULLY_DELIVERED;SHORT;REQUESTED_QTY;' &&
            'ALLOCATED_QTY;SHORTAGE_QTY;COVERAGE_PCT;FILL_RATE_PCT' ).
  ENDMETHOD.

  METHOD values_row.
    DATA ls_kpi TYPE zcl_alloc_kpi=>ty_kpi.

    ls_kpi-requirements = 3.
    ls_kpi-fully_delivered = 2.
    ls_kpi-short = 1.
    ls_kpi-requested_qty = '30'.
    ls_kpi-allocated_qty = '24'.
    ls_kpi-shortage_qty = '6'.
    ls_kpi-coverage_pct = 80.
    ls_kpi-fill_rate_pct = 66.

    DATA(lt_lines) = mo_cut->build( ls_kpi ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 2 ]
      exp = '3;2;1;30.000;24.000;6.000;80;66' ).
  ENDMETHOD.

ENDCLASS.
