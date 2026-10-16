CLASS ltcl_alloc_plant_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_plant_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS one_line   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_plant_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_plant_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_plants TYPE zcl_alloc_plant_report=>ty_line_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_plants )
                                        exp = '[]' ).
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

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_plants )
      exp = '[{"werks":"1000","lines":2,"requested_qty":20.000,' &&
            '"allocated_qty":15.000,"shortage_qty":5.000,' &&
            '"coverage_pct":75}]' ).
  ENDMETHOD.

ENDCLASS.
