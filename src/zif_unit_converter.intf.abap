INTERFACE zif_unit_converter PUBLIC.

  "! <p class="shorttext synchronized">Convert a quantity into the base unit of measure</p>
  "!
  "! Stock is kept in the base unit, demand is not necessarily. A quantity that
  "! has not been converted cannot be compared with stock at all, so a missing
  "! conversion is an error rather than a factor of one.
  "!
  "! @parameter iv_matnr       | <p class="shorttext synchronized">Material number</p>
  "! @parameter iv_quantity    | <p class="shorttext synchronized">Quantity in IV_UOM</p>
  "! @parameter iv_uom         | <p class="shorttext synchronized">Unit of the quantity</p>
  "! @parameter rv_quantity    | <p class="shorttext synchronized">Same quantity in the base unit</p>
  "! @raising   zcx_allocation | <p class="shorttext synchronized">No conversion is defined</p>
  METHODS to_base
    IMPORTING
      iv_matnr           TYPE mard-matnr
      iv_quantity        TYPE zif_allocation=>ty_quantity
      iv_uom             TYPE marm-meinh
    RETURNING
      VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity
    RAISING
      zcx_allocation.

  "! <p class="shorttext synchronized">The unit a material's stock is kept in</p>
  "!
  "! Everything this solution counts is in the base unit, and a report that
  "! prints "40 short" without it is asking a planner to remember which
  "! material is in kilos. The converter already has the material master in
  "! its hand, so asking it costs nothing.
  "!
  "! @parameter iv_matnr       | <p class="shorttext synchronized">Material number</p>
  "! @parameter rv_uom         | <p class="shorttext synchronized">Base unit of measure</p>
  "! @raising   zcx_allocation | <p class="shorttext synchronized">No such material</p>
  METHODS base_unit
    IMPORTING
      iv_matnr      TYPE mard-matnr
    RETURNING
      VALUE(rv_uom) TYPE mara-meins
    RAISING
      zcx_allocation.

ENDINTERFACE.
