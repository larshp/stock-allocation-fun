CLASS ltcl_alloc_queue DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_queue.

    METHODS setup.

    METHODS make_input
      IMPORTING
        iv_arrival      TYPE i
        iv_service      TYPE i
        iv_servers      TYPE i
      RETURNING
        VALUE(rs_input) TYPE zcl_alloc_queue=>ty_input.

    METHODS no_load           FOR TESTING.
    METHODS util_is_half      FOR TESTING.
    METHODS queue_and_wait    FOR TESTING.
    METHODS saturated_at_cap  FOR TESTING.
    METHODS two_servers       FOR TESTING.
    METHODS no_service        FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_queue IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_queue( ).
  ENDMETHOD.

  METHOD make_input.
    rs_input-arrival_rate = iv_arrival.
    rs_input-service_rate = iv_service.
    rs_input-servers = iv_servers.
  ENDMETHOD.

  METHOD no_load.
    DATA(ls_input) = make_input( iv_arrival = 0 iv_service = 100 iv_servers = 1 ).
    DATA(ls_result) = mo_cut->estimate( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-saturated exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-utilisation_x100 exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-queue_length_x100 exp = 0 ).
  ENDMETHOD.

  METHOD util_is_half.
    DATA(ls_input) = make_input( iv_arrival = 50 iv_service = 100 iv_servers = 1 ).
    DATA(ls_result) = mo_cut->estimate( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-utilisation_x100 exp = 50 ).
  ENDMETHOD.

  METHOD queue_and_wait.
    DATA(ls_input) = make_input( iv_arrival = 50 iv_service = 100 iv_servers = 1 ).
    DATA(ls_result) = mo_cut->estimate( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-queue_length_x100 exp = 50 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-wait_x100 exp = 100 ).
  ENDMETHOD.

  METHOD saturated_at_cap.
    DATA(ls_input) = make_input( iv_arrival = 100 iv_service = 100 iv_servers = 1 ).
    DATA(ls_result) = mo_cut->estimate( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-saturated exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-utilisation_x100 exp = 100 ).
  ENDMETHOD.

  METHOD two_servers.
    DATA(ls_input) = make_input( iv_arrival = 100 iv_service = 100 iv_servers = 2 ).
    DATA(ls_result) = mo_cut->estimate( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-saturated exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-utilisation_x100 exp = 50 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-wait_x100 exp = 50 ).
  ENDMETHOD.

  METHOD no_service.
    DATA(ls_input) = make_input( iv_arrival = 50 iv_service = 0 iv_servers = 1 ).
    DATA(ls_result) = mo_cut->estimate( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-utilisation_x100 exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-saturated exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
