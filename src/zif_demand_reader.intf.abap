INTERFACE zif_demand_reader PUBLIC.

  TYPES ty_matnr_tab TYPE STANDARD TABLE OF mard-matnr WITH EMPTY KEY.

  "! <p class="shorttext synchronized">Materials in a plant that are waiting for stock</p>
  "!
  "! What a run over a whole plant has to cover. Same filtering as
  "! READ_OPEN_DEMAND, so a material only appears if it would get demand lines.
  "!
  "! @parameter iv_werks | <p class="shorttext synchronized">Plant</p>
  "! @parameter rt_matnr | <p class="shorttext synchronized">Material numbers, no duplicates</p>
  METHODS materials_with_demand
    IMPORTING
      iv_werks        TYPE mard-werks
    RETURNING
      VALUE(rt_matnr) TYPE ty_matnr_tab.

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
