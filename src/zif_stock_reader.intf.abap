INTERFACE zif_stock_reader PUBLIC.

  TYPES:
    BEGIN OF ty_stock_line,
      matnr     TYPE mard-matnr,
      werks     TYPE mard-werks,
      lgort     TYPE mard-lgort,
      available TYPE mard-labst,
    END OF ty_stock_line.

  TYPES ty_stock_line_tab TYPE STANDARD TABLE OF ty_stock_line WITH EMPTY KEY.

  "! <p class="shorttext synchronized">Read unrestricted-use stock of a material in a plant</p>
  "!
  "! @parameter iv_matnr | <p class="shorttext synchronized">Material number</p>
  "! @parameter iv_werks | <p class="shorttext synchronized">Plant</p>
  "! @parameter rt_stock | <p class="shorttext synchronized">Stock per storage location</p>
  METHODS read_available_stock
    IMPORTING
      iv_matnr        TYPE mard-matnr
      iv_werks        TYPE mard-werks
    RETURNING
      VALUE(rt_stock) TYPE ty_stock_line_tab.

ENDINTERFACE.
