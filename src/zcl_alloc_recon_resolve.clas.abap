CLASS zcl_alloc_recon_resolve DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             key  TYPE string,
             diff TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS resolve
      IMPORTING
        it_diffs        TYPE ty_line_tt
        iv_tolerance    TYPE i
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS is_resolved
      IMPORTING
        iv_diff      TYPE i
        iv_tolerance TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS open_count
      IMPORTING
        it_diffs        TYPE ty_line_tt
        iv_tolerance    TYPE i
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_recon_resolve IMPLEMENTATION.

  METHOD is_resolved.
    DATA lv_size TYPE i.

    " A difference is resolved once it sits within the tolerance.
    lv_size = iv_diff.
    IF lv_size < 0.
      lv_size = -1 * lv_size.
    ENDIF.

    rv_ok = xsdbool( lv_size <= iv_tolerance ).
  ENDMETHOD.

  METHOD resolve.
    DATA ls_out TYPE ty_line.

    " Differences within the tolerance are cleared in the result.
    LOOP AT it_diffs INTO DATA(ls_in).
      CLEAR ls_out.
      ls_out-key = ls_in-key.
      IF is_resolved(
        iv_diff = ls_in-diff iv_tolerance = iv_tolerance ) = abap_false.
        ls_out-diff = ls_in-diff.
      ENDIF.
      APPEND ls_out TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

  METHOD open_count.
    " The open count gathers the differences still out of tolerance.
    LOOP AT it_diffs INTO DATA(ls_in).
      IF is_resolved(
        iv_diff = ls_in-diff iv_tolerance = iv_tolerance ) = abap_false.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
