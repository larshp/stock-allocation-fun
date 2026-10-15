CLASS ltcl_alloc_rout_queue DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_rout_queue.
    DATA mt_wait TYPE zcl_alloc_rout_queue=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_wait TYPE i.

    METHODS computes_queue FOR TESTING.
    METHODS waiting_rule   FOR TESTING.
    METHODS counts_waits   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_rout_queue IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_rout_queue( ).

    add( iv_wait = 0 ).
    add( iv_wait = 10 ).
    add( iv_wait = 0 ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_wait TO mt_wait.
  ENDMETHOD.

  METHOD computes_queue.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->queue_time( iv_wait = 60 iv_count = 3 )
      exp = 20 ).
  ENDMETHOD.

  METHOD waiting_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_waiting( 10 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_waiting( 0 ) exp = abap_false ).
  ENDMETHOD.

  METHOD counts_waits.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->wait_count( mt_wait ) exp = 1 ).
  ENDMETHOD.

ENDCLASS.
