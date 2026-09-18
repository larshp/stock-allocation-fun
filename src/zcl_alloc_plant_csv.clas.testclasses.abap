CLASS ltcl_alloc_plant_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_plant_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS one_line    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_plant_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_plant_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA lt_plants TYPE zcl_alloc_plant_report=>ty_line_tt.

    DATA(lt_lines) = mo_cut->build( lt_plants ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ]
      exp = 'WERKS;LINES;REQUESTED_QTY;ALLOCATED_QTY;SHORTAGE_QTY;COVERAGE_PCT' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_plants TYPE zcl_alloc_plant_report=>ty_line_tt.
    DATA ls_plant  TYPE zcl_alloc_plant_report=>ty_line.

    ls_plant-werks = '1000'.
    ls_plant-lines = 2.
    ls_plant-requested_qty = '20'.
    ls_plant-allocated_qty = '15'.
    ls_plant-shortage_qty = '5'.
    ls_plant-coverage_pct = 75.
    APPEND ls_plant TO lt_plants.

    DATA(lt_lines) = mo_cut->build( lt_plants ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 2 ]
      exp = '1000;2;20.000;15.000;5.000;75' ).
  ENDMETHOD.

ENDCLASS.
