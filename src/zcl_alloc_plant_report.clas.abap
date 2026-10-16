CLASS zcl_alloc_plant_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             werks         TYPE werks_d,
             requested_qty TYPE menge_d,
             allocated_qty TYPE menge_d,
             shortage_qty  TYPE menge_d,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_line,
             werks         TYPE werks_d,
             lines         TYPE i,
             requested_qty TYPE menge_d,
             allocated_qty TYPE menge_d,
             shortage_qty  TYPE menge_d,
             coverage_pct  TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS summarize
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

ENDCLASS.


CLASS zcl_alloc_plant_report IMPLEMENTATION.

  METHOD summarize.
    DATA lt_work    TYPE ty_item_tt.
    DATA ls_line    TYPE ty_line.
    DATA lv_started TYPE abap_bool.

    lt_work = it_items.
    SORT lt_work BY werks ASCENDING.

    LOOP AT lt_work INTO DATA(ls_item).
      IF lv_started = abap_false OR ls_item-werks <> ls_line-werks.
        IF lv_started = abap_true.
          APPEND ls_line TO rt_lines.
        ENDIF.
        CLEAR ls_line.
        ls_line-werks = ls_item-werks.
        lv_started = abap_true.
      ENDIF.

      ls_line-lines = ls_line-lines + 1.
      ls_line-requested_qty = ls_line-requested_qty + ls_item-requested_qty.
      ls_line-allocated_qty = ls_line-allocated_qty + ls_item-allocated_qty.
      ls_line-shortage_qty = ls_line-shortage_qty + ls_item-shortage_qty.
    ENDLOOP.

    IF lv_started = abap_true.
      APPEND ls_line TO rt_lines.
    ENDIF.

    LOOP AT rt_lines ASSIGNING FIELD-SYMBOL(<ls_line>).
      IF <ls_line>-requested_qty > 0.
        <ls_line>-coverage_pct = <ls_line>-allocated_qty * 100
          DIV <ls_line>-requested_qty.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
