CLASS ltcl_alloc_concurrency DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_concurrency.

    METHODS setup.

    METHODS grants_up_to_limit    FOR TESTING.
    METHODS rejects_beyond_limit  FOR TESTING.
    METHODS same_key_idempotent   FOR TESTING.
    METHODS release_frees_slot    FOR TESTING.
    METHODS unlimited_when_zero   FOR TESTING.
    METHODS saturated_flag        FOR TESTING.
    METHODS release_unknown_noop  FOR TESTING.
    METHODS empty_key_granted     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_concurrency IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_concurrency( iv_limit = 2 ).
  ENDMETHOD.

  METHOD grants_up_to_limit.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->acquire( 'A' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->acquire( 'B' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->active_count( ) exp = 2 ).
  ENDMETHOD.

  METHOD rejects_beyond_limit.
    mo_cut->acquire( 'A' ).
    mo_cut->acquire( 'B' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->acquire( 'C' ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->active_count( ) exp = 2 ).
  ENDMETHOD.

  METHOD same_key_idempotent.
    mo_cut->acquire( 'A' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->acquire( 'A' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->active_count( ) exp = 1 ).
  ENDMETHOD.

  METHOD release_frees_slot.
    mo_cut->acquire( 'A' ).
    mo_cut->acquire( 'B' ).

    mo_cut->release( 'A' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->active_count( ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->acquire( 'C' ) exp = abap_true ).
  ENDMETHOD.

  METHOD unlimited_when_zero.
    DATA lo_unlimited TYPE REF TO zcl_alloc_concurrency.

    lo_unlimited = NEW zcl_alloc_concurrency( iv_limit = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lo_unlimited->acquire( 'A' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lo_unlimited->acquire( 'B' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lo_unlimited->acquire( 'C' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lo_unlimited->is_saturated( ) exp = abap_false ).
  ENDMETHOD.

  METHOD saturated_flag.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_saturated( ) exp = abap_false ).

    mo_cut->acquire( 'A' ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_saturated( ) exp = abap_false ).

    mo_cut->acquire( 'B' ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_saturated( ) exp = abap_true ).
  ENDMETHOD.

  METHOD release_unknown_noop.
    mo_cut->acquire( 'A' ).
    mo_cut->release( 'ZZZ' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->active_count( ) exp = 1 ).
  ENDMETHOD.

  METHOD empty_key_granted.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->acquire( '' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->active_count( ) exp = 1 ).
  ENDMETHOD.

ENDCLASS.
