CLASS ltcl_alloc_subst_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_subst_csv.

    METHODS setup.

    METHODS empty_result FOR TESTING.
    METHODS one_hop      FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_subst_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_subst_csv( ).
  ENDMETHOD.

  METHOD empty_result.
    DATA ls_result TYPE zcl_alloc_subst_chain=>ty_result.

    DATA(lt_lines) = mo_cut->build( ls_result ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]
                                        exp = 'STEP;MATNR' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ]
                                        exp = 'STEPS;0' ).
  ENDMETHOD.

  METHOD one_hop.
    DATA ls_result TYPE zcl_alloc_subst_chain=>ty_result.

    APPEND 'MAT-A' TO ls_result-path.
    APPEND 'MAT-B' TO ls_result-path.
    ls_result-final_matnr = 'MAT-B'.
    ls_result-steps = 1.

    DATA(lt_lines) = mo_cut->build( ls_result ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = '1;MAT-A' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ]
                                        exp = '2;MAT-B' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 4 ]
                                        exp = 'FINAL;MAT-B' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 5 ]
                                        exp = 'STEPS;1' ).
  ENDMETHOD.

ENDCLASS.
