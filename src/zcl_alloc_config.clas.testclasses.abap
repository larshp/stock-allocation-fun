CLASS ltcl_alloc_config DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_config.

    METHODS setup.

    METHODS reads_value    FOR TESTING.
    METHODS missing_key    FOR TESTING.
    METHODS counts_entries FOR TESTING.
    METHODS lists_keys     FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_config IMPLEMENTATION.

  METHOD setup.
    DATA lt_entries TYPE zcl_alloc_config=>ty_entry_tt.

    APPEND VALUE #( key = 'MAX_PICKS' value = '3' ) TO lt_entries.
    APPEND VALUE #( key = 'PLANT' value = '1000' ) TO lt_entries.

    mo_cut = NEW zcl_alloc_config( lt_entries ).
  ENDMETHOD.

  METHOD reads_value.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get( 'PLANT' ) exp = '1000' ).
  ENDMETHOD.

  METHOD missing_key.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->has( 'NOPE' ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get( 'NOPE' ) exp = '' ).
  ENDMETHOD.

  METHOD counts_entries.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->has( 'MAX_PICKS' ) exp = abap_true ).
  ENDMETHOD.

  METHOD lists_keys.
    DATA lt_keys TYPE zcl_alloc_config=>ty_key_tt.

    lt_keys = mo_cut->keys( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_keys ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_keys[ 1 ] exp = 'MAX_PICKS' ).
  ENDMETHOD.

ENDCLASS.
