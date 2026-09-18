CLASS zcl_alloc_histogram DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             matnr    TYPE matnr,
             quantity TYPE menge_d,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_line,
             bucket_from TYPE menge_d,
             bucket_to   TYPE menge_d,
             count       TYPE i,
             quantity    TYPE menge_d,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_items        TYPE ty_item_tt
        iv_bucket_size  TYPE menge_d DEFAULT 10
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_work,
             bucket_from TYPE menge_d,
             quantity    TYPE menge_d,
           END OF ty_work.
    TYPES ty_work_tt TYPE STANDARD TABLE OF ty_work WITH DEFAULT KEY.

ENDCLASS.


CLASS zcl_alloc_histogram IMPLEMENTATION.

  METHOD build.
    DATA lt_work TYPE ty_work_tt.
    DATA ls_work TYPE ty_work.
    DATA ls_line TYPE ty_line.
    DATA lv_size TYPE menge_d.
    DATA lv_idx  TYPE i.

    lv_size = iv_bucket_size.
    IF lv_size <= 0.
      lv_size = 1.
    ENDIF.

    LOOP AT it_items INTO DATA(ls_item).
      CLEAR ls_work.
      lv_idx = ls_item-quantity DIV lv_size.
      ls_work-bucket_from = lv_idx * lv_size.
      ls_work-quantity = ls_item-quantity.
      APPEND ls_work TO lt_work.
    ENDLOOP.

    SORT lt_work BY bucket_from ASCENDING.

    CLEAR ls_line.

    LOOP AT lt_work INTO DATA(ls_w).
      IF sy-tabix = 1 OR ls_w-bucket_from <> ls_line-bucket_from.
        IF sy-tabix > 1.
          APPEND ls_line TO rt_lines.
        ENDIF.
        CLEAR ls_line.
        ls_line-bucket_from = ls_w-bucket_from.
        ls_line-bucket_to = ls_w-bucket_from + lv_size.
      ENDIF.

      ls_line-count = ls_line-count + 1.
      ls_line-quantity = ls_line-quantity + ls_w-quantity.
    ENDLOOP.

    IF lines( lt_work ) > 0.
      APPEND ls_line TO rt_lines.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
