CLASS ltcl_alloc_cache_policy DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cache_policy.

    METHODS setup.

    METHODS detects_stale    FOR TESTING.
    METHODS fresh_not_stale  FOR TESTING.
    METHODS detects_full     FOR TESTING.
    METHODS describes_policy FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_cache_policy IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cache_policy( iv_max_age = 30 iv_max_items = 5 ).
  ENDMETHOD.

  METHOD detects_stale.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_stale( 30 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_stale( 45 ) exp = abap_true ).
  ENDMETHOD.

  METHOD fresh_not_stale.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_stale( 29 ) exp = abap_false ).
  ENDMETHOD.

  METHOD detects_full.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_full( 5 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_full( 4 ) exp = abap_false ).
  ENDMETHOD.

  METHOD describes_policy.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->describe( )
                                        exp = 'max age 30s, max items 5' ).
  ENDMETHOD.

ENDCLASS.
