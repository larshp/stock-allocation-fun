CLASS zcl_alloc_contrib_margin DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS contribution
      IMPORTING
        iv_revenue        TYPE i
        iv_variable_cost  TYPE i
      RETURNING
        VALUE(rv_contrib) TYPE i.

    METHODS ratio
      IMPORTING
        iv_revenue       TYPE i
        iv_variable_cost TYPE i
      RETURNING
        VALUE(rv_ratio)  TYPE i.

    METHODS covers_fixed
      IMPORTING
        iv_revenue       TYPE i
        iv_variable_cost TYPE i
        iv_fixed_cost    TYPE i
      RETURNING
        VALUE(rv_ok)     TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_contrib_margin IMPLEMENTATION.

  METHOD contribution.
    " The contribution margin is what is left after the variable cost.
    rv_contrib = iv_revenue - iv_variable_cost.
  ENDMETHOD.

  METHOD ratio.
    DATA lv_contrib TYPE i.

    " The ratio is the contribution related to the revenue.
    IF iv_revenue = 0.
      RETURN.
    ENDIF.

    lv_contrib = iv_revenue - iv_variable_cost.
    rv_ratio = lv_contrib * 100 DIV iv_revenue.
  ENDMETHOD.

  METHOD covers_fixed.
    DATA lv_contrib TYPE i.

    " The contribution covers the fixed cost once it reaches it.
    lv_contrib = iv_revenue - iv_variable_cost.
    rv_ok = xsdbool( lv_contrib >= iv_fixed_cost ).
  ENDMETHOD.

ENDCLASS.
