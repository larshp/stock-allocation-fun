CLASS zcl_alloc_percent DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS ratio
      IMPORTING
        iv_part       TYPE menge_d
        iv_total      TYPE menge_d
      RETURNING
        VALUE(rv_pct) TYPE i.

    METHODS apply
      IMPORTING
        iv_pct          TYPE i
        iv_base         TYPE menge_d
      RETURNING
        VALUE(rv_value) TYPE menge_d.

    METHODS format
      IMPORTING
        iv_pct         TYPE i
      RETURNING
        VALUE(rv_text) TYPE string.

ENDCLASS.


CLASS zcl_alloc_percent IMPLEMENTATION.

  METHOD ratio.
    IF iv_total <= 0.
      rv_pct = 0.
      RETURN.
    ENDIF.
    rv_pct = iv_part * 100 DIV iv_total.
  ENDMETHOD.

  METHOD apply.
    rv_value = iv_base * iv_pct / 100.
  ENDMETHOD.

  METHOD format.
    rv_text = |{ iv_pct } %|.
  ENDMETHOD.

ENDCLASS.
