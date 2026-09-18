CLASS zcl_alloc_reorder_point DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             daily_demand   TYPE menge_d,
             lead_time_days TYPE i,
             safety_stock   TYPE menge_d,
           END OF ty_input.

    METHODS calculate
      IMPORTING
        is_input      TYPE ty_input
      RETURNING
        VALUE(rv_qty) TYPE menge_d.

ENDCLASS.


CLASS zcl_alloc_reorder_point IMPLEMENTATION.

  METHOD calculate.
    rv_qty = is_input-daily_demand * is_input-lead_time_days
      + is_input-safety_stock.
  ENDMETHOD.

ENDCLASS.
