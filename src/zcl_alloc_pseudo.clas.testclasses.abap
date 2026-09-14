CLASS ltcl_alloc_pseudo DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_pseudo.

    METHODS setup.

    METHODS stable_token       FOR TESTING.
    METHODS salt_changes_token FOR TESTING.
    METHODS resolves_value     FOR TESTING.
    METHODS unknown_id_empty   FOR TESTING.
    METHODS detects_pseudonym  FOR TESTING.
    METHODS counts_mappings    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_pseudo IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_pseudo( ).
  ENDMETHOD.

  METHOD stable_token.
    DATA lv_first  TYPE string.
    DATA lv_second TYPE string.

    lv_first = mo_cut->pseudonymize( iv_value = 'CUSTOMER-1' iv_salt = 'S1' ).
    lv_second = mo_cut->pseudonymize( iv_value = 'CUSTOMER-1' iv_salt = 'S1' ).

    cl_abap_unit_assert=>assert_equals( act = lv_first exp = lv_second ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_pseudonym( lv_first ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 1 ).
  ENDMETHOD.

  METHOD salt_changes_token.
    DATA lv_first  TYPE string.
    DATA lv_second TYPE string.

    lv_first = mo_cut->pseudonymize( iv_value = 'CUSTOMER-1' iv_salt = 'S1' ).
    lv_second = mo_cut->pseudonymize( iv_value = 'CUSTOMER-1' iv_salt = 'S2' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_pseudonym( lv_second ) exp = abap_true ).
  ENDMETHOD.

  METHOD resolves_value.
    DATA lv_id TYPE string.

    lv_id = mo_cut->pseudonymize( iv_value = 'CUST-2' iv_salt = 'S1' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->resolve( lv_id ) exp = 'CUST-2' ).
  ENDMETHOD.

  METHOD unknown_id_empty.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->resolve( 'PSN-4711' ) exp = '' ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 0 ).
  ENDMETHOD.

  METHOD detects_pseudonym.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_pseudonym( 'PSN-1' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_pseudonym( 'CUSTOMER-1' )
                                        exp = abap_false ).
  ENDMETHOD.

  METHOD counts_mappings.
    DATA lv_id TYPE string.

    lv_id = mo_cut->pseudonymize( iv_value = 'A' iv_salt = 'S1' ).
    lv_id = mo_cut->pseudonymize( iv_value = 'B' iv_salt = 'S1' ).
    lv_id = mo_cut->pseudonymize( iv_value = 'A' iv_salt = 'S1' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
