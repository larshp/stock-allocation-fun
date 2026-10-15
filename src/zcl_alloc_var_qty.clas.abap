CLASS zcl_alloc_var_qty DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS variance
      IMPORTING
        iv_standard_qty    TYPE i
        iv_actual_qty      TYPE i
        iv_standard_price  TYPE i
      RETURNING
        VALUE(rv_variance) TYPE i.

    METHODS is_favourable
      IMPORTING
        iv_standard_qty TYPE i
        iv_actual_qty   TYPE i
      RETURNING
        VALUE(rv_ok)    TYPE abap_bool.

    METHODS percent
      IMPORTING
        iv_standard_qty   TYPE i
        iv_actual_qty     TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

ENDCLASS.


CLASS zcl_alloc_var_qty IMPLEMENTATION.

  METHOD variance.
    DATA lv_delta TYPE i.

    " The quantity variance is the usage move valued at the standard price.
    lv_delta = iv_actual_qty - iv_standard_qty.
    rv_variance = lv_delta * iv_standard_price.
  ENDMETHOD.

  METHOD is_favourable.
    " Using less than the standard quantity is favourable.
    rv_ok = xsdbool( iv_actual_qty < iv_standard_qty ).
  ENDMETHOD.

  METHOD percent.
    DATA lv_delta TYPE i.

    " The move is related to the standard quantity it was measured against.
    IF iv_standard_qty = 0.
      RETURN.
    ENDIF.

    lv_delta = iv_actual_qty - iv_standard_qty.
    rv_percent = lv_delta * 100 DIV iv_standard_qty.
  ENDMETHOD.

ENDCLASS.
