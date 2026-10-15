CLASS zcl_alloc_rout_cost DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS cost
      IMPORTING
        iv_setup_cost  TYPE i
        iv_run_cost    TYPE i
        iv_qty         TYPE i
      RETURNING
        VALUE(rv_cost) TYPE i.

    METHODS per_unit
      IMPORTING
        iv_cost        TYPE i
        iv_qty         TYPE i
      RETURNING
        VALUE(rv_unit) TYPE i.

    METHODS total
      IMPORTING
        it_values       TYPE ty_values_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_rout_cost IMPLEMENTATION.

  METHOD cost.
    " The operation cost is the setup plus the run cost at its quantity.
    rv_cost = iv_setup_cost + iv_run_cost * iv_qty.
  ENDMETHOD.

  METHOD per_unit.
    " The unit cost spreads the operation cost over the quantity.
    IF iv_qty <= 0.
      RETURN.
    ENDIF.

    rv_unit = iv_cost DIV iv_qty.
  ENDMETHOD.

  METHOD total.
    " The total adds the cost of every operation.
    LOOP AT it_values INTO DATA(lv_value).
      rv_total = rv_total + lv_value.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
