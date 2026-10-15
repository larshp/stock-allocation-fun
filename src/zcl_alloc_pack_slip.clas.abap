CLASS zcl_alloc_pack_slip DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material TYPE string,
             ordered  TYPE i,
             picked   TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_slip,
             material  TYPE string,
             ordered   TYPE i,
             picked    TYPE i,
             backorder TYPE i,
             status    TYPE string,
           END OF ty_slip.
    TYPES ty_slip_tt TYPE STANDARD TABLE OF ty_slip WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_lines       TYPE ty_line_tt
      RETURNING
        VALUE(rt_slip) TYPE ty_slip_tt.

ENDCLASS.


CLASS zcl_alloc_pack_slip IMPLEMENTATION.

  METHOD build.
    DATA ls_slip TYPE ty_slip.

    LOOP AT it_lines INTO DATA(ls_line).
      CLEAR ls_slip.
      ls_slip-material = ls_line-material.
      ls_slip-ordered = ls_line-ordered.
      ls_slip-picked = ls_line-picked.

      IF ls_line-picked > ls_line-ordered.
        ls_slip-backorder = 0.
      ELSE.
        ls_slip-backorder = ls_line-ordered - ls_line-picked.
      ENDIF.

      IF ls_line-ordered <= 0 OR ls_line-picked >= ls_line-ordered.
        ls_slip-status = 'FULL'.
      ELSEIF ls_line-picked <= 0.
        ls_slip-status = 'NONE'.
      ELSE.
        ls_slip-status = 'PARTIAL'.
      ENDIF.

      APPEND ls_slip TO rt_slip.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
