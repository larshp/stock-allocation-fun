CLASS zcl_alloc_shock DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             shock_pct TYPE i,
             shock_abs TYPE menge_d,
             floor     TYPE menge_d,
           END OF ty_input.

    METHODS apply
      IMPORTING
        is_input        TYPE ty_input
        it_stock        TYPE zif_stock_reader=>ty_stock_tt
      RETURNING
        VALUE(rt_stock) TYPE zif_stock_reader=>ty_stock_tt.

    METHODS available_of
      IMPORTING
        it_stock        TYPE zif_stock_reader=>ty_stock_tt
      RETURNING
        VALUE(rv_total) TYPE menge_d.

ENDCLASS.


CLASS zcl_alloc_shock IMPLEMENTATION.

  METHOD apply.
    DATA ls_stock TYPE zif_stock_reader=>ty_stock.
    DATA lv_new   TYPE menge_d.

    LOOP AT it_stock INTO DATA(ls_base).
      ls_stock = ls_base.

      lv_new = ls_base-unrestricted_qty * ( 100 - is_input-shock_pct ) DIV 100.
      lv_new = lv_new - is_input-shock_abs.

      IF lv_new < is_input-floor.
        lv_new = is_input-floor.
      ENDIF.

      IF lv_new < 0.
        lv_new = 0.
      ENDIF.

      ls_stock-unrestricted_qty = lv_new.
      APPEND ls_stock TO rt_stock.
    ENDLOOP.
  ENDMETHOD.

  METHOD available_of.
    LOOP AT it_stock INTO DATA(ls_stock).
      rv_total = rv_total + ls_stock-unrestricted_qty.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
