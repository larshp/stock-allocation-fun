CLASS zcl_stock_reader_net DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_stock_reader.

    "! <p class="shorttext synchronized">Wrap a stock reader with the reservations against it</p>
    "!
    "! @parameter io_stock | <p class="shorttext synchronized">Reader of the book stock</p>
    METHODS constructor
      IMPORTING
        io_stock TYPE REF TO zif_stock_reader.

  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_reserved,
        rsnum       TYPE resb-rsnum,
        rspos       TYPE resb-rspos,
        requirement TYPE resb-bdmng,
        withdrawn   TYPE resb-enmng,
      END OF ty_reserved.
    TYPES ty_reserved_tab TYPE STANDARD TABLE OF ty_reserved WITH EMPTY KEY.

    DATA mo_stock TYPE REF TO zif_stock_reader.

    METHODS open_reservation
      IMPORTING
        iv_matnr           TYPE mard-matnr
        iv_werks           TYPE mard-werks
      RETURNING
        VALUE(rv_reserved) TYPE zif_allocation=>ty_quantity.

ENDCLASS.


CLASS zcl_stock_reader_net IMPLEMENTATION.

  METHOD constructor.
    mo_stock = io_stock.
  ENDMETHOD.

  METHOD zif_stock_reader~read_available_stock.

    rt_stock = mo_stock->read_available_stock(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    DATA(lv_reserved) = open_reservation(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    " reservations are not tied to the storage location they will be taken
    " from, so they are consumed in storage location order. What matters is
    " that the plant total comes out right, and it is the total the allocation
    " engine works with.
    LOOP AT rt_stock ASSIGNING FIELD-SYMBOL(<ls_stock>).
      DATA(lv_take) = COND zif_allocation=>ty_quantity(
        WHEN <ls_stock>-available > lv_reserved
        THEN lv_reserved
        ELSE <ls_stock>-available ).
      IF lv_take > 0.
        <ls_stock>-available = <ls_stock>-available - lv_take.
        lv_reserved = lv_reserved - lv_take.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD open_reservation.

    DATA lt_reserved TYPE ty_reserved_tab.

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
      DATA(lv_open) = ls_reserved-requirement - ls_reserved-withdrawn.
      IF lv_open > 0.
        rv_reserved = rv_reserved + lv_open.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
