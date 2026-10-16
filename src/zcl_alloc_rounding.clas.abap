CLASS zcl_alloc_rounding DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS round_to
      IMPORTING
        iv_value        TYPE menge_d
        iv_step         TYPE menge_d
      RETURNING
        VALUE(rv_value) TYPE menge_d.

    METHODS round_up_to
      IMPORTING
        iv_value        TYPE menge_d
        iv_step         TYPE menge_d
      RETURNING
        VALUE(rv_value) TYPE menge_d.

    METHODS round_down_to
      IMPORTING
        iv_value        TYPE menge_d
        iv_step         TYPE menge_d
      RETURNING
        VALUE(rv_value) TYPE menge_d.

ENDCLASS.


CLASS zcl_alloc_rounding IMPLEMENTATION.

  METHOD round_to.
    DATA lv_down TYPE menge_d.

    IF iv_step <= 0.
      rv_value = iv_value.
      RETURN.
    ENDIF.

    lv_down = iv_value DIV iv_step * iv_step.
    IF iv_value - lv_down >= iv_step / 2.
      rv_value = lv_down + iv_step.
    ELSE.
      rv_value = lv_down.
    ENDIF.
  ENDMETHOD.

  METHOD round_up_to.
    IF iv_step <= 0.
      rv_value = iv_value.
      RETURN.
    ENDIF.

    rv_value = iv_value DIV iv_step * iv_step.
    IF rv_value < iv_value.
      rv_value = rv_value + iv_step.
    ENDIF.
  ENDMETHOD.

  METHOD round_down_to.
    IF iv_step <= 0.
      rv_value = iv_value.
      RETURN.
    ENDIF.

    rv_value = iv_value DIV iv_step * iv_step.
  ENDMETHOD.

ENDCLASS.
