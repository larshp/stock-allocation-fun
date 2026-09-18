CLASS ltcl_alloc_backpressure DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_backpressure.

    METHODS setup.

    METHODS make_input
      IMPORTING
        iv_depth        TYPE i
        iv_capacity     TYPE i
        iv_drain        TYPE i
      RETURNING
        VALUE(rs_input) TYPE zcl_alloc_backpressure=>ty_input.

    METHODS empty_queue_accepted FOR TESTING.
    METHODS low_load_accepted    FOR TESTING.
    METHODS high_load_throttled  FOR TESTING.
    METHODS full_throttled       FOR TESTING.
    METHODS over_throttled       FOR TESTING.
    METHODS over_no_drain_reject FOR TESTING.
    METHODS zero_capacity_reject FOR TESTING.
    METHODS load_pct_capped      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_backpressure IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_backpressure( ).
  ENDMETHOD.

  METHOD make_input.
    rs_input-queue_depth = iv_depth.
    rs_input-capacity = iv_capacity.
    rs_input-drain_per_tick = iv_drain.
  ENDMETHOD.

  METHOD empty_queue_accepted.
    DATA(ls_input) = make_input( iv_depth = 0 iv_capacity = 100 iv_drain = 10 ).
    DATA(ls_decision) = mo_cut->assess( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_decision-action exp = 'accept' ).
    cl_abap_unit_assert=>assert_equals( act = ls_decision-load_pct exp = 0 ).
  ENDMETHOD.

  METHOD low_load_accepted.
    DATA(ls_input) = make_input( iv_depth = 50 iv_capacity = 100 iv_drain = 10 ).
    DATA(ls_decision) = mo_cut->assess( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_decision-action exp = 'accept' ).
    cl_abap_unit_assert=>assert_equals( act = ls_decision-load_pct exp = 50 ).
    cl_abap_unit_assert=>assert_equals( act = ls_decision-wait_ticks exp = 0 ).
  ENDMETHOD.

  METHOD high_load_throttled.
    DATA(ls_input) = make_input( iv_depth = 90 iv_capacity = 100 iv_drain = 10 ).
    DATA(ls_decision) = mo_cut->assess( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_decision-action exp = 'throttle' ).
    cl_abap_unit_assert=>assert_equals( act = ls_decision-wait_ticks exp = 1 ).
  ENDMETHOD.

  METHOD full_throttled.
    DATA(ls_input) = make_input( iv_depth = 100 iv_capacity = 100 iv_drain = 10 ).
    DATA(ls_decision) = mo_cut->assess( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_decision-action exp = 'throttle' ).
    cl_abap_unit_assert=>assert_equals( act = ls_decision-load_pct exp = 100 ).
  ENDMETHOD.

  METHOD over_throttled.
    DATA(ls_input) = make_input( iv_depth = 130 iv_capacity = 100 iv_drain = 10 ).
    DATA(ls_decision) = mo_cut->assess( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_decision-action exp = 'throttle' ).
    cl_abap_unit_assert=>assert_equals( act = ls_decision-wait_ticks exp = 3 ).
  ENDMETHOD.

  METHOD over_no_drain_reject.
    DATA(ls_input) = make_input( iv_depth = 130 iv_capacity = 100 iv_drain = 0 ).
    DATA(ls_decision) = mo_cut->assess( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_decision-action exp = 'reject' ).
    cl_abap_unit_assert=>assert_equals( act = ls_decision-load_pct exp = 100 ).
  ENDMETHOD.

  METHOD zero_capacity_reject.
    DATA(ls_input) = make_input( iv_depth = 5 iv_capacity = 0 iv_drain = 1 ).
    DATA(ls_decision) = mo_cut->assess( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_decision-action exp = 'reject' ).
    cl_abap_unit_assert=>assert_equals( act = ls_decision-load_pct exp = 100 ).
  ENDMETHOD.

  METHOD load_pct_capped.
    DATA(ls_input) = make_input( iv_depth = 400 iv_capacity = 100 iv_drain = 100 ).
    DATA(ls_decision) = mo_cut->assess( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_decision-load_pct exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = ls_decision-wait_ticks exp = 3 ).
  ENDMETHOD.

ENDCLASS.
