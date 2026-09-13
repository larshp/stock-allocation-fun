CLASS zcl_alloc_matrix DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             matnr    TYPE matnr,
             run_id   TYPE c LENGTH 20,
             quantity TYPE menge_d,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_line,
             matnr    TYPE matnr,
             run_id   TYPE c LENGTH 20,
             quantity TYPE menge_d,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

ENDCLASS.


CLASS zcl_alloc_matrix IMPLEMENTATION.

  METHOD build.
    DATA lt_work    TYPE ty_item_tt.
    DATA ls_line    TYPE ty_line.
    DATA lv_started TYPE abap_bool.

    lt_work = it_items.
    SORT lt_work BY matnr ASCENDING
                    run_id ASCENDING.

    LOOP AT lt_work INTO DATA(ls_item).
      IF lv_started = abap_false
          OR ls_item-matnr <> ls_line-matnr
          OR ls_item-run_id <> ls_line-run_id.
        IF lv_started = abap_true.
          APPEND ls_line TO rt_lines.
        ENDIF.
        CLEAR ls_line.
        ls_line-matnr = ls_item-matnr.
        ls_line-run_id = ls_item-run_id.
        lv_started = abap_true.
      ENDIF.

      ls_line-quantity = ls_line-quantity + ls_item-quantity.
    ENDLOOP.

    IF lv_started = abap_true.
      APPEND ls_line TO rt_lines.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
