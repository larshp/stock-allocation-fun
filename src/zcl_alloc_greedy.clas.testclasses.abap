CLASS ltcl_alloc_greedy DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_greedy.
    DATA mt_dem TYPE zcl_alloc_greedy=>ty_demand_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_id   TYPE string
        iv_qty  TYPE menge_d
        iv_prio TYPE i.

    METHODS empty_input          FOR TESTING.
    METHODS stock_covers_all     FOR TESTING.
    METHODS shortage_is_reported FOR TESTING.
    METHODS priority_order_used  FOR TESTING.
    METHODS zero_stock           FOR TESTING.
    METHODS negative_stock       FOR TESTING.
    METHODS totals_shortage      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_greedy IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_greedy( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_demand TYPE zcl_alloc_greedy=>ty_demand.

    ls_demand-demand_id = iv_id.
    ls_demand-quantity = iv_qty.
    ls_demand-priority = iv_prio.
    APPEND ls_demand TO mt_dem.
  ENDMETHOD.

  METHOD empty_input.
    DATA(lt_result) = mo_cut->solve( it_demands = mt_dem
                                     iv_stock   = 10 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_result ) exp = 0 ).
  ENDMETHOD.

  METHOD stock_covers_all.
    add( iv_id = 'D1' iv_qty = 4 iv_prio = 1 ).
    add( iv_id = 'D2' iv_qty = 6 iv_prio = 2 ).

    DATA(lt_result) = mo_cut->solve( it_demands = mt_dem
                                     iv_stock   = 10 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_result ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 2 ]-allocated exp = 6 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_shortage( lt_result ) exp = 0 ).
  ENDMETHOD.

  METHOD shortage_is_reported.
    add( iv_id = 'D1' iv_qty = 8 iv_prio = 1 ).

    DATA(lt_result) = mo_cut->solve( it_demands = mt_dem
                                     iv_stock   = 5 ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-shortage exp = 3 ).
  ENDMETHOD.

  METHOD priority_order_used.
    add( iv_id = 'LOW' iv_qty = 10 iv_prio = 5 ).
    add( iv_id = 'HIGH' iv_qty = 10 iv_prio = 1 ).

    DATA(lt_result) = mo_cut->solve( it_demands = mt_dem
                                     iv_stock   = 10 ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-demand_id exp = 'HIGH' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 2 ]-demand_id exp = 'LOW' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 2 ]-allocated exp = 0 ).
  ENDMETHOD.

  METHOD zero_stock.
    add( iv_id = 'D1' iv_qty = 4 iv_prio = 1 ).

    DATA(lt_result) = mo_cut->solve( it_demands = mt_dem
                                     iv_stock   = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-shortage exp = 4 ).
  ENDMETHOD.

  METHOD negative_stock.
    add( iv_id = 'D1' iv_qty = 3 iv_prio = 1 ).

    DATA(lt_result) = mo_cut->solve( it_demands = mt_dem
                                     iv_stock   = -5 ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-shortage exp = 3 ).
  ENDMETHOD.

  METHOD totals_shortage.
    add( iv_id = 'D1' iv_qty = 6 iv_prio = 1 ).
    add( iv_id = 'D2' iv_qty = 6 iv_prio = 2 ).

    DATA(lt_result) = mo_cut->solve( it_demands = mt_dem
                                     iv_stock   = 4 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_shortage( lt_result ) exp = 8 ).
  ENDMETHOD.

ENDCLASS.
