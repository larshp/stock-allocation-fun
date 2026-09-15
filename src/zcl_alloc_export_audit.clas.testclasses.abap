CLASS ltcl_alloc_export_audit DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_export_audit.

    METHODS setup.

    METHODS numbers_entries FOR TESTING.
    METHODS sums_rows       FOR TESTING.
    METHODS counts_format   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_export_audit IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_export_audit( ).
  ENDMETHOD.

  METHOD numbers_entries.
    DATA ls_entry TYPE zcl_alloc_export_audit=>ty_entry.

    ls_entry = mo_cut->log( iv_format = 'CSV' iv_user = 'LARS' iv_object = 'ZSTOCKALLOC' iv_row_count = 5 ).

    cl_abap_unit_assert=>assert_equals( act = ls_entry-seq exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_entry-format exp = 'CSV' ).
    cl_abap_unit_assert=>assert_equals( act = ls_entry-row_count exp = 5 ).
  ENDMETHOD.

  METHOD sums_rows.
    DATA ls_entry TYPE zcl_alloc_export_audit=>ty_entry.

    ls_entry = mo_cut->log( iv_format = 'CSV' iv_user = 'LARS' iv_object = 'A' iv_row_count = 5 ).
    ls_entry = mo_cut->log( iv_format = 'JSON' iv_user = 'ANNA' iv_object = 'B' iv_row_count = 7 ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->total_rows( ) exp = 12 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 2 ).
  ENDMETHOD.

  METHOD counts_format.
    DATA ls_entry TYPE zcl_alloc_export_audit=>ty_entry.

    ls_entry = mo_cut->log( iv_format = 'CSV' iv_user = 'LARS' iv_object = 'A' iv_row_count = 1 ).
    ls_entry = mo_cut->log( iv_format = 'CSV' iv_user = 'ANNA' iv_object = 'B' iv_row_count = 2 ).
    ls_entry = mo_cut->log( iv_format = 'JSON' iv_user = 'ANNA' iv_object = 'B' iv_row_count = 3 ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->format_count( 'CSV' ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->format_count( 'JSON' ) exp = 1 ).
  ENDMETHOD.

ENDCLASS.
