CLASS ltcl_alloc_dupc_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_dupc_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS one_duplicate FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_dupc_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_dupc_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_dups TYPE zcl_alloc_duplicate_check=>ty_dup_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_dups )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD one_duplicate.
    DATA lt_dups TYPE zcl_alloc_duplicate_check=>ty_dup_tt.
    DATA ls_dup  TYPE zcl_alloc_duplicate_check=>ty_dup.

    ls_dup-id = 'REQ-1'.
    ls_dup-count = 3.
    APPEND ls_dup TO lt_dups.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_dups )
      exp = '[{"id":"REQ-1","count":3}]' ).
  ENDMETHOD.

ENDCLASS.
