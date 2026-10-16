CLASS ltcl_alloc_stock_health DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_stock_health.

    METHODS setup.

    METHODS computes_health FOR TESTING.
    METHODS grades          FOR TESTING.
    METHODS healthy_rule    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_stock_health IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_stock_health( ).
  ENDMETHOD.

  METHOD computes_health.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->health( iv_turns = 10 iv_service_percent = 100
                            iv_excess_percent = 0 )
      exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->health( iv_turns = 2 iv_service_percent = 80
                            iv_excess_percent = 50 )
      exp = 44 ).
  ENDMETHOD.

  METHOD grades.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->grade( 90 ) exp = 'A' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->grade( 44 ) exp = 'D' ).
  ENDMETHOD.

  METHOD healthy_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_healthy( iv_health = 80 iv_threshold = 75 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_healthy( iv_health = 60 iv_threshold = 75 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
