CLASS zcl_deduct_reservations DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_stock_deduction.

  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_reserved,
        rsnum       TYPE resb-rsnum,
        rspos       TYPE resb-rspos,
        requirement TYPE resb-bdmng,
        withdrawn   TYPE resb-enmng,
      END OF ty_reserved.
    TYPES ty_reserved_tab TYPE STANDARD TABLE OF ty_reserved WITH EMPTY KEY.

ENDCLASS.


CLASS zcl_deduct_reservations IMPLEMENTATION.

  METHOD zif_stock_deduction~quantity.

    DATA lt_reserved TYPE ty_reserved_tab.
    " typed explicitly: an inline DATA() here loses the decimal places and
    " silently rounds the quantity, see ANOMALIES.md
    DATA lv_open TYPE zif_allocation=>ty_quantity.

    " what is still outstanding is the requirement less what has already been
    " withdrawn; deleted items reserve nothing.
    " The open quantities are added up in ABAP rather than with SUM( ) and a
    " GROUP BY, see ANOMALIES.md.
    SELECT rsnum,
           rspos,
           bdmng AS requirement,
           enmng AS withdrawn
      FROM resb
      WHERE matnr = @iv_matnr
        AND werks = @iv_werks
        AND xloek = @space
      ORDER BY rsnum, rspos
      INTO TABLE @lt_reserved.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT lt_reserved INTO DATA(ls_reserved).
      lv_open = ls_reserved-requirement - ls_reserved-withdrawn.
      IF lv_open > 0.
        rv_quantity = rv_quantity + lv_open.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
