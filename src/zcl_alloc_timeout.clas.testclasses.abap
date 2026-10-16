CLASS ltcl_alloc_timeout DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_timeout.

    METHODS setup.

    METHODS not_expired_before_limit   FOR TESTING.
    METHODS expired_at_the_limit       FOR TESTING.
    METHODS over_limit_message         FOR TESTING.
    METHODS unlimited_never_expires    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_timeout IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_timeout( ).
  ENDMETHOD.

  METHOD not_expired_before_limit.
    DATA(ls_status) = mo_cut->check( iv_limit_seconds = 60 iv_elapsed = 10 ).

    cl_abap_unit_assert=>assert_equals( act = ls_status-expired exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = ls_status-remaining_seconds exp = 50 ).
    cl_abap_unit_assert=>assert_equals( act = ls_status-message exp = '50 seconds remaining' ).
  ENDMETHOD.

  METHOD expired_at_the_limit.
    DATA lv_expired TYPE abap_bool.

    lv_expired = mo_cut->is_expired( iv_limit_seconds = 30 iv_elapsed = 30 ).

    cl_abap_unit_assert=>assert_equals( act = lv_expired exp = abap_true ).
  ENDMETHOD.

  METHOD over_limit_message.
    DATA(ls_status) = mo_cut->check( iv_limit_seconds = 20 iv_elapsed = 25 ).

    cl_abap_unit_assert=>assert_equals( act = ls_status-expired exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_status-remaining_seconds exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_status-message exp = 'Timeout exceeded' ).
  ENDMETHOD.

  METHOD unlimited_never_expires.
    DATA(ls_status) = mo_cut->check( iv_limit_seconds = 0 iv_elapsed = 9999 ).

    cl_abap_unit_assert=>assert_equals( act = ls_status-expired exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = ls_status-remaining_seconds exp = 0 ).
  ENDMETHOD.

ENDCLASS.
