INTERFACE zif_demand_reader PUBLIC.

  "! <p class="shorttext synchronized">Read the open demand for a material in a plant</p>
  "!
  "! Only demand that still needs stock is returned; rejected, blocked or
  "! otherwise closed requirements are filtered out by the implementation.
  "!
  "! @parameter iv_matnr  | <p class="shorttext synchronized">Material number</p>
  "! @parameter iv_werks  | <p class="shorttext synchronized">Plant</p>
  "! @parameter rt_demand | <p class="shorttext synchronized">Open demand</p>
  METHODS read_open_demand
    IMPORTING
      iv_matnr         TYPE mard-matnr
      iv_werks         TYPE mard-werks
    RETURNING
      VALUE(rt_demand) TYPE zif_allocation=>ty_demand_tab.

ENDINTERFACE.
