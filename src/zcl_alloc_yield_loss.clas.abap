CLASS zcl_alloc_yield_loss DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS loss
      IMPORTING
        iv_good        TYPE i
        iv_total       TYPE i
      RETURNING
        VALUE(rv_loss) TYPE i.

    METHODS is_lossy
      IMPORTING
        iv_loss      TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS loss_percent
      IMPORTING
        iv_good           TYPE i
        iv_total          TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

ENDCLASS.


CLASS zcl_alloc_yield_loss IMPLEMENTATION.

  METHOD loss.
    " The loss is what is left of the total after the good units.
    IF iv_good >= iv_total.
      RETURN.
    ENDIF.

    rv_loss = iv_total - iv_good.
  ENDMETHOD.

  METHOD is_lossy.
    " The order is lossy once any quantity is lost.
    rv_ok = xsdbool( iv_loss > 0 ).
  ENDMETHOD.

  METHOD loss_percent.
    DATA lv_loss TYPE i.

    " The loss as a share of the whole.
    IF iv_total = 0.
      RETURN.
    ENDIF.

    lv_loss = iv_total - iv_good.
    rv_percent = lv_loss * 100 DIV iv_total.
  ENDMETHOD.

ENDCLASS.
