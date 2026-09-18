CLASS ltcl_alloc_cost_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cost_csv.

    METHODS setup.

    METHODS header_and_summary FOR TESTING.
    METHODS one_source         FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_cost_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cost_csv( ).
  ENDMETHOD.

  METHOD header_and_summary.
    DATA ls_result TYPE zcl_alloc_cost=>ty_result.

    DATA(lt_lines) = mo_cut->build( ls_result ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]
                                        exp = 'WERKS;TAKEN;COST' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = 'SUMMARY;0.000;0.000' ).
  ENDMETHOD.

  METHOD one_source.
    DATA ls_result TYPE zcl_alloc_cost=>ty_result.
    DATA ls_line   TYPE zcl_alloc_cost=>ty_line.

    ls_line-werks = '1000'.
    ls_line-taken = '10'.
    ls_line-cost = '20'.
    APPEND ls_line TO ls_result-lines.
    ls_result-total_cost = '20'.
    ls_result-remaining = '0'.

    DATA(lt_lines) = mo_cut->build( ls_result ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = '1000;10.000;20.000' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ]
                                        exp = 'SUMMARY;20.000;0.000' ).
  ENDMETHOD.

ENDCLASS.
