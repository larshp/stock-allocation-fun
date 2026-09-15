CLASS ltcl_alloc_ref_cache DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_ref_cache.

    METHODS setup.

    METHODS stores_value FOR TESTING.
    METHODS overwrites   FOR TESTING.
    METHODS missing_key  FOR TESTING.
    METHODS clears_cache FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_ref_cache IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_ref_cache( ).
  ENDMETHOD.

  METHOD stores_value.
    mo_cut->put( iv_key = 'PLANT' iv_value = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->get( 'PLANT' ) exp = '1000' ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->has( 'PLANT' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 1 ).
  ENDMETHOD.

  METHOD overwrites.
    mo_cut->put( iv_key = 'PLANT' iv_value = '1000' ).
    mo_cut->put( iv_key = 'PLANT' iv_value = '2000' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->get( 'PLANT' ) exp = '2000' ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 1 ).
  ENDMETHOD.

  METHOD missing_key.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->has( 'NOPE' ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get( 'NOPE' ) exp = '' ).
  ENDMETHOD.

  METHOD clears_cache.
    mo_cut->put( iv_key = 'A' iv_value = '1' ).

    mo_cut->reset( ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->has( 'A' ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
