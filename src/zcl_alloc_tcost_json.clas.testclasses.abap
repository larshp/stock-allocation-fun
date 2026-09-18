CLASS ltcl_alloc_tcost_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_tcost_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS one_line   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_tcost_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_tcost_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_lines TYPE zcl_alloc_transport_cost=>ty_line_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_lines )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_lines TYPE zcl_alloc_transport_cost=>ty_line_tt.
    DATA ls_cost  TYPE zcl_alloc_transport_cost=>ty_line.

    ls_cost-werks = '1000'.
    ls_cost-cost_total = '10'.
    ls_cost-rank = 1.
    APPEND ls_cost TO lt_lines.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_lines )
      exp = '[{"werks":"1000","cost_total":10.000,"rank":1}]' ).
  ENDMETHOD.

ENDCLASS.
