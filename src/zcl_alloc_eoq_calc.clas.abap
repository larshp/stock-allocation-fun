CLASS zcl_alloc_eoq_calc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS eoq
      IMPORTING
        iv_annual_demand TYPE i
        iv_order_cost    TYPE i
        iv_holding_cost  TYPE i
      RETURNING
        VALUE(rv_eoq)    TYPE i.

    METHODS is_valid
      IMPORTING
        iv_eoq       TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS order_count
      IMPORTING
        iv_annual_demand  TYPE i
        iv_order_quantity TYPE i
      RETURNING
        VALUE(rv_count)   TYPE i.

  PRIVATE SECTION.
    METHODS square_root
      IMPORTING
        iv_value       TYPE i
      RETURNING
        VALUE(rv_root) TYPE i.

ENDCLASS.


CLASS zcl_alloc_eoq_calc IMPLEMENTATION.

  METHOD square_root.
    DATA lv_limit TYPE i.

    lv_limit = iv_value.
    IF lv_limit < 0.
      lv_limit = 0.
    ENDIF.

    " The integer root is grown until the next square would overshoot.
    WHILE ( rv_root + 1 ) * ( rv_root + 1 ) <= lv_limit.
      rv_root = rv_root + 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD eoq.
    DATA lv_under TYPE i.

    " The economic order quantity needs a positive holding cost and demand.
    IF iv_holding_cost <= 0 OR iv_annual_demand <= 0.
      RETURN.
    ENDIF.

    lv_under = 2 * iv_annual_demand * iv_order_cost DIV iv_holding_cost.
    IF lv_under <= 0.
      RETURN.
    ENDIF.

    rv_eoq = square_root( lv_under ).
  ENDMETHOD.

  METHOD is_valid.
    rv_ok = xsdbool( iv_eoq > 0 ).
  ENDMETHOD.

  METHOD order_count.
    " The number of orders a year spreads the demand over the order quantity.
    IF iv_order_quantity <= 0.
      RETURN.
    ENDIF.

    rv_count = iv_annual_demand DIV iv_order_quantity.
  ENDMETHOD.

ENDCLASS.
