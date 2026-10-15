CLASS zcl_alloc_var_price DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS variance
      IMPORTING
        iv_standard_price  TYPE i
        iv_actual_price    TYPE i
        iv_quantity        TYPE i
      RETURNING
        VALUE(rv_variance) TYPE i.

    METHODS is_favourable
      IMPORTING
        iv_standard_price TYPE i
        iv_actual_price   TYPE i
      RETURNING
        VALUE(rv_ok)      TYPE abap_bool.

    METHODS percent
      IMPORTING
        iv_standard_price TYPE i
        iv_actual_price   TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

ENDCLASS.


CLASS zcl_alloc_var_price IMPLEMENTATION.

  METHOD variance.
    DATA lv_delta TYPE i.

    " The price variance is the price move spread over the quantity used.
    lv_delta = iv_actual_price - iv_standard_price.
    rv_variance = lv_delta * iv_quantity.
  ENDMETHOD.

  METHOD is_favourable.
    " Buying below the standard price is favourable.
    rv_ok = xsdbool( iv_actual_price < iv_standard_price ).
  ENDMETHOD.

  METHOD percent.
    DATA lv_delta TYPE i.

    " The move is related to the standard price it was measured against.
    IF iv_standard_price = 0.
      RETURN.
    ENDIF.

    lv_delta = iv_actual_price - iv_standard_price.
    rv_percent = lv_delta * 100 DIV iv_standard_price.
  ENDMETHOD.

ENDCLASS.
