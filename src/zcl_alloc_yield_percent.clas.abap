CLASS zcl_alloc_yield_percent DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS yield_percent
      IMPORTING
        iv_good           TYPE i
        iv_total          TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS is_full
      IMPORTING
        iv_percent   TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS loss
      IMPORTING
        iv_good        TYPE i
        iv_total       TYPE i
      RETURNING
        VALUE(rv_loss) TYPE i.

ENDCLASS.


CLASS zcl_alloc_yield_percent IMPLEMENTATION.

  METHOD yield_percent.
    " The yield is the good quantity as a share of the whole.
    IF iv_total = 0.
      RETURN.
    ENDIF.

    rv_percent = iv_good * 100 DIV iv_total.
  ENDMETHOD.

  METHOD is_full.
    " The yield is full once every unit came out good.
    rv_ok = xsdbool( iv_percent >= 100 ).
  ENDMETHOD.

  METHOD loss.
    " The loss is what is left of the total after the good units.
    IF iv_good >= iv_total.
      RETURN.
    ENDIF.

    rv_loss = iv_total - iv_good.
  ENDMETHOD.

ENDCLASS.
