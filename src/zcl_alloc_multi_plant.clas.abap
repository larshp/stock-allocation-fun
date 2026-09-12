CLASS zcl_alloc_multi_plant DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             werks    TYPE werks_d,
             quantity TYPE menge_d,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_line,
             werks    TYPE werks_d,
             quantity TYPE menge_d,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             total  TYPE menge_d,
             plants TYPE i,
             lines  TYPE ty_line_tt,
           END OF ty_result.

    METHODS summarize
      IMPORTING
        it_items         TYPE ty_item_tt
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_multi_plant IMPLEMENTATION.

  METHOD summarize.
    DATA lt_work    TYPE ty_item_tt.
    DATA ls_line    TYPE ty_line.
    DATA lv_started TYPE abap_bool.

    lt_work = it_items.
    SORT lt_work BY werks ASCENDING.

    LOOP AT lt_work INTO DATA(ls_item).
      IF lv_started = abap_false OR ls_item-werks <> ls_line-werks.
        IF lv_started = abap_true.
          APPEND ls_line TO rs_result-lines.
        ENDIF.
        CLEAR ls_line.
        ls_line-werks = ls_item-werks.
        lv_started = abap_true.
      ENDIF.

      ls_line-quantity = ls_line-quantity + ls_item-quantity.
    ENDLOOP.

    IF lv_started = abap_true.
      APPEND ls_line TO rs_result-lines.
    ENDIF.

    LOOP AT rs_result-lines INTO DATA(ls_sum).
      rs_result-total = rs_result-total + ls_sum-quantity.
      rs_result-plants = rs_result-plants + 1.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
