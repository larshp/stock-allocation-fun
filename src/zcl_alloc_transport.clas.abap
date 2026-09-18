CLASS zcl_alloc_transport DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_supply,
             node_id TYPE string,
             supply  TYPE menge_d,
           END OF ty_supply.
    TYPES ty_supply_tt TYPE STANDARD TABLE OF ty_supply WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_demand,
             node_id TYPE string,
             demand  TYPE menge_d,
           END OF ty_demand.
    TYPES ty_demand_tt TYPE STANDARD TABLE OF ty_demand WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_lane,
             from_node TYPE string,
             to_node   TYPE string,
             unit_cost TYPE menge_d,
           END OF ty_lane.
    TYPES ty_lane_tt TYPE STANDARD TABLE OF ty_lane WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_shipment,
             from_node TYPE string,
             to_node   TYPE string,
             quantity  TYPE menge_d,
             cost      TYPE menge_d,
           END OF ty_shipment.
    TYPES ty_shipment_tt TYPE STANDARD TABLE OF ty_shipment WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_rem,
             node_id TYPE string,
             qty     TYPE menge_d,
           END OF ty_rem.
    TYPES ty_rem_tt TYPE STANDARD TABLE OF ty_rem WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             shipments  TYPE ty_shipment_tt,
             total_cost TYPE menge_d,
             unshipped  TYPE menge_d,
           END OF ty_result.

    METHODS solve
      IMPORTING
        it_supply        TYPE ty_supply_tt
        it_demand        TYPE ty_demand_tt
        it_lanes         TYPE ty_lane_tt
      RETURNING
        VALUE(rs_result) TYPE ty_result.

  PRIVATE SECTION.
    METHODS bump
      IMPORTING
        it_rem        TYPE ty_rem_tt
        iv_node       TYPE string
        iv_qty        TYPE menge_d
      RETURNING
        VALUE(rt_rem) TYPE ty_rem_tt.

    METHODS used_of
      IMPORTING
        it_rem         TYPE ty_rem_tt
        iv_node        TYPE string
      RETURNING
        VALUE(rv_used) TYPE menge_d.

ENDCLASS.


CLASS zcl_alloc_transport IMPLEMENTATION.

  METHOD bump.
    DATA ls_rem TYPE ty_rem.

    rt_rem = it_rem.

    READ TABLE rt_rem INTO ls_rem WITH KEY node_id = iv_node.
    IF sy-subrc = 0.
      ls_rem-qty = ls_rem-qty + iv_qty.
      DELETE rt_rem WHERE node_id = iv_node.
      APPEND ls_rem TO rt_rem.
      RETURN.
    ENDIF.

    ls_rem-node_id = iv_node.
    ls_rem-qty = iv_qty.
    APPEND ls_rem TO rt_rem.
  ENDMETHOD.

  METHOD used_of.
    READ TABLE it_rem INTO DATA(ls_rem) WITH KEY node_id = iv_node.
    IF sy-subrc = 0.
      rv_used = ls_rem-qty.
    ENDIF.
  ENDMETHOD.

  METHOD solve.
    DATA lt_lanes       TYPE ty_lane_tt.
    DATA lt_supply_used TYPE ty_rem_tt.
    DATA lt_demand_used TYPE ty_rem_tt.
    DATA ls_shipment    TYPE ty_shipment.
    DATA lv_free_from   TYPE menge_d.
    DATA lv_free_to     TYPE menge_d.
    DATA lv_take        TYPE menge_d.
    DATA lv_used        TYPE menge_d.
    DATA lv_total_dem   TYPE menge_d.
    DATA lv_total_ship  TYPE menge_d.

    IF lines( it_lanes ) = 0 OR lines( it_demand ) = 0.
      LOOP AT it_demand INTO DATA(ls_total_d).
        lv_total_dem = lv_total_dem + ls_total_d-demand.
      ENDLOOP.

      rs_result-unshipped = lv_total_dem.
      RETURN.
    ENDIF.

    lt_lanes = it_lanes.
    SORT lt_lanes BY unit_cost ASCENDING.

    LOOP AT lt_lanes INTO DATA(ls_lane).
      READ TABLE it_supply INTO DATA(ls_supply)
        WITH KEY node_id = ls_lane-from_node.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      READ TABLE it_demand INTO DATA(ls_demand)
        WITH KEY node_id = ls_lane-to_node.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      lv_used = used_of( it_rem  = lt_supply_used
                         iv_node = ls_lane-from_node ).
      lv_free_from = ls_supply-supply - lv_used.

      lv_used = used_of( it_rem  = lt_demand_used
                         iv_node = ls_lane-to_node ).
      lv_free_to = ls_demand-demand - lv_used.

      IF lv_free_from <= 0 OR lv_free_to <= 0.
        CONTINUE.
      ENDIF.

      IF lv_free_from < lv_free_to.
        lv_take = lv_free_from.
      ELSE.
        lv_take = lv_free_to.
      ENDIF.

      CLEAR ls_shipment.
      ls_shipment-from_node = ls_lane-from_node.
      ls_shipment-to_node = ls_lane-to_node.
      ls_shipment-quantity = lv_take.
      ls_shipment-cost = lv_take * ls_lane-unit_cost.
      APPEND ls_shipment TO rs_result-shipments.

      rs_result-total_cost = rs_result-total_cost + ls_shipment-cost.
      lv_total_ship = lv_total_ship + lv_take.

      lt_supply_used = bump( it_rem  = lt_supply_used
                             iv_node = ls_lane-from_node
                             iv_qty  = lv_take ).
      lt_demand_used = bump( it_rem  = lt_demand_used
                             iv_node = ls_lane-to_node
                             iv_qty  = lv_take ).
    ENDLOOP.

    LOOP AT it_demand INTO DATA(ls_total).
      lv_total_dem = lv_total_dem + ls_total-demand.
    ENDLOOP.

    rs_result-unshipped = lv_total_dem - lv_total_ship.
  ENDMETHOD.

ENDCLASS.
