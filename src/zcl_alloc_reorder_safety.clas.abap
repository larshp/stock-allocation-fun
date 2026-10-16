CLASS zcl_alloc_reorder_safety DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS demand_part
      IMPORTING
        iv_daily_demand TYPE i
        iv_lead_days    TYPE i
      RETURNING
        VALUE(rv_part)  TYPE i.

    METHODS safety_part
      IMPORTING
        iv_service_factor TYPE i
        iv_demand_std_dev TYPE i
        iv_lead_days      TYPE i
      RETURNING
        VALUE(rv_part)    TYPE i.

    METHODS point
      IMPORTING
        iv_daily_demand TYPE i
        iv_lead_days    TYPE i
        iv_safety_stock TYPE i
      RETURNING
        VALUE(rv_point) TYPE i.

ENDCLASS.


CLASS zcl_alloc_reorder_safety IMPLEMENTATION.

  METHOD demand_part.
    " The demand part covers the demand over the lead time.
    IF iv_daily_demand <= 0 OR iv_lead_days <= 0.
      RETURN.
    ENDIF.

    rv_part = iv_daily_demand * iv_lead_days.
  ENDMETHOD.

  METHOD safety_part.
    DATA lo_stock TYPE REF TO zcl_alloc_safety_stock.

    " The safety part reuses the safety-stock calculation.
    lo_stock = NEW zcl_alloc_safety_stock( ).
    rv_part = lo_stock->stock( iv_service_factor = iv_service_factor
                               iv_lead_days      = iv_lead_days
                               iv_demand_std_dev = iv_demand_std_dev ).
  ENDMETHOD.

  METHOD point.
    DATA lv_demand TYPE i.

    " The reorder point adds the safety stock on top of the demand part.
    lv_demand = demand_part( iv_daily_demand = iv_daily_demand
                             iv_lead_days    = iv_lead_days ).

    rv_point = lv_demand + iv_safety_stock.
  ENDMETHOD.

ENDCLASS.
