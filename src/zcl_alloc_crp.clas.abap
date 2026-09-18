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
    DATA lt_load TYPE ty_load_tt.
    DATA ls_row  TYPE ty_load.
    DATA ls_new  TYPE ty_load.

    LOOP AT it_orders INTO DATA(ls_order).
      READ TABLE lt_load INTO ls_row
        WITH KEY work_centre = ls_order-work_centre.

      IF sy-subrc = 0.
        ls_new-work_centre = ls_order-work_centre.
        ls_new-load_hours = ls_row-load_hours
          + ls_order-quantity * ls_order-hours_per_unit.
        ls_new-orders = ls_row-orders + 1.

        DELETE lt_load WHERE work_centre = ls_order-work_centre.
        APPEND ls_new TO lt_load.
        CONTINUE.
      ENDIF.

      CLEAR ls_new.
      ls_new-work_centre = ls_order-work_centre.
      ls_new-load_hours = ls_order-quantity * ls_order-hours_per_unit.
      ls_new-orders = 1.
      APPEND ls_new TO lt_load.
    ENDLOOP.

    rt_load = lt_load.
  ENDMETHOD.

  METHOD total_hours.
    LOOP AT it_load INTO DATA(ls_load).
      rv_hours = rv_hours + ls_load-load_hours.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
