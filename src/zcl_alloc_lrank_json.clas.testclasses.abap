CLASS ltcl_alloc_lrank_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_lrank_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS one_line   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_lrank_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_lrank_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_ranks TYPE zcl_alloc_location_rank=>ty_line_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_ranks )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_ranks TYPE zcl_alloc_location_rank=>ty_line_tt.
    DATA ls_rank  TYPE zcl_alloc_location_rank=>ty_line.

    ls_rank-rank = 1.
    ls_rank-lgort = '0001'.
    ls_rank-quantity = '80'.
    APPEND ls_rank TO lt_ranks.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_ranks )
      exp = '[{"rank":1,"lgort":"0001","quantity":80.000}]' ).
  ENDMETHOD.

ENDCLASS.
