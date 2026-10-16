CLASS ltcl_alloc_mplant_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_mplant_json.

    METHODS setup.

    METHODS empty_result FOR TESTING.
    METHODS one_plant    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_mplant_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_mplant_json( ).
  ENDMETHOD.

  METHOD empty_result.
    DATA ls_result TYPE zcl_alloc_multi_plant=>ty_result.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( ls_result )
      exp = '{"plants":[],"total":0.000,"plant_count":0}' ).
  ENDMETHOD.

  METHOD one_plant.
    DATA ls_result TYPE zcl_alloc_multi_plant=>ty_result.
    DATA ls_line   TYPE zcl_alloc_multi_plant=>ty_line.

    ls_line-werks = '1000'.
    ls_line-quantity = '10'.
    APPEND ls_line TO ls_result-lines.
    ls_result-total = '10'.
    ls_result-plants = 1.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( ls_result )
      exp = '{"plants":[{"werks":"1000","quantity":10.000}],' &&
            '"total":10.000,"plant_count":1}' ).
  ENDMETHOD.

ENDCLASS.
