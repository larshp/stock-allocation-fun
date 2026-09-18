CLASS zcl_alloc_diff DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             requirement_id TYPE zcl_stock_allocator=>ty_result-requirement_id,
             old_qty        TYPE menge_d,
             new_qty        TYPE menge_d,
             delta_qty      TYPE menge_d,
             change_type    TYPE c LENGTH 1,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_summary,
             added       TYPE i,
             removed     TYPE i,
             changed     TYPE i,
             unchanged   TYPE i,
             old_total   TYPE menge_d,
             new_total   TYPE menge_d,
             delta_total TYPE menge_d,
           END OF ty_summary.

    TYPES: BEGIN OF ty_result,
             lines   TYPE ty_line_tt,
             summary TYPE ty_summary,
           END OF ty_result.

    METHODS compare
      IMPORTING
        it_old               TYPE zcl_stock_allocator=>ty_result_tt
        it_new               TYPE zcl_stock_allocator=>ty_result_tt
        iv_include_unchanged TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)     TYPE ty_result.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_old_entry,
             requirement_id TYPE zcl_stock_allocator=>ty_result-requirement_id,
             allocated_qty  TYPE menge_d,
             matched        TYPE abap_bool,
           END OF ty_old_entry.
    TYPES ty_old_tt TYPE STANDARD TABLE OF ty_old_entry WITH DEFAULT KEY.

    METHODS total_of
      IMPORTING
        it_result       TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rv_total) TYPE menge_d.

ENDCLASS.


CLASS zcl_alloc_diff IMPLEMENTATION.

  METHOD compare.
    DATA ls_line  TYPE ty_line.
    DATA lt_old   TYPE ty_old_tt.
    DATA ls_old   TYPE ty_old_entry.

    LOOP AT it_old INTO DATA(ls_old_result).
      CLEAR ls_old.
      ls_old-requirement_id = ls_old_result-requirement_id.
      ls_old-allocated_qty = ls_old_result-allocated_qty.
      APPEND ls_old TO lt_old.
    ENDLOOP.

    LOOP AT it_new INTO DATA(ls_new).
      CLEAR ls_line.
      ls_line-requirement_id = ls_new-requirement_id.
      ls_line-new_qty = ls_new-allocated_qty.

      LOOP AT lt_old ASSIGNING FIELD-SYMBOL(<ls_old>).
        IF <ls_old>-requirement_id = ls_new-requirement_id.
          ls_line-old_qty = <ls_old>-allocated_qty.
          <ls_old>-matched = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF ls_line-old_qty = ls_line-new_qty.
        ls_line-change_type = '='.
        rs_result-summary-unchanged = rs_result-summary-unchanged + 1.
      ELSEIF ls_line-old_qty IS INITIAL AND ls_line-new_qty > 0.
        ls_line-change_type = '+'.
        rs_result-summary-added = rs_result-summary-added + 1.
      ELSE.
        ls_line-change_type = '~'.
        rs_result-summary-changed = rs_result-summary-changed + 1.
      ENDIF.

      ls_line-delta_qty = ls_line-new_qty - ls_line-old_qty.

      IF ls_line-change_type <> '=' OR iv_include_unchanged = abap_true.
        APPEND ls_line TO rs_result-lines.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_old INTO DATA(ls_unmatched).
      IF ls_unmatched-matched = abap_true.
        CONTINUE.
      ENDIF.

      CLEAR ls_line.
      ls_line-requirement_id = ls_unmatched-requirement_id.
      ls_line-old_qty = ls_unmatched-allocated_qty.
      ls_line-delta_qty = - ls_unmatched-allocated_qty.
      ls_line-change_type = '-'.

      APPEND ls_line TO rs_result-lines.
      rs_result-summary-removed = rs_result-summary-removed + 1.
    ENDLOOP.

    rs_result-summary-old_total = total_of( it_old ).
    rs_result-summary-new_total = total_of( it_new ).
    rs_result-summary-delta_total =
      rs_result-summary-new_total - rs_result-summary-old_total.
  ENDMETHOD.

  METHOD total_of.
    LOOP AT it_result INTO DATA(ls_result).
      rv_total = rv_total + ls_result-allocated_qty.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
