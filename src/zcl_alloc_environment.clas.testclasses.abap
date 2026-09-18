CLASS ltcl_alloc_environment DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_environment.

    METHODS setup.

    METHODS productive_client FOR TESTING.
    METHODS non_productive    FOR TESTING.
    METHODS builds_info       FOR TESTING.
    METHODS describes_info    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_environment IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_environment( ).
  ENDMETHOD.

  METHOD productive_client.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_production( '100' ) exp = abap_true ).
  ENDMETHOD.

  METHOD non_productive.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_production( '000' ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_production( '066' ) exp = abap_false ).
  ENDMETHOD.

  METHOD builds_info.
    DATA ls_info TYPE zcl_alloc_environment=>ty_info.

    ls_info = mo_cut->build( iv_system_id = 'SID' iv_client = '100' iv_release = '750' ).

    cl_abap_unit_assert=>assert_equals( act = ls_info-system_id exp = 'SID' ).
    cl_abap_unit_assert=>assert_equals( act = ls_info-client exp = '100' ).
    cl_abap_unit_assert=>assert_equals( act = ls_info-release exp = '750' ).
    cl_abap_unit_assert=>assert_equals( act = ls_info-is_production exp = abap_true ).
  ENDMETHOD.

  METHOD describes_info.
    DATA ls_info TYPE zcl_alloc_environment=>ty_info.

    ls_info = mo_cut->build( iv_system_id = 'SID' iv_client = '000' iv_release = '750' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->describe( ls_info )
                                        exp = 'SID/000 750 (non-productive)' ).
  ENDMETHOD.

ENDCLASS.
