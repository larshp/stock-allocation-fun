CLASS ltcl_alloc_archive_meta DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_archive_meta.

    METHODS setup.

    METHODS builds_meta     FOR TESTING.
    METHODS complete_check  FOR TESTING.
    METHODS incomplete_meta FOR TESTING.
    METHODS describes_meta  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_archive_meta IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_archive_meta( ).
  ENDMETHOD.

  METHOD builds_meta.
    DATA ls_meta TYPE zcl_alloc_archive_meta=>ty_meta.

    ls_meta = mo_cut->build( iv_object = 'ZSTOCKALLOC' iv_run_id = 'R1' iv_item_count = 12 ).

    cl_abap_unit_assert=>assert_equals( act = ls_meta-object exp = 'ZSTOCKALLOC' ).
    cl_abap_unit_assert=>assert_equals( act = ls_meta-run_id exp = 'R1' ).
    cl_abap_unit_assert=>assert_equals( act = ls_meta-item_count exp = 12 ).
    cl_abap_unit_assert=>assert_equals( act = ls_meta-archived_on exp = sy-datum ).
  ENDMETHOD.

  METHOD complete_check.
    DATA ls_meta TYPE zcl_alloc_archive_meta=>ty_meta.

    ls_meta = mo_cut->build( iv_object = 'ZSTOCKALLOC' iv_run_id = 'R1' iv_item_count = 1 ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_complete( ls_meta ) exp = abap_true ).
  ENDMETHOD.

  METHOD incomplete_meta.
    DATA ls_meta TYPE zcl_alloc_archive_meta=>ty_meta.

    ls_meta = mo_cut->build( iv_object = '' iv_run_id = 'R1' iv_item_count = 1 ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_complete( ls_meta ) exp = abap_false ).

    ls_meta = mo_cut->build( iv_object = 'ZSTOCKALLOC' iv_run_id = 'R1' iv_item_count = 0 ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_complete( ls_meta ) exp = abap_false ).
  ENDMETHOD.

  METHOD describes_meta.
    DATA ls_meta TYPE zcl_alloc_archive_meta=>ty_meta.

    ls_meta = mo_cut->build( iv_object = 'ZSTOCKALLOC' iv_run_id = 'R1' iv_item_count = 7 ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->describe( ls_meta )
                                        exp = 'ZSTOCKALLOC/R1: 7 items' ).
  ENDMETHOD.

ENDCLASS.
