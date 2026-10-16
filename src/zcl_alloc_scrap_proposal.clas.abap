CLASS zcl_alloc_scrap_proposal DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material TYPE matnr,
             quantity TYPE menge_d,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_line,
             material TYPE matnr,
             quantity TYPE menge_d,
             reason   TYPE string,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS propose
      IMPORTING
        it_items        TYPE ty_item_tt
        iv_reason       TYPE string
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS total_quantity
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_total) TYPE menge_d.

    METHODS reason
      IMPORTING
        is_item          TYPE ty_item
      RETURNING
        VALUE(rv_reason) TYPE string.

  PRIVATE SECTION.
    METHODS is_scrapped
      IMPORTING
        is_item      TYPE ty_item
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_scrap_proposal IMPLEMENTATION.

  METHOD is_scrapped.
    rv_ok = xsdbool( is_item-quantity > 0 ).
  ENDMETHOD.

  METHOD propose.
    DATA ls_line TYPE ty_line.

    " Only a positive quantity is worth proposing; a zero or negative line is
    " ignored rather than turned into an empty scrap line.
    LOOP AT it_items INTO DATA(ls_item).
      IF is_scrapped( ls_item ) = abap_false.
        CONTINUE.
      ENDIF.

      CLEAR ls_line.
      ls_line-material = ls_item-material.
      ls_line-quantity = ls_item-quantity.
      ls_line-reason = iv_reason.
      APPEND ls_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

  METHOD total_quantity.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD reason.
    IF is_scrapped( is_item ) = abap_true.
      rv_reason = 'SCRAP'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
