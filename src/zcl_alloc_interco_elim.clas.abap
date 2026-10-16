CLASS zcl_alloc_interco_elim DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material        TYPE matnr,
             margin          TYPE i,
             sold_externally TYPE abap_bool,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS eliminate
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS residual
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS is_cleared
      IMPORTING
        it_lines     TYPE ty_line_tt
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_interco_elim IMPLEMENTATION.

  METHOD eliminate.
    " The margin on goods still inside the group is eliminated.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-sold_externally = abap_true.
        CONTINUE.
      ENDIF.

      rv_total = rv_total + ls_line-margin.
    ENDLOOP.
  ENDMETHOD.

  METHOD residual.
    " Once the goods left the group the margin is real and stays.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-sold_externally = abap_false.
        CONTINUE.
      ENDIF.

      rv_total = rv_total + ls_line-margin.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_cleared.
    DATA lv_remaining TYPE i.

    " The intercompany profit is cleared once nothing is left to eliminate.
    lv_remaining = eliminate( it_lines ).
    rv_ok = xsdbool( lv_remaining = 0 ).
  ENDMETHOD.

ENDCLASS.
