INTERFACE zif_planned_order_read_repo PUBLIC.

  TYPES ty_order_number TYPE plaf-plnum.
  TYPES ty_order_numbers TYPE STANDARD TABLE OF ty_order_number
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_order_header,
      planned_order            TYPE plaf-plnum,
      material                 TYPE plaf-matnr,
      plant                    TYPE plaf-pwwrk,
      start_date               TYPE plaf-psttr,
      finish_date              TYPE plaf-pedtr,
      quantity                 TYPE plaf-gsmng,
      order_unit               TYPE plaf-meins,
      base_unit                TYPE mara-meins,
      fixed_indicator          TYPE plaf-auffx,
      planning_scenario        TYPE plaf-plscn,
      special_stock_indicator  TYPE plaf-sobkz,
      sales_order              TYPE plaf-kdauf,
      unit_to_base_numerator   TYPE marm-umrez,
      unit_to_base_denominator TYPE marm-umren,
    END OF ty_order_header.
  TYPES ty_order_headers TYPE STANDARD TABLE OF ty_order_header
    WITH EMPTY KEY.

  METHODS read_orders
    IMPORTING
      it_planned_orders TYPE ty_order_numbers
    RETURNING
      VALUE(rt_orders)  TYPE ty_order_headers.

ENDINTERFACE.
