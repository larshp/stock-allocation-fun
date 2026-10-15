CLASS ltcl_alloc_return_sla DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_sla.
    DATA mt_ela TYPE zcl_alloc_return_sla=>ty_hours_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_hours TYPE i.

    METHODS met_rule       FOR TESTING.
    METHODS computes_hours FOR TESTING.
    METHODS hours_guards   FOR TESTING.
    METHODS breaches       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_sla IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_sla( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_hours TO mt_ela.
  ENDMETHOD.

  METHOD met_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_met( iv_elapsed_hours = 10 iv_target_hours = 24 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_met( iv_elapsed_hours = 30 iv_target_hours = 24 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_hours.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->elapsed_hours( iv_start_day = '20260101'
                                   iv_end_day   = '20260102' )
      exp = 24 ).
  ENDMETHOD.

  METHOD hours_guards.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->elapsed_hours( iv_start_day = '20260102'
                                   iv_end_day   = '20260101' )
      exp = 0 ).
  ENDMETHOD.

  METHOD breaches.
    add( 10 ).
    add( 30 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->breach_count( it_elapsed = mt_ela iv_target = 24 )
      exp = 1 ).
  ENDMETHOD.

ENDCLASS.
