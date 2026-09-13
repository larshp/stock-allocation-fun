CLASS ltcl_alloc_topn_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_topn_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS one_line    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_topn_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_topn_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA lt_top TYPE zcl_alloc_top_n=>ty_line_tt.

    DATA(lt_lines) = mo_cut->build( lt_top ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]
                                        exp = 'RANK;MATNR;QUANTITY;SHARE_PCT' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_top TYPE zcl_alloc_top_n=>ty_line_tt.
    DATA ls_top TYPE zcl_alloc_top_n=>ty_line.

    ls_top-rank = 1.
    ls_top-matnr = 'MAT-1'.
    ls_top-quantity = '80'.
    ls_top-share_pct = 80.
    APPEND ls_top TO lt_top.

    DATA(lt_lines) = mo_cut->build( lt_top ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = '1;MAT-1;80.000;80' ).
  ENDMETHOD.

ENDCLASS.
