CLASS zcl_alloc_holding_cost DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS annual_cost
      IMPORTING
        iv_average_stock TYPE i
        iv_cost_per_unit TYPE i
      RETURNING
        VALUE(rv_cost)   TYPE i.

    METHODS per_unit
      IMPORTING
        iv_total_cost    TYPE i
        iv_average_stock TYPE i
      RETURNING
        VALUE(rv_cost)   TYPE i.

    METHODS average_stock
      IMPORTING
        iv_order_quantity TYPE i
      RETURNING
        VALUE(rv_stock)   TYPE i.

ENDCLASS.


CLASS zcl_alloc_holding_cost IMPLEMENTATION.

  METHOD annual_cost.
    " The holding cost is the average stock times the cost of one unit.
    IF iv_average_stock <= 0 OR iv_cost_per_unit <= 0.
      RETURN.
    ENDIF.

    rv_cost = iv_average_stock * iv_cost_per_unit.
  ENDMETHOD.

  METHOD per_unit.
    " One unit carries the total cost spread over the average stock.
    IF iv_average_stock <= 0.
      RETURN.
    ENDIF.

    rv_cost = iv_total_cost DIV iv_average_stock.
  ENDMETHOD.

  METHOD average_stock.
    " Over a full cycle the average stock is half the order quantity.
    IF iv_order_quantity <= 0.
      RETURN.
    ENDIF.

    rv_stock = iv_order_quantity DIV 2.
  ENDMETHOD.

ENDCLASS.
