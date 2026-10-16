CLASS zcl_alloc_regression_baseline DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_entry,
             requirement_id TYPE zcl_stock_allocator=>ty_result-requirement_id,
             allocated_qty  TYPE menge_d,
           END OF ty_entry.
    TYPES ty_entry_tt TYPE STANDARD TABLE OF ty_entry WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_delta,
             requirement_id TYPE zcl_stock_allocator=>ty_result-requirement_id,
             kind           TYPE string,
             before_qty     TYPE menge_d,
             after_qty      TYPE menge_d,
           END OF ty_delta.
    TYPES ty_delta_tt TYPE STANDARD TABLE OF ty_delta WITH DEFAULT KEY.

    METHODS capture
      IMPORTING
        it_result           TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rt_signature) TYPE ty_entry_tt.

    METHODS compare
      IMPORTING
        it_before        TYPE ty_entry_tt
        it_after         TYPE ty_entry_tt
      RETURNING
        VALUE(rt_deltas) TYPE ty_delta_tt.

    METHODS is_unchanged
      IMPORTING
        it_deltas    TYPE ty_delta_tt
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

  PRIVATE SECTION.
    CONSTANTS c_added   TYPE string VALUE 'added'.
    CONSTANTS c_removed TYPE string VALUE 'removed'.
    CONSTANTS c_changed TYPE string VALUE 'changed'.

    METHODS in_baseline
      IMPORTING
        it_before     TYPE ty_entry_tt
        iv_id         TYPE zcl_stock_allocator=>ty_result-requirement_id
      RETURNING
        VALUE(rv_hit) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_regression_baseline IMPLEMENTATION.

  METHOD capture.
    DATA ls_entry TYPE ty_entry.

    LOOP AT it_result INTO DATA(ls_line).
      CLEAR ls_entry.
      ls_entry-requirement_id = ls_line-requirement_id.
      ls_entry-allocated_qty = ls_line-allocated_qty.
      APPEND ls_entry TO rt_signature.
    ENDLOOP.
  ENDMETHOD.

  METHOD in_baseline.
    READ TABLE it_before INTO DATA(ls_entry)
      WITH KEY requirement_id = iv_id.

    IF sy-subrc = 0.
      rv_hit = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD compare.
    DATA ls_delta TYPE ty_delta.

    " Everything the new run produced: new lines and lines that moved.
    LOOP AT it_after INTO DATA(ls_after).
      READ TABLE it_before INTO DATA(ls_before)
        WITH KEY requirement_id = ls_after-requirement_id.

      CLEAR ls_delta.
      ls_delta-requirement_id = ls_after-requirement_id.

      IF sy-subrc <> 0.
        ls_delta-kind = c_added.
        ls_delta-after_qty = ls_after-allocated_qty.
        APPEND ls_delta TO rt_deltas.
        CONTINUE.
      ENDIF.

      IF ls_before-allocated_qty = ls_after-allocated_qty.
        CONTINUE.
      ENDIF.

      ls_delta-kind = c_changed.
      ls_delta-before_qty = ls_before-allocated_qty.
      ls_delta-after_qty = ls_after-allocated_qty.
      APPEND ls_delta TO rt_deltas.
    ENDLOOP.

    " Everything the baseline had and the new run no longer produces.
    LOOP AT it_before INTO ls_before.
      IF in_baseline( it_before = it_after
                      iv_id     = ls_before-requirement_id ) = abap_true.
        CONTINUE.
      ENDIF.

      CLEAR ls_delta.
      ls_delta-requirement_id = ls_before-requirement_id.
      ls_delta-kind = c_removed.
      ls_delta-before_qty = ls_before-allocated_qty.
      APPEND ls_delta TO rt_deltas.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_unchanged.
    rv_ok = abap_true.

    IF lines( it_deltas ) > 0.
      rv_ok = abap_false.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
