CLASS ltcl_alloc_cycle_detect DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cycle_detect.
    DATA mt_step TYPE zcl_alloc_cycle_detect=>ty_values_tt.
    DATA mt_loop TYPE zcl_alloc_cycle_detect=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_step TYPE i.

    METHODS detects_loop FOR TESTING.
    METHODS loop_rule    FOR TESTING.
    METHODS reads_reason FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cycle_detect IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cycle_detect( ).

    add( iv_step = 1 ).
    add( iv_step = 2 ).
    add( iv_step = 3 ).

    APPEND 1 TO mt_loop.
    APPEND 2 TO mt_loop.
    APPEND 1 TO mt_loop.
  ENDMETHOD.

  METHOD add.
    APPEND iv_step TO mt_step.
  ENDMETHOD.

  METHOD detects_loop.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->loop_detected( it_steps = mt_step iv_step = 2 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->loop_detected( it_steps = mt_step iv_step = 5 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD loop_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_loop( mt_step ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_loop( mt_loop ) exp = abap_true ).
  ENDMETHOD.

  METHOD reads_reason.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( abap_true ) exp = 'cycle revisited' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( abap_false ) exp = 'clear' ).
  ENDMETHOD.

ENDCLASS.
