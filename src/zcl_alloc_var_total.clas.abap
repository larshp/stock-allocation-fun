CLASS zcl_alloc_var_total DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS variance
      IMPORTING
        iv_actual_total    TYPE i
        iv_standard_total  TYPE i
      RETURNING
        VALUE(rv_variance) TYPE i.

    METHODS is_adverse
      IMPORTING
        iv_actual_total   TYPE i
        iv_standard_total TYPE i
      RETURNING
        VALUE(rv_ok)      TYPE abap_bool.

    METHODS split
      IMPORTING
        iv_total_variance      TYPE i
        iv_price_variance      TYPE i
      RETURNING
        VALUE(rv_qty_variance) TYPE i.

ENDCLASS.


CLASS zcl_alloc_var_total IMPLEMENTATION.

  METHOD variance.
    " The total variance is the actual cost less the standard cost.
    rv_variance = iv_actual_total - iv_standard_total.
  ENDMETHOD.

  METHOD is_adverse.
    " Spending above the standard is adverse.
    rv_ok = xsdbool( iv_actual_total > iv_standard_total ).
  ENDMETHOD.

  METHOD split.
    " What the price does not explain is left to the quantity.
    rv_qty_variance = iv_total_variance - iv_price_variance.
  ENDMETHOD.

ENDCLASS.
