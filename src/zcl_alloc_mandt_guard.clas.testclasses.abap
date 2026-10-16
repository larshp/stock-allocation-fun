CLASS ltcl_alloc_mandt_guard DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_mandt_guard.

    METHODS setup.

    METHODS default_allows_zero FOR TESTING.
    METHODS blocks_other_client FOR TESTING.
    METHODS allows_matching     FOR TESTING.
    METHODS describes_client    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_mandt_guard IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_mandt_guard( iv_client = '000' iv_allowed = '000' ).
  ENDMETHOD.

  METHOD default_allows_zero.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_current_allowed( ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->check( '000' ) exp = abap_true ).
  ENDMETHOD.

  METHOD blocks_other_client.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->check( '100' ) exp = abap_false ).
  ENDMETHOD.

  METHOD allows_matching.
    DATA lo_guard TYPE REF TO zcl_alloc_mandt_guard.

    lo_guard = NEW zcl_alloc_mandt_guard( iv_client = '100' iv_allowed = '100' ).

    cl_abap_unit_assert=>assert_equals( act = lo_guard->is_current_allowed( ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lo_guard->check( '100' ) exp = abap_true ).
  ENDMETHOD.

  METHOD describes_client.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->describe( )
                                        exp = 'Client 000, allowed 000' ).
  ENDMETHOD.

ENDCLASS.
