CLASS ltcl_alloc_transport_cost DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_transport_cost.

    METHODS setup.

    METHODS item
      IMPORTING
        iv_werks      TYPE werks_d
        iv_quantity   TYPE menge_d
        iv_cost       TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_transport_cost=>ty_item.

    METHODS empty_list   FOR TESTING.
    METHODS cheapest_first FOR TESTING.
    METHODS assigns_ranks FOR TESTING.
    METHODS total_cost    FOR TESTING.
    METHODS equal_costs   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_transport_cost IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_transport_cost( ).
  ENDMETHOD.

  METHOD item.
    rs_row-werks = iv_werks.
    rs_row-quantity = iv_quantity.
    rs_row-cost_per_unit = iv_cost.
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_items TYPE zcl_alloc_transport_cost=>ty_item_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->rank( lt_items ) ).
  ENDMETHOD.

  METHOD cheapest_first.
    DATA lt_items TYPE zcl_alloc_transport_cost=>ty_item_tt.

    APPEND item( iv_werks = '2000' iv_quantity = '10' iv_cost = '5' )
      TO lt_items.
    APPEND item( iv_werks = '1000' iv_quantity = '10' iv_cost = '1' )
      TO lt_items.

    DATA(lt_lines) = mo_cut->rank( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-werks exp = '1000' ).
  ENDMETHOD.

  METHOD assigns_ranks.
    DATA lt_items TYPE zcl_alloc_transport_cost=>ty_item_tt.

    APPEND item( iv_werks = '2000' iv_quantity = '10' iv_cost = '5' )
      TO lt_items.
    APPEND item( iv_werks = '1000' iv_quantity = '10' iv_cost = '1' )
      TO lt_items.

    DATA(lt_lines) = mo_cut->rank( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-rank exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-rank exp = 2 ).
  ENDMETHOD.

  METHOD total_cost.
    DATA lt_items TYPE zcl_alloc_transport_cost=>ty_item_tt.

    APPEND item( iv_werks = '1000' iv_quantity = '4' iv_cost = '2.5' )
      TO lt_items.

    DATA(lt_lines) = mo_cut->rank( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-cost_total
                                        exp = '10' ).
  ENDMETHOD.

  METHOD equal_costs.
    DATA lt_items TYPE zcl_alloc_transport_cost=>ty_item_tt.

    APPEND item( iv_werks = '2000' iv_quantity = '10' iv_cost = '5' )
      TO lt_items.
    APPEND item( iv_werks = '1000' iv_quantity = '10' iv_cost = '5' )
      TO lt_items.

    DATA(lt_lines) = mo_cut->rank( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-werks exp = '1000' ).
  ENDMETHOD.

ENDCLASS.
