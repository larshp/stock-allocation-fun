CLASS ltcl_alloc_breaker DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_breaker.

    METHODS setup.

    METHODS starts_closed            FOR TESTING.
    METHODS opens_after_threshold    FOR TESTING.
    METHODS success_resets_failures  FOR TESTING.
    METHODS probe_then_close         FOR TESTING.
    METHODS probe_then_fail          FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_breaker IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_breaker( iv_threshold = 2 ).
  ENDMETHOD.

  METHOD starts_closed.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_state( )
                                        exp = zcl_alloc_breaker=>state-closed ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_allowed( ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->failure_count( ) exp = 0 ).
  ENDMETHOD.

  METHOD opens_after_threshold.
    DATA lv_state TYPE zcl_alloc_breaker=>ty_state.

    lv_state = mo_cut->record_failure( ).
    lv_state = mo_cut->record_failure( ).

    cl_abap_unit_assert=>assert_equals( act = lv_state
                                        exp = zcl_alloc_breaker=>state-open ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_allowed( ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->failure_count( ) exp = 2 ).
  ENDMETHOD.

  METHOD success_resets_failures.
    DATA lv_state TYPE zcl_alloc_breaker=>ty_state.

    lv_state = mo_cut->record_failure( ).
    lv_state = mo_cut->record_success( ).

    cl_abap_unit_assert=>assert_equals( act = lv_state
                                        exp = zcl_alloc_breaker=>state-closed ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->failure_count( ) exp = 0 ).
  ENDMETHOD.

  METHOD probe_then_close.
    DATA lv_state TYPE zcl_alloc_breaker=>ty_state.

    lv_state = mo_cut->record_failure( ).
    lv_state = mo_cut->record_failure( ).
    lv_state = mo_cut->probe_half_open( ).

    cl_abap_unit_assert=>assert_equals( act = lv_state
                                        exp = zcl_alloc_breaker=>state-half_open ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_allowed( ) exp = abap_true ).

    lv_state = mo_cut->record_success( ).

    cl_abap_unit_assert=>assert_equals( act = lv_state
                                        exp = zcl_alloc_breaker=>state-closed ).
  ENDMETHOD.

  METHOD probe_then_fail.
    DATA lv_state TYPE zcl_alloc_breaker=>ty_state.

    lv_state = mo_cut->record_failure( ).
    lv_state = mo_cut->record_failure( ).
    lv_state = mo_cut->probe_half_open( ).
    lv_state = mo_cut->record_failure( ).

    cl_abap_unit_assert=>assert_equals( act = lv_state
                                        exp = zcl_alloc_breaker=>state-open ).
  ENDMETHOD.

ENDCLASS.
