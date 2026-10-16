CLASS zcl_alloc_demand_variance DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_qty_tt TYPE STANDARD TABLE OF menge_d WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_stats,
             count     TYPE i,
             total     TYPE menge_d,
             mean      TYPE menge_d,
             min_qty   TYPE menge_d,
             max_qty   TYPE menge_d,
             range_qty TYPE menge_d,
             variance  TYPE menge_d,
           END OF ty_stats.

    METHODS analyze
      IMPORTING
        it_quantities   TYPE ty_qty_tt
      RETURNING
        VALUE(rs_stats) TYPE ty_stats.

ENDCLASS.


CLASS zcl_alloc_demand_variance IMPLEMENTATION.

  METHOD analyze.
    DATA lv_sum   TYPE menge_d.
    DATA lv_sq    TYPE menge_d.
    DATA lv_diff  TYPE menge_d.
    DATA lv_first TYPE abap_bool.

    lv_first = abap_true.

    LOOP AT it_quantities INTO DATA(lv_qty).
      rs_stats-count = rs_stats-count + 1.
      lv_sum = lv_sum + lv_qty.

      IF lv_first = abap_true.
        rs_stats-min_qty = lv_qty.
        rs_stats-max_qty = lv_qty.
        lv_first = abap_false.
      ELSE.
        IF lv_qty < rs_stats-min_qty.
          rs_stats-min_qty = lv_qty.
        ENDIF.
        IF lv_qty > rs_stats-max_qty.
          rs_stats-max_qty = lv_qty.
        ENDIF.
      ENDIF.
    ENDLOOP.

    rs_stats-total = lv_sum.

    IF rs_stats-count > 0.
      rs_stats-mean = lv_sum / rs_stats-count.
      rs_stats-range_qty = rs_stats-max_qty - rs_stats-min_qty.

      LOOP AT it_quantities INTO DATA(lv_value).
        lv_diff = lv_value - rs_stats-mean.
        lv_sq = lv_sq + lv_diff * lv_diff.
      ENDLOOP.

      rs_stats-variance = lv_sq / rs_stats-count.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
