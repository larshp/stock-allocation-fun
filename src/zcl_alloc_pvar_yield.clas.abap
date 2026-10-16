CLASS zcl_alloc_pvar_yield DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS yield_variance
      IMPORTING
        iv_standard_qty    TYPE i
        iv_actual_qty      TYPE i
        iv_standard_price  TYPE i
      RETURNING
        VALUE(rv_variance) TYPE i.

    METHODS is_adverse
      IMPORTING
        iv_variance  TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS percent
      IMPORTING
        iv_variance       TYPE i
        iv_standard_cost  TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

ENDCLASS.


CLASS zcl_alloc_pvar_yield IMPLEMENTATION.

  METHOD yield_variance.
    DATA lv_diff TYPE i.

    " A yield variance is the shortfall in output at the standard price.
    lv_diff = iv_standard_qty - iv_actual_qty.
    rv_variance = lv_diff * iv_standard_price.
  ENDMETHOD.

  METHOD is_adverse.
    " The variance is adverse once it costs more than planned.
    rv_ok = xsdbool( iv_variance > 0 ).
  ENDMETHOD.

  METHOD percent.
    " The variance as a share of the standard cost.
    IF iv_standard_cost = 0.
      RETURN.
    ENDIF.

    rv_percent = iv_variance * 100 DIV iv_standard_cost.
  ENDMETHOD.

ENDCLASS.
