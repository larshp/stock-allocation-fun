CLASS ltcl_alloc_cycle_service DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cycle_service.
    DATA mt_per TYPE zcl_alloc_cycle_service=>ty_period_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_target TYPE i
        iv_actual TYPE i.

    METHODS computes_level FOR TESTING.
    METHODS met_rule       FOR TESTING.
    METHODS counts_breaches FOR TESTING.
    METHODS empty_input    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cycle_service IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cycle_service( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_period TYPE zcl_alloc_cycle_service=>ty_period.

    ls_period-target = iv_target.
    ls_period-actual = iv_actual.
    APPEND ls_period TO mt_per.
  ENDMETHOD.

  METHOD computes_level.
    add( iv_target = 95 iv_actual = 98 ).
    add( iv_target = 95 iv_actual = 90 ).
    add( iv_target = 95 iv_actual = 95 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->level( mt_per ) exp = 66 ).
  ENDMETHOD.

  METHOD met_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_met( iv_level = 66 iv_target_level = 60 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_met( iv_level = 50 iv_target_level = 60 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD counts_breaches.
    add( iv_target = 95 iv_actual = 98 ).
    add( iv_target = 95 iv_actual = 90 ).
    add( iv_target = 95 iv_actual = 95 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->breach_count( mt_per ) exp = 1 ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->level( mt_per ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
