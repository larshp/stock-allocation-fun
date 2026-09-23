CLASS zcl_stock_avail_qty_calc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS calculate
      IMPORTING
        iv_unrestricted_quantity TYPE mard-labst
        iv_reserved_quantity     TYPE resb-bdmng
      RETURNING
        VALUE(rv_quantity)       TYPE mard-labst.

    METHODS calculate_with_safety_stock
      IMPORTING
        iv_available_quantity    TYPE mard-labst
        iv_safety_stock_quantity TYPE marc-eisbe
      RETURNING
        VALUE(rv_quantity)       TYPE mard-labst.
ENDCLASS.

CLASS zcl_stock_avail_qty_calc IMPLEMENTATION.

  METHOD calculate.
    rv_quantity = iv_unrestricted_quantity.
    IF rv_quantity < 0.
      CLEAR rv_quantity.
    ENDIF.

    IF iv_reserved_quantity > 0.
      rv_quantity = rv_quantity - iv_reserved_quantity.
    ENDIF.

    IF rv_quantity < 0.
      CLEAR rv_quantity.
    ENDIF.
  ENDMETHOD.

  METHOD calculate_with_safety_stock.
    rv_quantity = iv_available_quantity.
    IF rv_quantity < 0.
      CLEAR rv_quantity.
    ENDIF.

    IF iv_safety_stock_quantity > 0.
      rv_quantity = rv_quantity - iv_safety_stock_quantity.
    ENDIF.

    IF rv_quantity < 0.
      CLEAR rv_quantity.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
