CLASS ltcl_alloc_access_log DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_access_log.

    METHODS setup.

    METHODS numbers_entries FOR TESTING.
    METHODS counts_all      FOR TESTING.
    METHODS counts_per_user FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_access_log IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_access_log( ).
  ENDMETHOD.

  METHOD numbers_entries.
    DATA ls_entry TYPE zcl_alloc_access_log=>ty_entry.

    ls_entry = mo_cut->log( iv_user = 'LARS' iv_object = 'ZSTOCKALLOC' iv_action = 'READ' ).

    cl_abap_unit_assert=>assert_equals( act = ls_entry-seq exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_entry-user exp = 'LARS' ).
    cl_abap_unit_assert=>assert_equals( act = ls_entry-action exp = 'READ' ).
  ENDMETHOD.

  METHOD counts_all.
    DATA ls_entry TYPE zcl_alloc_access_log=>ty_entry.

    ls_entry = mo_cut->log( iv_user = 'LARS' iv_object = 'ZSTOCKALLOC' iv_action = 'READ' ).
    ls_entry = mo_cut->log( iv_user = 'ANNA' iv_object = 'ZSTOCKRUN' iv_action = 'WRITE' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_entry-seq exp = 2 ).
  ENDMETHOD.

  METHOD counts_per_user.
    DATA ls_entry TYPE zcl_alloc_access_log=>ty_entry.

    ls_entry = mo_cut->log( iv_user = 'LARS' iv_object = 'ZSTOCKALLOC' iv_action = 'READ' ).
    ls_entry = mo_cut->log( iv_user = 'LARS' iv_object = 'ZSTOCKRUN' iv_action = 'READ' ).
    ls_entry = mo_cut->log( iv_user = 'ANNA' iv_object = 'ZSTOCKRUN' iv_action = 'READ' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->count_of_user( 'LARS' ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 3 ).
  ENDMETHOD.

ENDCLASS.
