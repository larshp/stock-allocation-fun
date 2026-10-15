CLASS zcl_alloc_return_stock_kpi DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_stock,
             quantity   TYPE i,
             unit_value TYPE i,
             age_days   TYPE i,
           END OF ty_stock.

    TYPES: BEGIN OF ty_kpi,
             value    TYPE i,
             age_days TYPE i,
             aged     TYPE abap_bool,
           END OF ty_kpi.

    METHODS build
      IMPORTING
        is_stock      TYPE ty_stock
      RETURNING
        VALUE(rs_kpi) TYPE ty_kpi.

    METHODS value
      IMPORTING
        iv_quantity     TYPE i
        iv_unit_value   TYPE i
      RETURNING
        VALUE(rv_value) TYPE i.

    METHODS age_days
      IMPORTING
        iv_received    TYPE d
        iv_check       TYPE d
      RETURNING
        VALUE(rv_days) TYPE i.

ENDCLASS.


CLASS zcl_alloc_return_stock_kpi IMPLEMENTATION.

  METHOD value.
    IF iv_quantity <= 0 OR iv_unit_value <= 0.
      RETURN.
    ENDIF.

    rv_value = iv_quantity * iv_unit_value.
  ENDMETHOD.

  METHOD age_days.
    " The stock age is the number of days between receipt and the check day.
    IF iv_received IS INITIAL OR iv_check IS INITIAL.
      RETURN.
    ENDIF.

    IF iv_check < iv_received.
      RETURN.
    ENDIF.

    rv_days = iv_check - iv_received.
  ENDMETHOD.

  METHOD build.
    " The card states the stock value and age, and flags stock past 90 days as
    " aged.
    rs_kpi-value = value( iv_quantity   = is_stock-quantity
                          iv_unit_value = is_stock-unit_value ).
    rs_kpi-age_days = is_stock-age_days.
    rs_kpi-aged = xsdbool( is_stock-age_days > 90 ).
  ENDMETHOD.

ENDCLASS.
