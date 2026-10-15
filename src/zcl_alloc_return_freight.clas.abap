CLASS zcl_alloc_return_freight DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             quantity     TYPE i,
             unit_freight TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS estimate
      IMPORTING
        iv_base        TYPE i
        iv_per_unit    TYPE i
        iv_quantity    TYPE i
      RETURNING
        VALUE(rv_cost) TYPE i.

    METHODS per_unit
      IMPORTING
        iv_total       TYPE i
        iv_quantity    TYPE i
      RETURNING
        VALUE(rv_unit) TYPE i.

    METHODS total
      IMPORTING
        it_lines       TYPE ty_line_tt
      RETURNING
        VALUE(rv_cost) TYPE i.

ENDCLASS.


CLASS zcl_alloc_return_freight IMPLEMENTATION.

  METHOD estimate.
    " A return shipment pays a fixed collection fee plus a per-unit rate.
    IF iv_quantity <= 0 OR iv_base < 0 OR iv_per_unit < 0.
      RETURN.
    ENDIF.

    rv_cost = iv_base + iv_quantity * iv_per_unit.
  ENDMETHOD.

  METHOD per_unit.
    IF iv_total <= 0 OR iv_quantity <= 0.
      RETURN.
    ENDIF.

    rv_unit = iv_total DIV iv_quantity.
  ENDMETHOD.

  METHOD total.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-quantity > 0 AND ls_line-unit_freight > 0.
        rv_cost = rv_cost + ls_line-quantity * ls_line-unit_freight.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
