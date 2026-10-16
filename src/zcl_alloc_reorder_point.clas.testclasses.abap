CLASS ltcl_alloc_reorder_point DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_reorder_point.

    METHODS setup.

    METHODS input
      IMPORTING
        iv_demand     TYPE menge_d
        iv_lead       TYPE i
        iv_safety     TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_reorder_point=>ty_input.

    METHODS demand_times_lead FOR TESTING.
    METHODS adds_safety_stock FOR TESTING.
    METHODS zero_lead_time    FOR TESTING.
    METHODS zero_demand       FOR TESTING.
    METHODS all_zero          FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_reorder_point IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_reorder_point( ).
  ENDMETHOD.

  METHOD input.
    rs_row-daily_demand = iv_demand.
    rs_row-lead_time_days = iv_lead.
    rs_row-safety_stock = iv_safety.
  ENDMETHOD.

  METHOD demand_times_lead.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( input( iv_demand = '10'
                                      iv_lead   = 5
                                      iv_safety = '20' ) )
      exp = '70' ).
  ENDMETHOD.

  METHOD adds_safety_stock.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( input( iv_demand = '1'
                                      iv_lead   = 3
                                      iv_safety = '7' ) )
      exp = '10' ).
  ENDMETHOD.

  METHOD zero_lead_time.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( input( iv_demand = '10'
                                      iv_lead   = 0
                                      iv_safety = '20' ) )
      exp = '20' ).
  ENDMETHOD.

  METHOD zero_demand.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( input( iv_demand = '0'
                                      iv_lead   = 5
                                      iv_safety = '20' ) )
      exp = '20' ).
  ENDMETHOD.

  METHOD all_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( input( iv_demand = '0'
                                      iv_lead   = 0
                                      iv_safety = '0' ) )
      exp = '0' ).
  ENDMETHOD.

ENDCLASS.
