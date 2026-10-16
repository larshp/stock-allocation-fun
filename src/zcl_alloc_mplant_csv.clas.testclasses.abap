CLASS ltcl_alloc_mplant_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_mplant_csv.

    METHODS setup.

    METHODS header_and_totals FOR TESTING.
    METHODS one_plant         FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_mplant_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_mplant_csv( ).
  ENDMETHOD.

  METHOD header_and_totals.
    DATA ls_result TYPE zcl_alloc_multi_plant=>ty_result.

    DATA(lt_lines) = mo_cut->build( ls_result ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]
                                        exp = 'WERKS;QUANTITY' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ]
                                        exp = 'PLANTS;0' ).
  ENDMETHOD.

  METHOD one_plant.
    DATA ls_result TYPE zcl_alloc_multi_plant=>ty_result.
    DATA ls_line   TYPE zcl_alloc_multi_plant=>ty_line.

    ls_line-werks = '1000'.
    ls_line-quantity = '10'.
    APPEND ls_line TO ls_result-lines.
    ls_result-total = '10'.
    ls_result-plants = 1.

    DATA(lt_lines) = mo_cut->build( ls_result ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = '1000;10.000' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ]
                                        exp = 'TOTAL;10.000' ).
  ENDMETHOD.

ENDCLASS.
