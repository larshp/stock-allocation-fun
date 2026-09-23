CLASS zcl_po_sched_qty_calc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS calculate_open_base_quantity
      IMPORTING
        iv_scheduled_quantity  TYPE eket-menge
        iv_received_quantity   TYPE eket-wemng
        iv_order_to_base_num   TYPE ekpo-umrez
        iv_order_to_base_denom TYPE ekpo-umren
      RETURNING
        VALUE(rv_quantity)     TYPE decfloat34.
    METHODS calculate_open_issued_qty
      IMPORTING
        iv_issued_quantity     TYPE eket-wamng
        iv_received_quantity   TYPE eket-wemng
        iv_order_to_base_num   TYPE ekpo-umrez
        iv_order_to_base_denom TYPE ekpo-umren
      RETURNING
        VALUE(rv_quantity)     TYPE decfloat34.
ENDCLASS.

CLASS zcl_po_sched_qty_calc IMPLEMENTATION.

  METHOD calculate_open_base_quantity.
    IF iv_scheduled_quantity <= 0
        OR iv_received_quantity >= iv_scheduled_quantity
        OR iv_order_to_base_num <= 0
        OR iv_order_to_base_denom <= 0.
      RETURN.
    ENDIF.

    rv_quantity = CONV decfloat34(
      iv_scheduled_quantity - iv_received_quantity )
      * CONV decfloat34( iv_order_to_base_num )
      / CONV decfloat34( iv_order_to_base_denom ).
  ENDMETHOD.

  METHOD calculate_open_issued_qty.
    rv_quantity = calculate_open_base_quantity(
      iv_scheduled_quantity  = iv_issued_quantity
      iv_received_quantity   = iv_received_quantity
      iv_order_to_base_num   = iv_order_to_base_num
      iv_order_to_base_denom = iv_order_to_base_denom ).
  ENDMETHOD.

ENDCLASS.
