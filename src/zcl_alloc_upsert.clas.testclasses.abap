CLASS ltcl_alloc_upsert DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_upsert.

    METHODS setup.

    METHODS inserts_new      FOR TESTING.
    METHODS updates_existing FOR TESTING.
    METHODS counts_entries   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_upsert IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_upsert( ).
  ENDMETHOD.

  METHOD inserts_new.
    DATA lt_entries TYPE zcl_alloc_upsert=>ty_entry_tt.
    DATA ls_result  TYPE zcl_alloc_upsert=>ty_result.

    APPEND VALUE #( key = 'A' value = '1' ) TO lt_entries.

    ls_result = mo_cut->upsert( lt_entries ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-inserted exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-updated exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 1 ).
  ENDMETHOD.

  METHOD updates_existing.
    DATA lt_entries TYPE zcl_alloc_upsert=>ty_entry_tt.
    DATA ls_result  TYPE zcl_alloc_upsert=>ty_result.
    DATA ls_entry   TYPE zcl_alloc_upsert=>ty_entry.
    DATA lt_all     TYPE zcl_alloc_upsert=>ty_entry_tt.

    APPEND VALUE #( key = 'A' value = '1' ) TO lt_entries.

    ls_result = mo_cut->upsert( lt_entries ).

    CLEAR lt_entries.
    APPEND VALUE #( key = 'A' value = '2' ) TO lt_entries.

    ls_result = mo_cut->upsert( lt_entries ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-inserted exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-updated exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 1 ).

    lt_all = mo_cut->entries( ).

    READ TABLE lt_all INTO ls_entry WITH KEY key = 'A'.

    cl_abap_unit_assert=>assert_equals( act = ls_entry-value exp = '2' ).
  ENDMETHOD.

  METHOD counts_entries.
    DATA lt_entries TYPE zcl_alloc_upsert=>ty_entry_tt.
    DATA ls_result  TYPE zcl_alloc_upsert=>ty_result.

    APPEND VALUE #( key = 'A' value = '1' ) TO lt_entries.
    APPEND VALUE #( key = 'B' value = '2' ) TO lt_entries.

    ls_result = mo_cut->upsert( lt_entries ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-inserted exp = 2 ).
  ENDMETHOD.

ENDCLASS.
