CLASS zcl_alloc_kpi DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_kpi,
             requirements    TYPE i,
             fully_delivered TYPE i,
             short           TYPE i,
             requested_qty   TYPE menge_d,
             allocated_qty   TYPE menge_d,
             shortage_qty    TYPE menge_d,
             coverage_pct    TYPE i,
             fill_rate_pct   TYPE i,
           END OF ty_kpi.

    METHODS summarize
      IMPORTING
        it_result     TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rs_kpi) TYPE ty_kpi.

ENDCLASS.


CLASS zcl_alloc_kpi IMPLEMENTATION.

  METHOD summarize.
    LOOP AT it_result INTO DATA(ls_result).
      rs_kpi-requirements = rs_kpi-requirements + 1.
      rs_kpi-requested_qty = rs_kpi-requested_qty + ls_result-requested_qty.
      rs_kpi-allocated_qty = rs_kpi-allocated_qty + ls_result-allocated_qty.
      rs_kpi-shortage_qty = rs_kpi-shortage_qty + ls_result-shortage_qty.

      IF ls_result-shortage_qty <= 0.
        rs_kpi-fully_delivered = rs_kpi-fully_delivered + 1.
      ELSE.
        rs_kpi-short = rs_kpi-short + 1.
      ENDIF.
    ENDLOOP.

    IF rs_kpi-requested_qty > 0.
      rs_kpi-coverage_pct = rs_kpi-allocated_qty * 100 DIV rs_kpi-requested_qty.
    ENDIF.

    IF rs_kpi-requirements > 0.
      rs_kpi-fill_rate_pct = rs_kpi-fully_delivered * 100 DIV rs_kpi-requirements.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
