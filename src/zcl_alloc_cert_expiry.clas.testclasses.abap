CLASS ltcl_alloc_cert_expiry DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cert_expiry.

    METHODS setup.

    METHODS days_read     FOR TESTING.
    METHODS days_on_edge  FOR TESTING.
    METHODS valid_state   FOR TESTING.
    METHODS expiring_st   FOR TESTING.
    METHODS expired_st    FOR TESTING.
    METHODS no_warn       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cert_expiry IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cert_expiry( ).
  ENDMETHOD.

  METHOD days_read.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->days_left( iv_today = 100 iv_valid_to = 130 )
      exp = 30 ).
  ENDMETHOD.

  METHOD days_on_edge.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->days_left( iv_today = 130 iv_valid_to = 130 )
      exp = 0 ).
  ENDMETHOD.

  METHOD valid_state.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->state( iv_today = 100 iv_valid_to = 200
                           iv_warn_days = 10 )
      exp = 'VALID' ).
  ENDMETHOD.

  METHOD expiring_st.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->state( iv_today = 100 iv_valid_to = 105
                           iv_warn_days = 10 )
      exp = 'EXPIRING' ).
  ENDMETHOD.

  METHOD expired_st.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->state( iv_today = 106 iv_valid_to = 105
                           iv_warn_days = 10 )
      exp = 'EXPIRED' ).
  ENDMETHOD.

  METHOD no_warn.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->state( iv_today = 100 iv_valid_to = 101
                           iv_warn_days = 0 )
      exp = 'VALID' ).
  ENDMETHOD.

ENDCLASS.
