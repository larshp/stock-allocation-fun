CLASS zcl_alloc_margin_pct DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS of_revenue
      IMPORTING
        iv_margin         TYPE i
        iv_revenue        TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS apply
      IMPORTING
        iv_revenue       TYPE i
        iv_percent       TYPE i
      RETURNING
        VALUE(rv_margin) TYPE i.

    METHODS is_improved
      IMPORTING
        iv_old_percent TYPE i
        iv_new_percent TYPE i
      RETURNING
        VALUE(rv_ok)   TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_margin_pct IMPLEMENTATION.

  METHOD of_revenue.
    " The margin as a share of the revenue that carried it.
    IF iv_revenue = 0.
      RETURN.
    ENDIF.

    rv_percent = iv_margin * 100 DIV iv_revenue.
  ENDMETHOD.

  METHOD apply.
    " A margin rate turns a revenue into the margin amount.
    rv_margin = iv_revenue * iv_percent DIV 100.
  ENDMETHOD.

  METHOD is_improved.
    " The margin improved once the new rate beats the old one.
    rv_ok = xsdbool( iv_new_percent > iv_old_percent ).
  ENDMETHOD.

ENDCLASS.
