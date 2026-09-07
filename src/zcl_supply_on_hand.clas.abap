CLASS zcl_supply_on_hand DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_supply_reader.

    "! <p class="shorttext synchronized">Read the stock on the shelf as supply available now</p>
    "!
    "! @parameter io_stock | <p class="shorttext synchronized">Source of the available stock</p>
    METHODS constructor
      IMPORTING
        io_stock TYPE REF TO zif_stock_reader.

  PRIVATE SECTION.
    DATA mo_stock TYPE REF TO zif_stock_reader.

ENDCLASS.


CLASS zcl_supply_on_hand IMPLEMENTATION.

  METHOD constructor.
    mo_stock = io_stock.
  ENDMETHOD.

  METHOD zif_supply_reader~read_supply.

    DATA(lt_stock) = mo_stock->read_available_stock(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    " the storage locations of a plant are one pool, as they have been since
    " the engine first added them up
    DATA(lv_available) = REDUCE zif_allocation=>ty_quantity(
      INIT lv_sum = CONV zif_allocation=>ty_quantity( 0 )
      FOR ls_stock IN lt_stock
      NEXT lv_sum = lv_sum + ls_stock-available ).

    IF lv_available <= 0.
      RETURN.
    ENDIF.

    " no date: what is on the shelf has been there since before any
    " requirement was raised, so it can serve demand of any date. Dating it
    " today would leave an overdue line unservable from stock that is there.
    APPEND VALUE #( quantity = lv_available ) TO rt_supply.

  ENDMETHOD.

ENDCLASS.
