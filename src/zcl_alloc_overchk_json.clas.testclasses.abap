CLASS ltcl_alloc_overchk_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_overchk_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS one_row    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_overchk_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_overchk_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_overs TYPE zcl_alloc_over_check=>ty_over_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_overs )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD one_row.
    DATA lt_overs TYPE zcl_alloc_over_check=>ty_over_tt.
    DATA ls_over  TYPE zcl_alloc_over_check=>ty_over.

    ls_over-requirement_id = 'REQ-1'.
    ls_over-requested_qty = '5'.
    ls_over-allocated_qty = '8'.
    APPEND ls_over TO lt_overs.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_overs )
      exp = '[{"requirement_id":"REQ-1","requested_qty":5.000,' &&
            '"allocated_qty":8.000}]' ).
  ENDMETHOD.

ENDCLASS.
