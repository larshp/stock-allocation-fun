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
    METHODS calc_open_sched_mrp_qty
      IMPORTING
        iv_scheduled_quantity   TYPE eket-menge
        iv_received_quantity    TYPE eket-wemng
        iv_mrp_reduced_quantity TYPE eket-dabmg
        iv_order_to_base_num    TYPE ekpo-umrez
        iv_order_to_base_denom  TYPE ekpo-umren
      RETURNING
        VALUE(rv_quantity)      TYPE decfloat34.
    METHODS calc_open_conf_base_qty
      IMPORTING
        iv_confirmed_quantity  TYPE ekes-menge
        iv_reduced_quantity    TYPE ekes-dabmg
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
    METHODS calculate_open_unissued_qty
      IMPORTING
        iv_scheduled_quantity  TYPE eket-menge
        iv_issued_quantity     TYPE eket-wamng
        iv_order_to_base_num   TYPE ekpo-umrez
        iv_order_to_base_denom TYPE ekpo-umren
      RETURNING
        VALUE(rv_quantity)     TYPE decfloat34.
ENDCLASS.

CLASS zcl_po_sched_qty_calc IMPLEMENTATION.

  METHOD calculate_open_base_quantity.
    IF iv_scheduled_quantity <= 0
        OR iv_received_quantity < 0
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

  METHOD calc_open_sched_mrp_qty.
    DATA(lv_scheduled_quantity) =
      CONV decfloat34( iv_scheduled_quantity ).
    DATA(lv_received_quantity) =
      CONV decfloat34( iv_received_quantity ).
    DATA(lv_reduced_quantity) =
      CONV decfloat34( iv_mrp_reduced_quantity ).
    IF lv_scheduled_quantity <= 0
        OR lv_received_quantity < 0
        OR lv_reduced_quantity < 0.
      RETURN.
    ENDIF.

    IF lv_received_quantity > lv_reduced_quantity.
      lv_reduced_quantity = lv_received_quantity.
    ENDIF.

    IF lv_scheduled_quantity <= lv_reduced_quantity
        OR iv_order_to_base_num <= 0
        OR iv_order_to_base_denom <= 0.
      RETURN.
    ENDIF.

    rv_quantity = CONV decfloat34(
      lv_scheduled_quantity - lv_reduced_quantity )
      * CONV decfloat34( iv_order_to_base_num )
      / CONV decfloat34( iv_order_to_base_denom ).
  ENDMETHOD.

  METHOD calc_open_conf_base_qty.
    IF iv_confirmed_quantity < 0 OR iv_reduced_quantity < 0
        OR iv_order_to_base_num <= 0
        OR iv_order_to_base_denom <= 0.
      RETURN.
    ENDIF.

    DATA(lv_open_quantity) = CONV decfloat34( iv_confirmed_quantity )
      - CONV decfloat34( iv_reduced_quantity ).

    IF lv_open_quantity <= 0.
      RETURN.
    ENDIF.

    rv_quantity = CONV decfloat34(
      lv_open_quantity )
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

  METHOD calculate_open_unissued_qty.
    IF iv_scheduled_quantity <= 0 OR iv_issued_quantity < 0
        OR iv_scheduled_quantity <= iv_issued_quantity
        OR iv_order_to_base_num <= 0
        OR iv_order_to_base_denom <= 0.
      RETURN.
    ENDIF.

    rv_quantity = CONV decfloat34(
      iv_scheduled_quantity - iv_issued_quantity )
      * CONV decfloat34( iv_order_to_base_num )
      / CONV decfloat34( iv_order_to_base_denom ).
  ENDMETHOD.

ENDCLASS.
