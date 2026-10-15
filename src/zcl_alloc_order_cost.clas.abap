CLASS zcl_alloc_order_cost DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS annual_cost
      IMPORTING
        iv_order_count    TYPE i
        iv_cost_per_order TYPE i
      RETURNING
        VALUE(rv_cost)    TYPE i.

    METHODS per_order
      IMPORTING
        iv_total_cost  TYPE i
        iv_order_count TYPE i
      RETURNING
        VALUE(rv_cost) TYPE i.

    METHODS order_count
      IMPORTING
        iv_annual_demand  TYPE i
        iv_order_quantity TYPE i
      RETURNING
        VALUE(rv_count)   TYPE i.

ENDCLASS.


CLASS zcl_alloc_order_cost IMPLEMENTATION.

  METHOD annual_cost.
    " The ordering cost is the order count times the cost of one order.
    IF iv_order_count <= 0 OR iv_cost_per_order <= 0.
      RETURN.
    ENDIF.

    rv_cost = iv_order_count * iv_cost_per_order.
  ENDMETHOD.

  METHOD per_order.
    " One order carries the total cost spread over the orders.
    IF iv_order_count <= 0.
      RETURN.
    ENDIF.

    rv_cost = iv_total_cost DIV iv_order_count.
  ENDMETHOD.

  METHOD order_count.
    " The number of orders a year spreads the demand over the order quantity.
    IF iv_order_quantity <= 0.
      RETURN.
    ENDIF.

    rv_count = iv_annual_demand DIV iv_order_quantity.
  ENDMETHOD.

ENDCLASS.
