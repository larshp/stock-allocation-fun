CLASS zcl_stock_in_locations DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_stock_reader.

    TYPES ty_lgort_tab TYPE STANDARD TABLE OF mard-lgort WITH EMPTY KEY.

    "! <p class="shorttext synchronized">Allocate only from certain storage locations</p>
    "!
    "! Not every storage location of a plant holds stock that may be given away:
    "! returns, a shipping area, a location a customer owns. Which ones count is
    "! a decision about the plant, so it is a list rather than a rule, and an
    "! empty list means every location counts.
    "!
    "! @parameter io_stock | <p class="shorttext synchronized">Reader of the stock per storage location</p>
    "! @parameter it_lgort | <p class="shorttext synchronized">Locations to allocate from, all if empty</p>
    METHODS constructor
      IMPORTING
        io_stock TYPE REF TO zif_stock_reader
        it_lgort TYPE ty_lgort_tab OPTIONAL.

  PRIVATE SECTION.
    DATA mo_stock TYPE REF TO zif_stock_reader.
    DATA mt_lgort TYPE ty_lgort_tab.

ENDCLASS.


CLASS zcl_stock_in_locations IMPLEMENTATION.

  METHOD constructor.

    mo_stock = io_stock.
    mt_lgort = it_lgort.

  ENDMETHOD.

  METHOD zif_stock_reader~read_available_stock.

    DATA lt_kept TYPE zif_stock_reader=>ty_stock_line_tab.

    rt_stock = mo_stock->read_available_stock(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    " no list is no restriction rather than nothing allowed: a plant that has
    " not said which locations to use means all of them
    IF mt_lgort IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT rt_stock INTO DATA(ls_stock).
      IF line_exists( mt_lgort[ table_line = ls_stock-lgort ] ).
        APPEND ls_stock TO lt_kept.
      ENDIF.
    ENDLOOP.

    rt_stock = lt_kept.

  ENDMETHOD.

ENDCLASS.
