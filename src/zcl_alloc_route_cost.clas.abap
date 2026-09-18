CLASS zcl_alloc_route_cost DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             distance       TYPE i,
             cost_per_km    TYPE menge_d,
             stop_count     TYPE i,
             fixed_per_stop TYPE menge_d,
           END OF ty_input.

    TYPES: BEGIN OF ty_result,
             distance_cost TYPE menge_d,
             stop_cost     TYPE menge_d,
             total_cost    TYPE menge_d,
           END OF ty_result.

    METHODS estimate
      IMPORTING
        is_input         TYPE ty_input
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_route_cost IMPLEMENTATION.

  METHOD estimate.
    DATA lv_dist TYPE i.
    DATA lv_laps TYPE i.

    lv_dist = is_input-distance.
    IF lv_dist < 0.
      lv_dist = 0.
    ENDIF.

    IF is_input-cost_per_km > 0.
      rs_result-distance_cost = lv_dist * is_input-cost_per_km.
    ENDIF.

    lv_laps = is_input-stop_count.
    IF lv_laps > 0 AND is_input-fixed_per_stop > 0.
      rs_result-stop_cost = lv_laps * is_input-fixed_per_stop.
    ENDIF.

    rs_result-total_cost = rs_result-distance_cost + rs_result-stop_cost.
  ENDMETHOD.

ENDCLASS.
