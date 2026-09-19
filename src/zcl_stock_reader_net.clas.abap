CLASS zcl_stock_reader_net DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_stock_reader.

    TYPES ty_deduction_tab TYPE STANDARD TABLE OF REF TO zif_stock_deduction WITH EMPTY KEY.

    "! <p class="shorttext synchronized">Wrap a stock reader with what may not be allocated</p>
    "!
    "! @parameter io_stock     | <p class="shorttext synchronized">Reader of the book stock</p>
    "! @parameter it_deduction | <p class="shorttext synchronized">Reasons stock is held back</p>
    METHODS constructor
      IMPORTING
        io_stock     TYPE REF TO zif_stock_reader
        it_deduction TYPE ty_deduction_tab.

  PRIVATE SECTION.

    DATA mo_stock     TYPE REF TO zif_stock_reader.
    DATA mt_deduction TYPE ty_deduction_tab.

    METHODS held_back
      IMPORTING
        iv_matnr           TYPE mard-matnr
        iv_werks           TYPE mard-werks
      RETURNING
        VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity.

ENDCLASS.


CLASS zcl_stock_reader_net IMPLEMENTATION.

  METHOD constructor.

    mo_stock     = io_stock.
    mt_deduction = it_deduction.

  ENDMETHOD.

  METHOD zif_stock_reader~read_available_stock.

    rt_stock = mo_stock->read_available_stock(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    DATA(lv_held_back) = held_back(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    " none of the deductions is tied to the storage location the stock would
    " have come from, so they are taken off in storage location order. What
    " matters is that the plant total comes out right, and it is the total the
    " allocation engine works with.
    LOOP AT rt_stock ASSIGNING FIELD-SYMBOL(<ls_stock>).
      DATA(lv_take) = COND zif_allocation=>ty_quantity(
        WHEN <ls_stock>-available > lv_held_back
        THEN lv_held_back
        ELSE <ls_stock>-available ).
      IF lv_take > 0.
        <ls_stock>-available = <ls_stock>-available - lv_take.
        lv_held_back = lv_held_back - lv_take.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD held_back.

    LOOP AT mt_deduction INTO DATA(lo_deduction).
      DATA(lv_quantity) = lo_deduction->quantity(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ).
      IF lv_quantity > 0.
        rv_quantity = rv_quantity + lv_quantity.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
