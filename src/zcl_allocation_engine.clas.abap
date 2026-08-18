CLASS zcl_allocation_engine DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    "! <p class="shorttext synchronized">Wire up the engine</p>
    "!
    "! @parameter io_stock_reader | <p class="shorttext synchronized">Source of the available stock</p>
    "! @parameter io_strategy     | <p class="shorttext synchronized">Rule for distributing the stock</p>
    METHODS constructor
      IMPORTING
        io_stock_reader TYPE REF TO zif_stock_reader
        io_strategy     TYPE REF TO zif_allocation_strategy.

    "! <p class="shorttext synchronized">Allocate the stock of one material to competing demand</p>
    "!
    "! The stock of all storage locations of the plant is pooled and handed to
    "! the strategy, which decides who gets what. All demand lines passed in are
    "! expected to be for IV_MATNR in IV_WERKS.
    "!
    "! @parameter iv_matnr      | <p class="shorttext synchronized">Material number</p>
    "! @parameter iv_werks      | <p class="shorttext synchronized">Plant</p>
    "! @parameter it_demand     | <p class="shorttext synchronized">Demand competing for the stock</p>
    "! @parameter rt_allocation | <p class="shorttext synchronized">Confirmed quantity per demand line</p>
    METHODS allocate
      IMPORTING
        iv_matnr             TYPE mard-matnr
        iv_werks             TYPE mard-werks
        it_demand            TYPE zif_allocation=>ty_demand_tab
      RETURNING
        VALUE(rt_allocation) TYPE zif_allocation=>ty_allocation_tab.

  PRIVATE SECTION.
    DATA mo_stock_reader TYPE REF TO zif_stock_reader.
    DATA mo_strategy     TYPE REF TO zif_allocation_strategy.

ENDCLASS.


CLASS zcl_allocation_engine IMPLEMENTATION.

  METHOD constructor.

    mo_stock_reader = io_stock_reader.
    mo_strategy     = io_strategy.

  ENDMETHOD.

  METHOD allocate.

    DATA(lt_stock) = mo_stock_reader->read_available_stock(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    DATA(lv_available) = REDUCE zif_allocation=>ty_quantity(
      INIT lv_sum = CONV zif_allocation=>ty_quantity( 0 )
      FOR ls_stock IN lt_stock
      NEXT lv_sum = lv_sum + ls_stock-available ).

    rt_allocation = mo_strategy->allocate(
      iv_available = lv_available
      it_demand    = it_demand ).

  ENDMETHOD.

ENDCLASS.
