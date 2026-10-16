CLASS zcl_alloc_cpool_rate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS rate
      IMPORTING
        iv_pool        TYPE i
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


CLASS zcl_alloc_cpool_rate IMPLEMENTATION.

  METHOD rate.
    " The pool rate spreads the pool over the driver quantity.
    IF iv_quantity <= 0.
      RETURN.
    ENDIF.

    rv_rate = iv_pool DIV iv_quantity.
  ENDMETHOD.

  METHOD applied.
    " The rate on a quantity gives back the pool cost.
    rv_cost = iv_rate * iv_quantity.
  ENDMETHOD.

  METHOD is_zero.
    " A rate at zero carries no pool cost.
    rv_ok = xsdbool( iv_rate = 0 ).
  ENDMETHOD.

ENDCLASS.
