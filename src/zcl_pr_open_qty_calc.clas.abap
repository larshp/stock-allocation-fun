CLASS zcl_pr_open_qty_calc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS calculate_open_base_quantity
      IMPORTING
        iv_requested_quantity TYPE eban-menge
        iv_ordered_quantity   TYPE eban-bsmng
        iv_unit_to_base_num   TYPE marm-umrez
        iv_unit_to_base_denom TYPE marm-umren
      RETURNING
        VALUE(rv_quantity)    TYPE decfloat34.
ENDCLASS.

CLASS zcl_pr_open_qty_calc IMPLEMENTATION.
  METHOD calculate_open_base_quantity.
    IF iv_requested_quantity <= 0
        OR iv_ordered_quantity >= iv_requested_quantity
        OR iv_unit_to_base_num <= 0
        OR iv_unit_to_base_denom <= 0.
      RETURN.
    ENDIF.

    rv_quantity = CONV decfloat34(
      iv_requested_quantity - iv_ordered_quantity )
      * CONV decfloat34( iv_unit_to_base_num )
      / CONV decfloat34( iv_unit_to_base_denom ).
  ENDMETHOD.
ENDCLASS.
