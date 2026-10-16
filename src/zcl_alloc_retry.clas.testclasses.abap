CLASS ltcl_alloc_retry DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_retry.

    METHODS setup.

    METHODS retries_when_attempts_left   FOR TESTING.
    METHODS gives_up_at_max              FOR TESTING.
    METHODS no_attempts_no_retry         FOR TESTING.
    METHODS backoff_is_exponential       FOR TESTING.
    METHODS backoff_caps_at_300          FOR TESTING.
    METHODS zero_base_no_delay           FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_retry IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_retry( ).
  ENDMETHOD.

  METHOD retries_when_attempts_left.
    DATA(ls_plan) = mo_cut->plan( iv_attempt = 2 iv_max_attempts = 3 iv_base_delay = 5 ).

    cl_abap_unit_assert=>assert_equals( act = ls_plan-attempt exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_plan-retry exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_plan-delay_seconds exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = ls_plan-message exp = 'Retry 2 in 10s' ).
  ENDMETHOD.

  METHOD gives_up_at_max.
    DATA(ls_plan) = mo_cut->plan( iv_attempt = 3 iv_max_attempts = 3 iv_base_delay = 5 ).

    cl_abap_unit_assert=>assert_equals( act = ls_plan-retry exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = ls_plan-delay_seconds exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_plan-message
                                        exp = 'Giving up after 3 attempts' ).
  ENDMETHOD.

  METHOD no_attempts_no_retry.
    DATA(ls_plan) = mo_cut->plan( iv_attempt = 1 iv_max_attempts = 0 iv_base_delay = 5 ).

    cl_abap_unit_assert=>assert_equals( act = ls_plan-retry exp = abap_false ).
  ENDMETHOD.

  METHOD backoff_is_exponential.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->backoff( iv_attempt = 1 iv_base_delay = 4 )
                                        exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->backoff( iv_attempt = 3 iv_base_delay = 4 )
                                        exp = 16 ).
  ENDMETHOD.

  METHOD backoff_caps_at_300.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->backoff( iv_attempt = 10 iv_base_delay = 10 )
                                        exp = 300 ).
  ENDMETHOD.

  METHOD zero_base_no_delay.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->backoff( iv_attempt = 4 iv_base_delay = 0 )
                                        exp = 0 ).
  ENDMETHOD.

ENDCLASS.
