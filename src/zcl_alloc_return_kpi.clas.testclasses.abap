CLASS ltcl_alloc_return_kpi DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_kpi.

    METHODS setup.

    METHODS builds_card     FOR TESTING.
    METHODS flags_over      FOR TESTING.
    METHODS rate_percent    FOR TESTING.
    METHODS value_guard     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_kpi IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_kpi( ).
  ENDMETHOD.

  METHOD builds_card.
    DATA ls_kpi TYPE zcl_alloc_return_kpi=>ty_kpi.

    ls_kpi = mo_cut->build( iv_returned = 25 iv_shipped = 1000
                            iv_target_percent = 3 iv_unit_value = 10 ).

    cl_abap_unit_assert=>assert_equals( act = ls_kpi-rate_percent exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_kpi-on_target exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_kpi-value exp = 250 ).
  ENDMETHOD.

  METHOD flags_over.
    DATA ls_kpi TYPE zcl_alloc_return_kpi=>ty_kpi.

    ls_kpi = mo_cut->build( iv_returned = 40 iv_shipped = 1000
                            iv_target_percent = 3 iv_unit_value = 10 ).

    cl_abap_unit_assert=>assert_equals( act = ls_kpi-rate_percent exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = ls_kpi-on_target exp = abap_false ).
  ENDMETHOD.

  METHOD rate_percent.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rate_percent( iv_returned = 25 iv_shipped = 1000 )
      exp = 2 ).
  ENDMETHOD.

  METHOD value_guard.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( iv_returned = 0 iv_unit_value = 10 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
