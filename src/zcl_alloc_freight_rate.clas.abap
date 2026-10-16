CLASS zcl_alloc_freight_rate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS per_unit
      IMPORTING
        iv_total_cents  TYPE i
        iv_quantity     TYPE i
      RETURNING
        VALUE(rv_cents) TYPE i.

    METHODS total
      IMPORTING
        iv_base_cents     TYPE i
        iv_per_unit_cents TYPE i
        iv_quantity       TYPE i
      RETURNING
        VALUE(rv_cents)   TYPE i.

    METHODS surcharge
      IMPORTING
        iv_cents        TYPE i
        iv_percent      TYPE i
      RETURNING
        VALUE(rv_cents) TYPE i.

ENDCLASS.


CLASS zcl_alloc_freight_rate IMPLEMENTATION.

  METHOD per_unit.
    " Money is handled in whole cents throughout the repository, so the rounding
    " is an integer division and is always down.
    IF iv_total_cents <= 0 OR iv_quantity <= 0.
      RETURN.
    ENDIF.

    rv_cents = iv_total_cents DIV iv_quantity.
  ENDMETHOD.

  METHOD total.
    IF iv_base_cents < 0 OR iv_per_unit_cents < 0 OR iv_quantity < 0.
      RETURN.
    ENDIF.

    rv_cents = iv_base_cents + iv_per_unit_cents * iv_quantity.
  ENDMETHOD.

  METHOD surcharge.
    IF iv_cents <= 0 OR iv_percent <= 0.
      RETURN.
    ENDIF.

    rv_cents = iv_cents * iv_percent DIV 100.
  ENDMETHOD.

ENDCLASS.
