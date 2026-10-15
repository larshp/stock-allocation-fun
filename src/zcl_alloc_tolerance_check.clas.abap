CLASS zcl_alloc_tolerance_check DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS deviation_percent
      IMPORTING
        iv_ordered    TYPE i
        iv_delivered  TYPE i
      RETURNING
        VALUE(rv_pct) TYPE i.

    METHODS within_tolerance
      IMPORTING
        iv_ordered       TYPE i
        iv_delivered     TYPE i
        iv_under_percent TYPE i
        iv_over_percent  TYPE i
      RETURNING
        VALUE(rv_ok)     TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_tolerance_check IMPLEMENTATION.

  METHOD deviation_percent.
    IF iv_ordered <= 0.
      RETURN.
    ENDIF.

    " The deviation is signed and rounded towards zero, so a small under
    " delivery can read as a zero deviation.
    rv_pct = ( iv_delivered - iv_ordered ) * 100 DIV iv_ordered.
  ENDMETHOD.

  METHOD within_tolerance.
    DATA lv_dev TYPE i.

    IF iv_ordered <= 0 OR iv_under_percent < 0 OR iv_over_percent < 0.
      RETURN.
    ENDIF.

    lv_dev = deviation_percent( iv_ordered   = iv_ordered
                                iv_delivered = iv_delivered ).

    IF lv_dev < 0.
      rv_ok = xsdbool( 0 - lv_dev <= iv_under_percent ).
    ELSEIF lv_dev > 0.
      rv_ok = xsdbool( lv_dev <= iv_over_percent ).
    ELSE.
      rv_ok = abap_true.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
