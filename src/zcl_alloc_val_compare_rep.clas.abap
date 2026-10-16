CLASS zcl_alloc_val_compare_rep DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material  TYPE matnr,
             old_value TYPE i,
             new_value TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_delta,
             material TYPE matnr,
             delta    TYPE i,
           END OF ty_delta.
    TYPES ty_delta_tt TYPE STANDARD TABLE OF ty_delta WITH DEFAULT KEY.

    METHODS compare
      IMPORTING
        it_lines         TYPE ty_line_tt
      RETURNING
        VALUE(rt_deltas) TYPE ty_delta_tt.

    METHODS changed_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS is_same
      IMPORTING
        iv_old_value TYPE i
        iv_new_value TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_val_compare_rep IMPLEMENTATION.

  METHOD compare.
    DATA ls_delta TYPE ty_delta.

    " Only the lines whose value moved show up in the comparison.
    LOOP AT it_lines INTO DATA(ls_line).
      IF is_same( iv_old_value = ls_line-old_value
                  iv_new_value = ls_line-new_value ) = abap_true.
        CONTINUE.
      ENDIF.

      ls_delta-material = ls_line-material.
      ls_delta-delta = ls_line-new_value - ls_line-old_value.
      APPEND ls_delta TO rt_deltas.
    ENDLOOP.
  ENDMETHOD.

  METHOD changed_count.
    DATA lt_deltas TYPE ty_delta_tt.

    " The count is how many lines moved between the two valuations.
    lt_deltas = compare( it_lines ).
    rv_count = lines( lt_deltas ).
  ENDMETHOD.

  METHOD is_same.
    " Two values are the same once they match.
    rv_ok = xsdbool( iv_old_value = iv_new_value ).
  ENDMETHOD.

ENDCLASS.
