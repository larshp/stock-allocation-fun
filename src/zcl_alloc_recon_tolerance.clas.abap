CLASS zcl_alloc_recon_tolerance DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS within_tolerance
      IMPORTING
        iv_left      TYPE i
        iv_right     TYPE i
        iv_tolerance TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS tolerance
      IMPORTING
        iv_base         TYPE i
        iv_percent      TYPE i
      RETURNING
        VALUE(rv_limit) TYPE i.

    METHODS is_tight
      IMPORTING
        iv_tolerance TYPE i
        iv_limit     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_recon_tolerance IMPLEMENTATION.

  METHOD within_tolerance.
    DATA lv_gap TYPE i.

    " The two sides agree while they sit within the tolerance.
    lv_gap = iv_left - iv_right.
    IF lv_gap < 0.
      lv_gap = -1 * lv_gap.
    ENDIF.

    rv_ok = xsdbool( lv_gap <= iv_tolerance ).
  ENDMETHOD.

  METHOD tolerance.
    " The tolerance is a share of the base amount.
    rv_limit = iv_base * iv_percent DIV 100.
  ENDMETHOD.

  METHOD is_tight.
    " A tolerance is tight once it stays within the limit.
    rv_ok = xsdbool( iv_tolerance <= iv_limit ).
  ENDMETHOD.

ENDCLASS.
