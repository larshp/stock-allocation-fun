CLASS zcl_alloc_transport_cost DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             werks         TYPE werks_d,
             quantity      TYPE menge_d,
             cost_per_unit TYPE menge_d,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_line,
             werks      TYPE werks_d,
             cost_total TYPE menge_d,
             rank       TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS rank
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

ENDCLASS.


CLASS zcl_alloc_transport_cost IMPLEMENTATION.

  METHOD rank.
    DATA ls_line TYPE ty_line.

    LOOP AT it_items INTO DATA(ls_item).
      CLEAR ls_line.
      ls_line-werks = ls_item-werks.
      ls_line-cost_total = ls_item-quantity * ls_item-cost_per_unit.
      APPEND ls_line TO rt_lines.
    ENDLOOP.

    SORT rt_lines BY cost_total ASCENDING
                     werks ASCENDING.

    LOOP AT rt_lines ASSIGNING FIELD-SYMBOL(<ls_line>).
      <ls_line>-rank = sy-tabix.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
