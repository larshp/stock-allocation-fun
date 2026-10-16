CLASS zcl_alloc_shipment DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             lgort    TYPE lgort_d,
             quantity TYPE menge_d,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_line,
             shipment  TYPE i,
             lgort     TYPE lgort_d,
             positions TYPE i,
             quantity  TYPE menge_d,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

ENDCLASS.


CLASS zcl_alloc_shipment IMPLEMENTATION.

  METHOD build.
    DATA lt_work    TYPE ty_item_tt.
    DATA ls_line    TYPE ty_line.
    DATA lv_started TYPE abap_bool.

    lt_work = it_items.
    SORT lt_work BY lgort ASCENDING.

    LOOP AT lt_work INTO DATA(ls_item).
      IF lv_started = abap_false OR ls_item-lgort <> ls_line-lgort.
        IF lv_started = abap_true.
          APPEND ls_line TO rt_lines.
        ENDIF.
        CLEAR ls_line.
        ls_line-shipment = lines( rt_lines ) + 1.
        ls_line-lgort = ls_item-lgort.
        lv_started = abap_true.
      ENDIF.

      ls_line-positions = ls_line-positions + 1.
      ls_line-quantity = ls_line-quantity + ls_item-quantity.
    ENDLOOP.

    IF lv_started = abap_true.
      APPEND ls_line TO rt_lines.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
