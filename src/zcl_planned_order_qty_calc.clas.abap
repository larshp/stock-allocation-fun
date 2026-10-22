CLASS zcl_planned_order_qty_calc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS calculate_open_base_quantity
      IMPORTING
        iv_planned_quantity   TYPE plaf-gsmng
        iv_unit_to_base_num   TYPE marm-umrez
        iv_unit_to_base_denom TYPE marm-umren
      RETURNING
        VALUE(rv_quantity)    TYPE decfloat34.
ENDCLASS.

CLASS zcl_planned_order_qty_calc IMPLEMENTATION.
  METHOD calculate_open_base_quantity.
    IF iv_planned_quantity <= 0
        OR iv_unit_to_base_num <= 0
        OR iv_unit_to_base_denom <= 0.
      RETURN.
    ENDIF.

    rv_quantity = CONV decfloat34( iv_planned_quantity )
      * CONV decfloat34( iv_unit_to_base_num )
      / CONV decfloat34( iv_unit_to_base_denom ).
  ENDMETHOD.
ENDCLASS.
