CLASS ltcl_alloc_lrank_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_lrank_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS one_line    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_lrank_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_lrank_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA lt_ranks TYPE zcl_alloc_location_rank=>ty_line_tt.

    DATA(lt_lines) = mo_cut->build( lt_ranks ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]
                                        exp = 'RANK;LGORT;QUANTITY' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_ranks TYPE zcl_alloc_location_rank=>ty_line_tt.
    DATA ls_rank  TYPE zcl_alloc_location_rank=>ty_line.

    ls_rank-rank = 1.
    ls_rank-lgort = '0001'.
    ls_rank-quantity = '80'.
    APPEND ls_rank TO lt_ranks.

    DATA(lt_lines) = mo_cut->build( lt_ranks ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = '1;0001;80.000' ).
  ENDMETHOD.

ENDCLASS.
