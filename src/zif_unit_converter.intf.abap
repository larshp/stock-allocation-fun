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

  "! <p class="shorttext synchronized">Convert a quantity out of the base unit of measure</p>
  "!
  "! The way back, for a quantity that has to be written onto a document rather
  "! than compared with stock: a sales order line ordered in cartons is
  "! confirmed in cartons, and a confirmation in pieces put on it would be a
  "! twelvefold promise. It is the inverse of TO_BASE and refuses whatever
  "! TO_BASE refuses, so a caller that could read a quantity can write it back.
  "!
  "! It does not round. Five pieces of a material sold in cartons of twelve are
  "! not a whole number of cartons, and a solution that quietly made them one
  "! would either promise more than it has or less than it decided. A plant
  "! that cannot live with a fraction on the document is a plant that wants
  "! whole order units, which is a rule of its own and is applied before this.
  "!
  "! @parameter iv_matnr       | <p class="shorttext synchronized">Material number</p>
  "! @parameter iv_quantity    | <p class="shorttext synchronized">Quantity in the base unit</p>
  "! @parameter iv_uom         | <p class="shorttext synchronized">Unit to convert it to</p>
  "! @parameter rv_quantity    | <p class="shorttext synchronized">Same quantity in IV_UOM</p>
  "! @raising   zcx_allocation | <p class="shorttext synchronized">No conversion is defined</p>
  METHODS from_base
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
