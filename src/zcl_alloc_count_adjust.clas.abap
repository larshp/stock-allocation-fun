CLASS zcl_alloc_count_adjust DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_proposal,
             book_qty    TYPE menge_d,
             counted_qty TYPE menge_d,
             adjust_qty  TYPE menge_d,
             reason      TYPE string,
           END OF ty_proposal.

    METHODS propose
      IMPORTING
        iv_book          TYPE menge_d
        iv_counted       TYPE menge_d
      RETURNING
        VALUE(rs_result) TYPE ty_proposal.

    METHODS posting_qty
      IMPORTING
        is_proposal   TYPE ty_proposal
      RETURNING
        VALUE(rv_qty) TYPE menge_d.

ENDCLASS.


CLASS zcl_alloc_count_adjust IMPLEMENTATION.

  METHOD propose.
    rs_result-book_qty = iv_book.
    rs_result-counted_qty = iv_counted.
    rs_result-adjust_qty = iv_counted - iv_book.

    " Rounded to whole pieces the adjustment may be zero even when the stored
    " quantities differ, and then there is nothing to post.
    IF rs_result-adjust_qty = 0.
      rs_result-reason = 'NONE'.
    ELSEIF rs_result-adjust_qty > 0.
      rs_result-reason = 'GAIN'.
    ELSE.
      rs_result-reason = 'LOSS'.
    ENDIF.
  ENDMETHOD.

  METHOD posting_qty.
    rv_qty = is_proposal-adjust_qty.
    IF rv_qty < 0.
      rv_qty = 0 - rv_qty.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
