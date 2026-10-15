CLASS zcl_alloc_reorder_calc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS point
      IMPORTING
        iv_daily_demand TYPE i
        iv_lead_days    TYPE i
      RETURNING
        VALUE(rv_point) TYPE i.

    METHODS is_below
      IMPORTING
        iv_stock     TYPE i
        iv_point     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS gap
      IMPORTING
        iv_stock      TYPE i
        iv_point      TYPE i
      RETURNING
        VALUE(rv_gap) TYPE i.

ENDCLASS.


CLASS zcl_alloc_reorder_calc IMPLEMENTATION.

  METHOD point.
    " The reorder point covers the demand over the lead time.
    IF iv_daily_demand <= 0 OR iv_lead_days <= 0.
      RETURN.
    ENDIF.

    rv_point = iv_daily_demand * iv_lead_days.
  ENDMETHOD.

  METHOD is_below.
    " A reorder is due once the stock falls below the point.
    rv_ok = xsdbool( iv_stock < iv_point ).
  ENDMETHOD.

  METHOD gap.
    " The gap to the reorder point is never negative.
    IF iv_stock >= iv_point.
      RETURN.
    ENDIF.

    rv_gap = iv_point - iv_stock.
  ENDMETHOD.

ENDCLASS.
