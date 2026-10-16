CLASS ltcl_alloc_archive_idx DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_archive_idx.

    METHODS setup.

    METHODS adds_and_reads  FOR TESTING.
    METHODS deduplicates    FOR TESTING.
    METHODS unknown_missing FOR TESTING.
    METHODS counts_entries  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_archive_idx IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_archive_idx( ).
  ENDMETHOD.

  METHOD adds_and_reads.
    mo_cut->add( 'R1' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->contains( 'R1' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 1 ).
  ENDMETHOD.

  METHOD deduplicates.
    DATA lt_index TYPE zcl_alloc_archive_idx=>ty_index_tt.

    mo_cut->add( 'R1' ).
    mo_cut->add( 'R1' ).
    lt_index = mo_cut->entries( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_index ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_index[ 1 ]-run_id exp = 'R1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_index[ 1 ]-archived_on exp = sy-datum ).
  ENDMETHOD.

  METHOD unknown_missing.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->contains( 'R9' ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 0 ).
  ENDMETHOD.

  METHOD counts_entries.
    mo_cut->add( 'R1' ).
    mo_cut->add( 'R2' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
