CLASS ltcl_alloc_session DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_session.

    METHODS setup.

    METHODS initially_closed FOR TESTING.
    METHODS opens_context    FOR TESTING.
    METHODS close_keeps_data FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_session IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_session( ).
  ENDMETHOD.

  METHOD initially_closed.
    DATA(ls_context) = mo_cut->context( ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_open( ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = ls_context-session_id exp = '' ).
    cl_abap_unit_assert=>assert_equals( act = ls_context-user_id exp = '' ).
  ENDMETHOD.

  METHOD opens_context.
    DATA ls_context TYPE zcl_alloc_session=>ty_context.

    ls_context = mo_cut->open( iv_session_id = 'S1' iv_user_id = 'LARS' iv_client = '100' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_open( ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_context-session_id exp = 'S1' ).
    cl_abap_unit_assert=>assert_equals( act = ls_context-user_id exp = 'LARS' ).
    cl_abap_unit_assert=>assert_equals( act = ls_context-client exp = '100' ).
    cl_abap_unit_assert=>assert_equals( act = ls_context-created_at exp = sy-datum ).
  ENDMETHOD.

  METHOD close_keeps_data.
    DATA ls_context TYPE zcl_alloc_session=>ty_context.

    ls_context = mo_cut->open( iv_session_id = 'S2' iv_user_id = 'ANNA' iv_client = '200' ).
    ls_context = mo_cut->close( ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_open( ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = ls_context-session_id exp = 'S2' ).
    cl_abap_unit_assert=>assert_equals( act = ls_context-user_id exp = 'ANNA' ).
  ENDMETHOD.

ENDCLASS.
