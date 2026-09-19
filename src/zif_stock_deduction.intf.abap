INTERFACE zif_stock_deduction PUBLIC.

  "! <p class="shorttext synchronized">Quantity of the book stock that is not up for allocation</p>
  "!
  "! One reason why some of what MARD reports cannot be given away. Add an
  "! implementation per reason and hand them to ZCL_STOCK_READER_NET, rather
  "! than growing one class that knows about all of them.
  "!
  "! @parameter iv_matnr    | <p class="shorttext synchronized">Material number</p>
  "! @parameter iv_werks    | <p class="shorttext synchronized">Plant</p>
  "! @parameter rv_quantity | <p class="shorttext synchronized">Quantity to hold back, never negative</p>
  METHODS quantity
    IMPORTING
      iv_matnr           TYPE mard-matnr
      iv_werks           TYPE mard-werks
    RETURNING
      VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity.

ENDINTERFACE.
