CLASS zcl_alloc_recon_rate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS rate
      IMPORTING
        iv_matched     TYPE i
        iv_total       TYPE i
      RETURNING
        VALUE(rv_rate) TYPE i.

    METHODS matched_percent
      IMPORTING
        iv_matched        TYPE i
        iv_total          TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS is_clean
      IMPORTING
        iv_matched   TYPE i
        iv_total     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_recon_rate IMPLEMENTATION.

  METHOD rate.
    " The rate is the share of the items that matched, per hundred.
    IF iv_total = 0.
      RETURN.
    ENDIF.

    rv_rate = iv_matched * 100 DIV iv_total.
  ENDMETHOD.

  METHOD matched_percent.
    " The matched share of the whole, per hundred.
    IF iv_total = 0.
      RETURN.
    ENDIF.

    rv_percent = iv_matched * 100 DIV iv_total.
  ENDMETHOD.

  METHOD is_clean.
    " The reconciliation is clean once every item matched.
    rv_ok = xsdbool( iv_matched >= iv_total ).
  ENDMETHOD.

ENDCLASS.
