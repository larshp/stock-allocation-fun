CLASS zcl_alloc_crp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_order,
             order_id       TYPE string,
             work_centre    TYPE string,
             quantity       TYPE menge_d,
             hours_per_unit TYPE menge_d,
           END OF ty_order.
    TYPES ty_order_tt TYPE STANDARD TABLE OF ty_order WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_load,
             work_centre TYPE string,
             load_hours  TYPE menge_d,
             orders      TYPE i,
           END OF ty_load.
    TYPES ty_load_tt TYPE STANDARD TABLE OF ty_load WITH DEFAULT KEY.

    METHODS calculate
      IMPORTING
        it_orders      TYPE ty_order_tt
      RETURNING
        VALUE(rt_load) TYPE ty_load_tt.

    METHODS total_hours
      IMPORTING
        it_load         TYPE ty_load_tt
      RETURNING
        VALUE(rv_hours) TYPE menge_d.

ENDCLASS.


CLASS zcl_alloc_crp IMPLEMENTATION.

  METHOD calculate.
    DATA lo_hours  TYPE REF TO zcl_alloc_key_agg_str.
    DATA lo_orders TYPE REF TO zcl_alloc_key_agg_str.
    DATA lt_sums   TYPE zcl_alloc_key_agg_str=>ty_sum_tt.
    DATA ls_row    TYPE ty_load.

    lo_hours = NEW zcl_alloc_key_agg_str( ).
    lo_orders = NEW zcl_alloc_key_agg_str( ).

    " One pass collects the work, then a single sort and merge groups it, so the
    " cost grows with the number of orders instead of scanning the load table once
    " per order. The aggregation keeps the order in which the work centres were
    " first seen, so the result is exactly what the scanning version produced.
    LOOP AT it_orders INTO DATA(ls_order).
      lo_hours->add( iv_key      = ls_order-work_centre
                     iv_quantity = ls_order-quantity * ls_order-hours_per_unit ).
      lo_orders->add( iv_key      = ls_order-work_centre
                      iv_quantity = 1 ).
    ENDLOOP.

    lt_sums = lo_hours->sums( ).

    LOOP AT lt_sums INTO DATA(ls_sum).
      CLEAR ls_row.
      ls_row-work_centre = ls_sum-key.
      ls_row-load_hours = ls_sum-quantity.
      ls_row-orders = lo_orders->find( iv_key = ls_sum-key ) DIV 1.
      APPEND ls_row TO rt_load.
    ENDLOOP.
  ENDMETHOD.

  METHOD total_hours.
    LOOP AT it_load INTO DATA(ls_load).
      rv_hours = rv_hours + ls_load-load_hours.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
