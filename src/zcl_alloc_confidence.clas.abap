CLASS zcl_alloc_confidence DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_confidence,
             requirements  TYPE i,
             coverage_pct  TYPE i,
             fill_rate_pct TYPE i,
             score         TYPE i,
           END OF ty_confidence.

    METHODS assess
      IMPORTING
        it_result       TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rs_score) TYPE ty_confidence.

ENDCLASS.


CLASS zcl_alloc_confidence IMPLEMENTATION.

  METHOD assess.
    DATA lv_fully   TYPE i.
    DATA lv_request TYPE menge_d.
    DATA lv_alloc   TYPE menge_d.

    LOOP AT it_result INTO DATA(ls_result).
      rs_score-requirements = rs_score-requirements + 1.
      lv_request = lv_request + ls_result-requested_qty.
      lv_alloc = lv_alloc + ls_result-allocated_qty.
      IF ls_result-shortage_qty <= 0.
        lv_fully = lv_fully + 1.
      ENDIF.
    ENDLOOP.

    IF lv_request > 0.
      rs_score-coverage_pct = lv_alloc * 100 DIV lv_request.
    ENDIF.

    IF rs_score-requirements > 0.
      rs_score-fill_rate_pct = lv_fully * 100 DIV rs_score-requirements.
    ENDIF.

    rs_score-score = ( rs_score-coverage_pct + rs_score-fill_rate_pct ) DIV 2.
  ENDMETHOD.

ENDCLASS.
