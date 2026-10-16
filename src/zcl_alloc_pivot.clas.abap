CLASS zcl_alloc_pivot DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             matnr    TYPE matnr,
             werks    TYPE werks_d,
             quantity TYPE menge_d,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_line,
             matnr     TYPE matnr,
             werks     TYPE werks_d,
             quantity  TYPE menge_d,
             share_pct TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_total,
             matnr TYPE matnr,
             total TYPE menge_d,
           END OF ty_total.
    TYPES ty_total_tt TYPE STANDARD TABLE OF ty_total WITH DEFAULT KEY.

    METHODS totals_of
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rt_total) TYPE ty_total_tt.

ENDCLASS.


CLASS zcl_alloc_pivot IMPLEMENTATION.

  METHOD totals_of.
    DATA ls_total   TYPE ty_total.
    DATA lv_started TYPE abap_bool.

    " it_items is sorted by material, so equal materials are consecutive
    LOOP AT it_items INTO DATA(ls_item).
      IF lv_started = abap_false OR ls_item-matnr <> ls_total-matnr.
        IF lv_started = abap_true.
          APPEND ls_total TO rt_total.
        ENDIF.
        CLEAR ls_total.
        ls_total-matnr = ls_item-matnr.
        lv_started = abap_true.
      ENDIF.

      ls_total-total = ls_total-total + ls_item-quantity.
    ENDLOOP.

    IF lv_started = abap_true.
      APPEND ls_total TO rt_total.
    ENDIF.
  ENDMETHOD.

  METHOD build.
    DATA lt_work   TYPE ty_item_tt.
    DATA lt_totals TYPE ty_total_tt.
    DATA ls_line   TYPE ty_line.
    DATA ls_total  TYPE ty_total.
    DATA lv_started TYPE abap_bool.

    lt_work = it_items.
    SORT lt_work BY matnr ASCENDING
                    werks ASCENDING.

    lt_totals = totals_of( lt_work ).

    LOOP AT lt_work INTO DATA(ls_item).
      IF lv_started = abap_false
          OR ls_item-matnr <> ls_line-matnr
          OR ls_item-werks <> ls_line-werks.
        IF lv_started = abap_true.
          APPEND ls_line TO rt_lines.
        ENDIF.
        CLEAR ls_line.
        ls_line-matnr = ls_item-matnr.
        ls_line-werks = ls_item-werks.
        lv_started = abap_true.
      ENDIF.

      ls_line-quantity = ls_line-quantity + ls_item-quantity.
    ENDLOOP.

    IF lv_started = abap_true.
      APPEND ls_line TO rt_lines.
    ENDIF.

    LOOP AT rt_lines ASSIGNING FIELD-SYMBOL(<ls_line>).
      READ TABLE lt_totals INTO ls_total
        WITH KEY matnr = <ls_line>-matnr.
      IF sy-subrc = 0 AND ls_total-total > 0.
        <ls_line>-share_pct = <ls_line>-quantity * 100 DIV ls_total-total.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
