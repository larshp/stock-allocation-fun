CLASS ltcl_alloc_topn_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_topn_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS one_line   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_topn_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_topn_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_top TYPE zcl_alloc_top_n=>ty_line_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_top )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_top TYPE zcl_alloc_top_n=>ty_line_tt.
    DATA ls_top TYPE zcl_alloc_top_n=>ty_line.

    ls_top-rank = 1.
    ls_top-matnr = 'MAT-1'.
    ls_top-quantity = '80'.
    ls_top-share_pct = 80.
    APPEND ls_top TO lt_top.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_top )
      exp = '[{"rank":1,"matnr":"MAT-1","quantity":80.000,' &&
            '"share_pct":80}]' ).
  ENDMETHOD.

ENDCLASS.
