CLASS zcl_alloc_drv_rate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS rate
      IMPORTING
        iv_cost        TYPE i
        iv_quantity    TYPE i
      RETURNING
        VALUE(rv_rate) TYPE i.

    METHODS applied
      IMPORTING
        iv_rate        TYPE i
        iv_quantity    TYPE i
      RETURNING
        VALUE(rv_cost) TYPE i.

    METHODS is_zero
      IMPORTING
        iv_rate      TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_drv_rate IMPLEMENTATION.

  METHOD rate.
    " The driver rate is the cost spread over the driver quantity.
    IF iv_quantity <= 0.
      RETURN.
    ENDIF.

    rv_rate = iv_cost DIV iv_quantity.
  ENDMETHOD.

  METHOD applied.
    " Applying the rate to a quantity gives back the cost.
    rv_cost = iv_rate * iv_quantity.
  ENDMETHOD.

  METHOD is_zero.
    " A rate at zero carries no cost.
    rv_ok = xsdbool( iv_rate = 0 ).
  ENDMETHOD.

ENDCLASS.
