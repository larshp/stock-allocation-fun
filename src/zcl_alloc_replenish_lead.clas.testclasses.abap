CLASS ltcl_alloc_replenish_lead DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_replenish_lead.
    DATA mt_day TYPE zcl_alloc_replenish_lead=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_day TYPE i.

    METHODS computes_actual FOR TESTING.
    METHODS averages_days   FOR TESTING.
    METHODS late_rule       FOR TESTING.
    METHODS empty_input     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_replenish_lead IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_replenish_lead( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_day TO mt_day.
  ENDMETHOD.

  METHOD computes_actual.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->actual( iv_ordered_day  = '20260101'
                            iv_received_day = '20260111' )
      exp = 10 ).
  ENDMETHOD.

  METHOD averages_days.
    add( 10 ).
    add( 20 ).
    add( 30 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->average( mt_day ) exp = 20 ).
  ENDMETHOD.

  METHOD late_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_late( iv_actual = 12 iv_planned = 10 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_late( iv_actual = 8 iv_planned = 10 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->average( mt_day ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
