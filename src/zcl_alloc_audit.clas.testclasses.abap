CLASS ltcl_alloc_audit DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_audit.

    METHODS setup.

    METHODS numbers_entries        FOR TESTING.
    METHODS counts_all_entries     FOR TESTING.
    METHODS filters_by_run         FOR TESTING.
    METHODS empty_run_returns_none FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_audit IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_audit( ).
  ENDMETHOD.

  METHOD numbers_entries.
    DATA(ls_entry) = mo_cut->add( iv_kind = 'ALLOCATE' iv_run_id = 'R1' iv_detail = 'first' ).

    cl_abap_unit_assert=>assert_equals( act = ls_entry-seq exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_entry-kind exp = 'ALLOCATE' ).
    cl_abap_unit_assert=>assert_equals( act = ls_entry-detail exp = 'first' ).
  ENDMETHOD.

  METHOD counts_all_entries.
    DATA ls_entry TYPE zcl_alloc_audit=>ty_entry.
    DATA lt_all   TYPE zcl_alloc_audit=>ty_entry_tt.

    ls_entry = mo_cut->add( iv_kind = 'ALLOCATE' iv_run_id = 'R1' iv_detail = 'first' ).
    ls_entry = mo_cut->add( iv_kind = 'POST' iv_run_id = 'R1' iv_detail = 'second' ).
    ls_entry = mo_cut->add( iv_kind = 'ALLOCATE' iv_run_id = 'R2' iv_detail = 'third' ).

    lt_all = mo_cut->entries( ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = ls_entry-seq exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_all ) exp = 3 ).
  ENDMETHOD.

  METHOD filters_by_run.
    DATA ls_entry TYPE zcl_alloc_audit=>ty_entry.
    DATA lt_run1  TYPE zcl_alloc_audit=>ty_entry_tt.

    ls_entry = mo_cut->add( iv_kind = 'ALLOCATE' iv_run_id = 'R1' iv_detail = 'first' ).
    ls_entry = mo_cut->add( iv_kind = 'POST' iv_run_id = 'R1' iv_detail = 'second' ).
    ls_entry = mo_cut->add( iv_kind = 'ALLOCATE' iv_run_id = 'R2' iv_detail = 'third' ).

    lt_run1 = mo_cut->of_run( 'R1' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_run1 ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_run1[ 1 ]-kind exp = 'ALLOCATE' ).
    cl_abap_unit_assert=>assert_equals( act = lt_run1[ 2 ]-detail exp = 'second' ).
  ENDMETHOD.

  METHOD empty_run_returns_none.
    DATA lt_entries TYPE zcl_alloc_audit=>ty_entry_tt.
    DATA ls_entry   TYPE zcl_alloc_audit=>ty_entry.

    ls_entry = mo_cut->add( iv_kind = 'ALLOCATE' iv_run_id = 'R1' iv_detail = 'first' ).
    lt_entries = mo_cut->of_run( 'R9' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_entries ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
