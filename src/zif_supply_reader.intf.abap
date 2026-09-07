INTERFACE zif_supply_reader PUBLIC.

  "! A quantity that can be allocated, and the day it can be allocated from.
  "!
  "! AVAIL_DATE is initial for stock that is already on the shelf: it has been
  "! there since before any requirement was raised, so it can serve demand of
  "! any date, including a line that is already overdue. A receipt carries the
  "! day it arrives and can only serve demand wanted on or after it.
  TYPES:
    BEGIN OF ty_supply,
      avail_date TYPE d,
      quantity   TYPE zif_allocation=>ty_quantity,
    END OF ty_supply.
  TYPES ty_supply_tab TYPE STANDARD TABLE OF ty_supply WITH EMPTY KEY.

  "! <p class="shorttext synchronized">Read what a material has to allocate, and from when</p>
  "!
  "! Everything that adds to what can be given away, one implementation per
  "! kind of supply, composed with ZCL_SUPPLY_SOURCES. Quantities are in the
  "! base unit of measure.
  "!
  "! @parameter iv_matnr  | <p class="shorttext synchronized">Material number</p>
  "! @parameter iv_werks  | <p class="shorttext synchronized">Plant</p>
  "! @parameter rt_supply | <p class="shorttext synchronized">Quantity per availability date</p>
  "! @raising   zcx_allocation | <p class="shorttext synchronized">Supply could not be read</p>
  METHODS read_supply
    IMPORTING
      iv_matnr         TYPE mard-matnr
      iv_werks         TYPE mard-werks
    RETURNING
      VALUE(rt_supply) TYPE ty_supply_tab
    RAISING
      zcx_allocation.

ENDINTERFACE.
