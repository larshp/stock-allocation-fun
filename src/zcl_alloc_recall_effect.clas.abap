CLASS zcl_alloc_recall_effect DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS rate
      IMPORTING
        iv_expected   TYPE i
        iv_recovered  TYPE i
      RETURNING
        VALUE(rv_pct) TYPE i.

    METHODS is_effective
      IMPORTING
        iv_pct       TYPE i
        iv_target    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS outstanding
      IMPORTING
        iv_expected   TYPE i
        iv_recovered  TYPE i
      RETURNING
        VALUE(rv_qty) TYPE i.

ENDCLASS.


CLASS zcl_alloc_recall_effect IMPLEMENTATION.

  METHOD rate.
    " The effectiveness rate is the recovered share of the recall.
    IF iv_expected <= 0 OR iv_recovered <= 0.
      RETURN.
    ENDIF.

    rv_pct = iv_recovered * 100 DIV iv_expected.
  ENDMETHOD.

  METHOD is_effective.
    rv_ok = xsdbool( iv_target > 0 AND iv_pct >= iv_target ).
  ENDMETHOD.

  METHOD outstanding.
    " The quantity still to recover never goes below zero.
    IF iv_expected <= 0 OR iv_recovered >= iv_expected.
      RETURN.
    ENDIF.

    rv_qty = iv_expected - iv_recovered.
  ENDMETHOD.

ENDCLASS.
