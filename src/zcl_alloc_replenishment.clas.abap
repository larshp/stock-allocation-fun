CLASS zcl_alloc_replenishment DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_proposal,
             matnr          TYPE matnr,
             requirement_id TYPE c LENGTH 20,
             shortage_qty   TYPE menge_d,
             order_qty      TYPE menge_d,
           END OF ty_proposal.
    TYPES ty_proposal_tt TYPE STANDARD TABLE OF ty_proposal WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_summary,
             proposals    TYPE i,
             shortage_qty TYPE menge_d,
             order_qty    TYPE menge_d,
           END OF ty_summary.

    TYPES: BEGIN OF ty_result,
             proposals TYPE ty_proposal_tt,
             summary   TYPE ty_summary,
           END OF ty_result.

    METHODS build
      IMPORTING
        iv_matnr         TYPE matnr
        it_result        TYPE zcl_stock_allocator=>ty_result_tt
        iv_round_to      TYPE menge_d DEFAULT 0
        iv_min_order     TYPE menge_d DEFAULT 0
      RETURNING
        VALUE(rs_result) TYPE ty_result.

  PRIVATE SECTION.
    METHODS round_up
      IMPORTING
        iv_quantity     TYPE menge_d
        iv_round_to     TYPE menge_d
        iv_min_order    TYPE menge_d
      RETURNING
        VALUE(rv_order) TYPE menge_d.

ENDCLASS.


CLASS zcl_alloc_replenishment IMPLEMENTATION.

  METHOD build.
    DATA ls_proposal TYPE ty_proposal.

    LOOP AT it_result INTO DATA(ls_result).
      IF ls_result-shortage_qty <= 0.
        CONTINUE.
      ENDIF.

      CLEAR ls_proposal.
      ls_proposal-matnr = iv_matnr.
      ls_proposal-requirement_id = ls_result-requirement_id.
      ls_proposal-shortage_qty = ls_result-shortage_qty.
      ls_proposal-order_qty = round_up( iv_quantity  = ls_result-shortage_qty
                                        iv_round_to  = iv_round_to
                                        iv_min_order = iv_min_order ).

      APPEND ls_proposal TO rs_result-proposals.
      rs_result-summary-proposals = rs_result-summary-proposals + 1.
      rs_result-summary-shortage_qty = rs_result-summary-shortage_qty
        + ls_proposal-shortage_qty.
      rs_result-summary-order_qty = rs_result-summary-order_qty
        + ls_proposal-order_qty.
    ENDLOOP.
  ENDMETHOD.

  METHOD round_up.
    DATA lv_multiples TYPE i.

    rv_order = iv_quantity.

    IF iv_round_to > 0.
      " round the shortage up to the next whole multiple of the lot size
      lv_multiples = iv_quantity DIV iv_round_to.
      rv_order = lv_multiples * iv_round_to.
      IF rv_order < iv_quantity.
        rv_order = rv_order + iv_round_to.
      ENDIF.
    ENDIF.

    IF rv_order < iv_min_order.
      rv_order = iv_min_order.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
