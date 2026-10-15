CLASS zcl_alloc_return_writedown DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS write_down
      IMPORTING
        iv_value        TYPE i
        iv_percent      TYPE i
      RETURNING
        VALUE(rv_write) TYPE i.

    METHODS new_value
      IMPORTING
        iv_value      TYPE i
        iv_percent    TYPE i
      RETURNING
        VALUE(rv_new) TYPE i.

    METHODS loss
      IMPORTING
        iv_value       TYPE i
        iv_new_value   TYPE i
      RETURNING
        VALUE(rv_loss) TYPE i.

ENDCLASS.


CLASS zcl_alloc_return_writedown IMPLEMENTATION.

  METHOD write_down.
    DATA lv_pct TYPE i.

    " The write-down is a share of the value; the share is held between nothing
    " and everything.
    IF iv_value <= 0 OR iv_percent <= 0.
      RETURN.
    ENDIF.

    lv_pct = iv_percent.
    IF lv_pct > 100.
      lv_pct = 100.
    ENDIF.

    rv_write = iv_value * lv_pct DIV 100.
  ENDMETHOD.

  METHOD new_value.
    rv_new = iv_value - write_down( iv_value   = iv_value
                                    iv_percent = iv_percent ).
  ENDMETHOD.

  METHOD loss.
    " The loss is what the write-down took off the value, never below zero.
    IF iv_value <= iv_new_value.
      RETURN.
    ENDIF.

    rv_loss = iv_value - iv_new_value.
  ENDMETHOD.

ENDCLASS.
