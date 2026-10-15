CLASS zcl_alloc_return_settle DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material TYPE matnr,
             refund   TYPE i,
             fee      TYPE i,
             shipping TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_entry,
             material TYPE matnr,
             net      TYPE i,
           END OF ty_entry.
    TYPES ty_entry_tt TYPE STANDARD TABLE OF ty_entry WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_lines          TYPE ty_line_tt
      RETURNING
        VALUE(rt_entries) TYPE ty_entry_tt.

    METHODS net_settlement
      IMPORTING
        it_entries    TYPE ty_entry_tt
      RETURNING
        VALUE(rv_net) TYPE i.

    METHODS line_count
      IMPORTING
        it_entries      TYPE ty_entry_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_return_settle IMPLEMENTATION.

  METHOD build.
    DATA ls_entry TYPE ty_entry.
    DATA lv_net   TYPE i.

    " The settlement lists every positive refund line; a line whose fees eat the
    " whole refund settles at zero but still appears.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-refund <= 0.
        CONTINUE.
      ENDIF.

      lv_net = ls_line-refund - ls_line-fee - ls_line-shipping.
      IF lv_net < 0.
        lv_net = 0.
      ENDIF.

      CLEAR ls_entry.
      ls_entry-material = ls_line-material.
      ls_entry-net = lv_net.
      APPEND ls_entry TO rt_entries.
    ENDLOOP.
  ENDMETHOD.

  METHOD net_settlement.
    LOOP AT it_entries INTO DATA(ls_entry).
      rv_net = rv_net + ls_entry-net.
    ENDLOOP.
  ENDMETHOD.

  METHOD line_count.
    rv_count = lines( it_entries ).
  ENDMETHOD.

ENDCLASS.
