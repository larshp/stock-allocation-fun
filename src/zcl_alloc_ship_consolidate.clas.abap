CLASS zcl_alloc_ship_consolidate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             destination TYPE string,
             material    TYPE matnr,
             quantity    TYPE menge_d,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_shipment,
             destination TYPE string,
             line_count  TYPE i,
             total_qty   TYPE menge_d,
           END OF ty_shipment.
    TYPES ty_shipment_tt TYPE STANDARD TABLE OF ty_shipment WITH DEFAULT KEY.

    METHODS consolidate
      IMPORTING
        it_lines            TYPE ty_line_tt
      RETURNING
        VALUE(rt_shipments) TYPE ty_shipment_tt.

ENDCLASS.


CLASS zcl_alloc_ship_consolidate IMPLEMENTATION.

  METHOD consolidate.
    TYPES: BEGIN OF ty_work,
             destination TYPE string,
             line_count  TYPE i,
             total_qty   TYPE menge_d,
           END OF ty_work.
    TYPES ty_work_tt TYPE HASHED TABLE OF ty_work WITH UNIQUE KEY destination.

    DATA lt_work TYPE ty_work_tt.
    DATA ls_ship TYPE ty_shipment.

    " The lines of one destination become one shipment. A hashed working table
    " keeps the totals one lookup per line and, because it is walked only at the
    " end, the shipments come out in first-seen destination order.
    LOOP AT it_lines INTO DATA(ls_line).
      READ TABLE lt_work ASSIGNING FIELD-SYMBOL(<ls_work>)
        WITH KEY destination = ls_line-destination.

      IF sy-subrc = 0.
        <ls_work>-line_count = <ls_work>-line_count + 1.
        <ls_work>-total_qty = <ls_work>-total_qty + ls_line-quantity.
      ELSE.
        INSERT VALUE #( destination = ls_line-destination
                        line_count  = 1
                        total_qty   = ls_line-quantity ) INTO TABLE lt_work.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_work INTO DATA(ls_work).
      CLEAR ls_ship.
      ls_ship-destination = ls_work-destination.
      ls_ship-line_count = ls_work-line_count.
      ls_ship-total_qty = ls_work-total_qty.
      APPEND ls_ship TO rt_shipments.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
