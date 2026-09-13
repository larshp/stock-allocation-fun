CLASS ltcl_alloc_overchk_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_overchk_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS one_row     FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_overchk_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_overchk_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA lt_overs TYPE zcl_alloc_over_check=>ty_over_tt.

    DATA(lt_lines) = mo_cut->build( lt_overs ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ]
      exp = 'REQUIREMENT_ID;REQUESTED_QTY;ALLOCATED_QTY' ).
  ENDMETHOD.

  METHOD one_row.
    DATA lt_overs TYPE zcl_alloc_over_check=>ty_over_tt.
    DATA ls_over  TYPE zcl_alloc_over_check=>ty_over.

    ls_over-requirement_id = 'REQ-1'.
    ls_over-requested_qty = '5'.
    ls_over-allocated_qty = '8'.
    APPEND ls_over TO lt_overs.

    DATA(lt_lines) = mo_cut->build( lt_overs ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = 'REQ-1;5.000;8.000' ).
  ENDMETHOD.

ENDCLASS.
