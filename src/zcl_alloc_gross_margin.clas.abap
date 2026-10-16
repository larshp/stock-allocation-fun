CLASS zcl_alloc_gross_margin DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS margin
      IMPORTING
        iv_revenue       TYPE i
        iv_cogs          TYPE i
      RETURNING
        VALUE(rv_margin) TYPE i.

    METHODS margin_percent
      IMPORTING
        iv_revenue        TYPE i
        iv_cogs           TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS is_positive
      IMPORTING
        iv_revenue   TYPE i
        iv_cogs      TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_gross_margin IMPLEMENTATION.

  METHOD margin.
    " The gross margin is what the revenue leaves after the cost of goods.
    rv_margin = iv_revenue - iv_cogs.
  ENDMETHOD.

  METHOD margin_percent.
    DATA lv_margin TYPE i.

    " The margin is related to the revenue that carried it.
    IF iv_revenue = 0.
      RETURN.
    ENDIF.

    lv_margin = iv_revenue - iv_cogs.
    rv_percent = lv_margin * 100 DIV iv_revenue.
  ENDMETHOD.

  METHOD is_positive.
    " The margin is positive once the revenue beats the cost of goods.
    rv_ok = xsdbool( iv_revenue > iv_cogs ).
  ENDMETHOD.

ENDCLASS.
