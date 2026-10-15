CLASS zcl_alloc_replenish_release DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material TYPE matnr,
             released TYPE abap_bool,
             blocked  TYPE abap_bool,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS release
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS is_released
      IMPORTING
        it_lines     TYPE ty_line_tt
        iv_material  TYPE matnr
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS blocked_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_replenish_release IMPLEMENTATION.

  METHOD release.
    DATA ls_out TYPE ty_line.

    " Every unblocked line is released; a blocked line is left alone.
    LOOP AT it_lines INTO DATA(ls_line).
      ls_out = ls_line.
      IF ls_line-blocked = abap_false.
        ls_out-released = abap_true.
      ENDIF.
      APPEND ls_out TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_released.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-material = iv_material.
        rv_ok = ls_line-released.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD blocked_count.
    " The blocked lines are the ones that cannot be released.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-blocked = abap_true.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
