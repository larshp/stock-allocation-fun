CLASS zcl_prod_order_qty_calc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS calculate_open_base_quantity
      IMPORTING
        iv_order_quantity      TYPE afpo-psmng
        iv_received_quantity   TYPE afpo-wemng
        iv_order_to_base_num   TYPE afpo-umrez
        iv_order_to_base_denom TYPE afpo-umren
      RETURNING
        VALUE(rv_quantity)     TYPE decfloat34.
ENDCLASS.

CLASS zcl_prod_order_qty_calc IMPLEMENTATION.

  METHOD calculate_open_base_quantity.
    IF iv_order_quantity <= 0
        OR iv_received_quantity >= iv_order_quantity
        OR iv_order_to_base_num <= 0
        OR iv_order_to_base_denom <= 0.
      RETURN.
    ENDIF.

    rv_quantity = CONV decfloat34(
      iv_order_quantity - iv_received_quantity )
      * CONV decfloat34( iv_order_to_base_num )
      / CONV decfloat34( iv_order_to_base_denom ).
  ENDMETHOD.

ENDCLASS.
