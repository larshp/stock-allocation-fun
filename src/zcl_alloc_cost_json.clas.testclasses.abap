CLASS ltcl_alloc_cost_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cost_json.

    METHODS setup.

    METHODS empty_result FOR TESTING.
    METHODS one_source   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_cost_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cost_json( ).
  ENDMETHOD.

  METHOD empty_result.
    DATA ls_result TYPE zcl_alloc_cost=>ty_result.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( ls_result )
      exp = '{"lines":[],"total_cost":0.000,"remaining":0.000}' ).
  ENDMETHOD.

  METHOD one_source.
    DATA ls_result TYPE zcl_alloc_cost=>ty_result.
    DATA ls_line   TYPE zcl_alloc_cost=>ty_line.

    ls_line-werks = '1000'.
    ls_line-taken = '10'.
    ls_line-cost = '20'.
    APPEND ls_line TO ls_result-lines.
    ls_result-total_cost = '20'.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( ls_result )
      exp = '{"lines":[{"werks":"1000","taken":10.000,"cost":20.000}],' &&
            '"total_cost":20.000,"remaining":0.000}' ).
  ENDMETHOD.

ENDCLASS.
