CLASS ltcl_alloc_config_w DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_config_w.

    METHODS setup.

    METHODS stores_value   FOR TESTING.
    METHODS overwrites     FOR TESTING.
    METHODS removes_entry  FOR TESTING.
    METHODS missing_key    FOR TESTING.
    METHODS counts_entries FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_config_w IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_config_w( ).
  ENDMETHOD.

  METHOD stores_value.
    mo_cut->put( iv_key = 'PLANT' iv_value = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->get( 'PLANT' ) exp = '1000' ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 1 ).
  ENDMETHOD.

  METHOD overwrites.
    mo_cut->put( iv_key = 'PLANT' iv_value = '1000' ).
    mo_cut->put( iv_key = 'PLANT' iv_value = '2000' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get( 'PLANT' ) exp = '2000' ).
  ENDMETHOD.

  METHOD removes_entry.
    DATA lt_entries TYPE zcl_alloc_config_w=>ty_entry_tt.

    mo_cut->put( iv_key = 'PLANT' iv_value = '1000' ).
    mo_cut->put( iv_key = 'LGORT' iv_value = '0001' ).

    mo_cut->remove( 'PLANT' ).
    lt_entries = mo_cut->entries( ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_entries[ 1 ]-key exp = 'LGORT' ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get( 'PLANT' ) exp = '' ).
  ENDMETHOD.

  METHOD missing_key.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get( 'NOPE' ) exp = '' ).
  ENDMETHOD.

  METHOD counts_entries.
    mo_cut->put( iv_key = 'A' iv_value = '1' ).
    mo_cut->put( iv_key = 'B' iv_value = '2' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
