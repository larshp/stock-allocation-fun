CLASS ltcl_alloc_tcost_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_tcost_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS one_line    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_tcost_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_tcost_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA lt_lines TYPE zcl_alloc_transport_cost=>ty_line_tt.

    DATA(lt_result) = mo_cut->build( lt_lines ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_result ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]
                                        exp = 'WERKS;COST_TOTAL;RANK' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_lines TYPE zcl_alloc_transport_cost=>ty_line_tt.
    DATA ls_cost  TYPE zcl_alloc_transport_cost=>ty_line.

    ls_cost-werks = '1000'.
    ls_cost-cost_total = '10'.
    ls_cost-rank = 1.
    APPEND ls_cost TO lt_lines.

    DATA(lt_result) = mo_cut->build( lt_lines ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 2 ]
                                        exp = '1000;10.000;1' ).
  ENDMETHOD.

ENDCLASS.
