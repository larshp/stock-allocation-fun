CLASS zcl_supply_extra DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_supply_reader.

    "! <p class="shorttext synchronized">A source of supply that is not there yet</p>
    "!
    "! Everything a plant has, plus one delivery somebody is thinking about.
    "! Nothing writes it anywhere: it exists for the length of one question.
    "!
    "! @parameter io_supply   | <p class="shorttext synchronized">What the plant really has</p>
    "! @parameter iv_matnr    | <p class="shorttext synchronized">Material the extra supply is of</p>
    "! @parameter iv_werks    | <p class="shorttext synchronized">Plant it would land in</p>
    "! @parameter iv_quantity | <p class="shorttext synchronized">How much would land</p>
    "! @parameter iv_date     | <p class="shorttext synchronized">When, empty for on the shelf now</p>
    METHODS constructor
      IMPORTING
        io_supply   TYPE REF TO zif_supply_reader
        iv_matnr    TYPE mard-matnr
        iv_werks    TYPE mard-werks
        iv_quantity TYPE zif_allocation=>ty_quantity
        iv_date     TYPE d OPTIONAL.

  PRIVATE SECTION.

    DATA mo_supply   TYPE REF TO zif_supply_reader.
    DATA mv_matnr    TYPE mard-matnr.
    DATA mv_werks    TYPE mard-werks.
    DATA mv_quantity TYPE zif_allocation=>ty_quantity.
    DATA mv_date     TYPE d.

ENDCLASS.


CLASS zcl_supply_extra IMPLEMENTATION.

  METHOD constructor.

    mo_supply   = io_supply.
    mv_matnr    = iv_matnr.
    mv_werks    = iv_werks.
    mv_quantity = iv_quantity.
    mv_date     = iv_date.

  ENDMETHOD.

  METHOD zif_supply_reader~read_supply.

    rt_supply = mo_supply->read_supply(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    " the extra delivery is of one material in one plant, and a run over the
    " rest of the plant must not find it
    IF iv_matnr <> mv_matnr OR iv_werks <> mv_werks OR mv_quantity <= 0.
      RETURN.
    ENDIF.

    APPEND VALUE #(
      avail_date = mv_date
      quantity   = mv_quantity ) TO rt_supply.

  ENDMETHOD.

ENDCLASS.
