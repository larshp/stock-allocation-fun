CLASS ltcl_alloc_dupc_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_dupc_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS one_duplicate FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_dupc_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_dupc_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA lt_dups TYPE zcl_alloc_duplicate_check=>ty_dup_tt.

    DATA(lt_lines) = mo_cut->build( lt_dups ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]
                                        exp = 'ID;COUNT' ).
  ENDMETHOD.

  METHOD one_duplicate.
    DATA lt_dups TYPE zcl_alloc_duplicate_check=>ty_dup_tt.
    DATA ls_dup  TYPE zcl_alloc_duplicate_check=>ty_dup.

    ls_dup-id = 'REQ-1'.
    ls_dup-count = 3.
    APPEND ls_dup TO lt_dups.

    DATA(lt_lines) = mo_cut->build( lt_dups ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = 'REQ-1;3' ).
  ENDMETHOD.

ENDCLASS.
