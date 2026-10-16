CLASS ltcl_alloc_reorder_safety DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_reorder_safety.

    METHODS setup.

    METHODS demand_part FOR TESTING.
    METHODS safety_part FOR TESTING.
    METHODS reorder_point FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_reorder_safety IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_reorder_safety( ).
  ENDMETHOD.

  METHOD demand_part.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->demand_part( iv_daily_demand = 10 iv_lead_days = 5 )
      exp = 50 ).
  ENDMETHOD.

  METHOD safety_part.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->safety_part( iv_service_factor = 200 iv_demand_std_dev = 10
                                 iv_lead_days = 4 )
      exp = 40 ).
  ENDMETHOD.

  METHOD reorder_point.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->point( iv_daily_demand = 10 iv_lead_days = 5
                           iv_safety_stock = 40 )
      exp = 90 ).
  ENDMETHOD.

ENDCLASS.
