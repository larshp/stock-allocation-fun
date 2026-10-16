CLASS ltcl_alloc_once DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_once.

    METHODS setup.

    METHODS first_run_true    FOR TESTING.
    METHODS second_run_false  FOR TESTING.
    METHODS different_keys    FOR TESTING.
    METHODS has_run_tracks    FOR TESTING.
    METHODS count_entries     FOR TESTING.
    METHODS reset_clears      FOR TESTING.
    METHODS empty_key_recorded FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_once IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_once( ).
  ENDMETHOD.

  METHOD first_run_true.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->run( 'K1' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 1 ).
  ENDMETHOD.

  METHOD second_run_false.
    mo_cut->run( 'K1' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->run( 'K1' ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 1 ).
  ENDMETHOD.

  METHOD different_keys.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->run( 'K1' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->run( 'K2' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 2 ).
  ENDMETHOD.

  METHOD has_run_tracks.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->has_run( 'K1' ) exp = abap_false ).

    mo_cut->run( 'K1' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->has_run( 'K1' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->has_run( 'K2' ) exp = abap_false ).
  ENDMETHOD.

  METHOD count_entries.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 0 ).

    mo_cut->run( 'A' ).
    mo_cut->run( 'B' ).
    mo_cut->run( 'C' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 3 ).
  ENDMETHOD.

  METHOD reset_clears.
    mo_cut->run( 'A' ).
    mo_cut->reset( ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->run( 'A' ) exp = abap_true ).
  ENDMETHOD.

  METHOD empty_key_recorded.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->run( '' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->run( '' ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
