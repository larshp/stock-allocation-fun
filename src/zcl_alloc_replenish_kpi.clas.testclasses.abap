CLASS ltcl_alloc_replenish_kpi DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_replenish_kpi.

    METHODS setup.

    METHODS computes_fill    FOR TESTING.
    METHODS computes_on_time FOR TESTING.
    METHODS builds_card      FOR TESTING.
    METHODS guards_zero      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_replenish_kpi IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_replenish_kpi( ).
  ENDMETHOD.

  METHOD computes_fill.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->fill_rate( iv_delivered = 80 iv_requested = 100 )
      exp = 80 ).
  ENDMETHOD.

  METHOD computes_on_time.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->on_time_percent( iv_on_time = 9 iv_total = 10 )
      exp = 90 ).
  ENDMETHOD.

  METHOD builds_card.
    DATA ls_kpi TYPE zcl_alloc_replenish_kpi=>ty_kpi.

    ls_kpi = mo_cut->build( iv_fill_rate = 80 iv_on_time_percent = 90 ).

    cl_abap_unit_assert=>assert_equals( act = ls_kpi-fill_rate exp = 80 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_kpi-on_time_percent exp = 90 ).
  ENDMETHOD.

  METHOD guards_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->fill_rate( iv_delivered = 10 iv_requested = 0 )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->on_time_percent( iv_on_time = 1 iv_total = 0 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
