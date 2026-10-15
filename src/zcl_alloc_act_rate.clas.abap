CLASS zcl_alloc_act_rate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS rate
      IMPORTING
        iv_cost        TYPE i
        iv_driver_qty  TYPE i
      RETURNING
        VALUE(rv_rate) TYPE i.

    METHODS from_cost
      IMPORTING
        iv_rate        TYPE i
        iv_driver_qty  TYPE i
      RETURNING
        VALUE(rv_cost) TYPE i.

    METHODS is_zero
      IMPORTING
        iv_rate      TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_act_rate IMPLEMENTATION.

  METHOD rate.
    " The activity rate spreads the pool cost over the driver quantity.
    IF iv_driver_qty <= 0.
      RETURN.
    ENDIF.

    rv_rate = iv_cost DIV iv_driver_qty.
  ENDMETHOD.

  METHOD from_cost.
    " The rate applied to a driver quantity gives back the pool cost.
    rv_cost = iv_rate * iv_driver_qty.
  ENDMETHOD.

  METHOD is_zero.
    " A rate at zero carries no pool cost.
    rv_ok = xsdbool( iv_rate = 0 ).
  ENDMETHOD.

ENDCLASS.
