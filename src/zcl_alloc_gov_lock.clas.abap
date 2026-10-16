CLASS zcl_alloc_gov_lock DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             key    TYPE string,
             locked TYPE abap_bool,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS lock
      IMPORTING
        it_lines        TYPE ty_line_tt
        iv_key          TYPE string
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS is_locked
      IMPORTING
        it_lines     TYPE ty_line_tt
        iv_key       TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS lock_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_gov_lock IMPLEMENTATION.

  METHOD lock.
    DATA ls_out TYPE ty_line.

    " The named item is locked in the returned list.
    LOOP AT it_lines INTO DATA(ls_in).
      CLEAR ls_out.
      ls_out-key = ls_in-key.
      ls_out-locked = ls_in-locked.
      IF ls_in-key = iv_key.
        ls_out-locked = abap_true.
      ENDIF.
      APPEND ls_out TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_locked.
    " The item is locked once its flag is set.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-key = iv_key AND ls_line-locked = abap_true.
        rv_ok = abap_true.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD lock_count.
    " The count gathers the items that are locked.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-locked = abap_true.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
