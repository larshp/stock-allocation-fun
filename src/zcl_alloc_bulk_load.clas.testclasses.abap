CLASS ltcl_alloc_bulk_load DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bulk_load.

    METHODS setup.

    METHODS stages_and_commits  FOR TESTING.
    METHODS deduplicates_stage  FOR TESTING.
    METHODS clears_after_commit FOR TESTING.
    METHODS unknown_not_loaded  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_bulk_load IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bulk_load( ).
  ENDMETHOD.

  METHOD stages_and_commits.
    DATA lv_loaded TYPE i.

    mo_cut->stage( 'R1' ).
    mo_cut->stage( 'R2' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->staged_count( ) exp = 2 ).

    lv_loaded = mo_cut->commit( ).

    cl_abap_unit_assert=>assert_equals( act = lv_loaded exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->loaded_count( ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_loaded( 'R1' ) exp = abap_true ).
  ENDMETHOD.

  METHOD deduplicates_stage.
    mo_cut->stage( 'R1' ).
    mo_cut->stage( 'R1' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->staged_count( ) exp = 1 ).
  ENDMETHOD.

  METHOD clears_after_commit.
    DATA lv_loaded TYPE i.

    mo_cut->stage( 'R1' ).

    lv_loaded = mo_cut->commit( ).

    cl_abap_unit_assert=>assert_equals( act = lv_loaded exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->staged_count( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->loaded_count( ) exp = 1 ).
  ENDMETHOD.

  METHOD unknown_not_loaded.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_loaded( 'R9' ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->loaded_count( ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
