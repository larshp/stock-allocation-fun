CLASS ltcl_alloc_user DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    METHODS defaults_to_system    FOR TESTING.
    METHODS keeps_given_user      FOR TESTING.
    METHODS detects_sap_star      FOR TESTING.
    METHODS empty_becomes_system  FOR TESTING.
    METHODS describes_user        FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_user IMPLEMENTATION.

  METHOD defaults_to_system.
    DATA lo_user TYPE REF TO zcl_alloc_user.

    lo_user = NEW zcl_alloc_user( ).

    cl_abap_unit_assert=>assert_equals( act = lo_user->get_user( ) exp = 'SYSTEM' ).
    cl_abap_unit_assert=>assert_equals( act = lo_user->is_system( ) exp = abap_true ).
  ENDMETHOD.

  METHOD keeps_given_user.
    DATA lo_user TYPE REF TO zcl_alloc_user.

    lo_user = NEW zcl_alloc_user( iv_user = 'LARS' ).

    cl_abap_unit_assert=>assert_equals( act = lo_user->get_user( ) exp = 'LARS' ).
    cl_abap_unit_assert=>assert_equals( act = lo_user->is_system( ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = lo_user->describe( ) exp = 'User LARS' ).
  ENDMETHOD.

  METHOD detects_sap_star.
    DATA lo_user TYPE REF TO zcl_alloc_user.

    lo_user = NEW zcl_alloc_user( iv_user = 'SAP*' ).

    cl_abap_unit_assert=>assert_equals( act = lo_user->is_system( ) exp = abap_true ).
  ENDMETHOD.

  METHOD empty_becomes_system.
    DATA lo_user TYPE REF TO zcl_alloc_user.

    lo_user = NEW zcl_alloc_user( iv_user = '' ).

    cl_abap_unit_assert=>assert_equals( act = lo_user->get_user( ) exp = 'SYSTEM' ).
  ENDMETHOD.

  METHOD describes_user.
    DATA lo_user TYPE REF TO zcl_alloc_user.

    lo_user = NEW zcl_alloc_user( iv_user = 'ANNA' ).

    cl_abap_unit_assert=>assert_equals( act = lo_user->describe( ) exp = 'User ANNA' ).
  ENDMETHOD.

ENDCLASS.
