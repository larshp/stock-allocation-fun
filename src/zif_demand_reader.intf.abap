INTERFACE zif_demand_reader PUBLIC.

  TYPES ty_matnr_tab TYPE STANDARD TABLE OF mard-matnr WITH EMPTY KEY.

  "! <p class="shorttext synchronized">Materials in a plant that are waiting for stock</p>
  "!
  "! What a run over a whole plant has to cover. This is the candidate list:
  "! a material is left out when it plainly has nothing waiting, but whether
  "! anything is really left to serve is decided by READ_OPEN_DEMAND. A
  "! material whose demand has all been delivered or served can still be
  "! listed, and then comes back with no demand lines.
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
  "! @parameter rt_demand      | <p class="shorttext synchronized">Open demand</p>
  "! @raising   zcx_allocation | <p class="shorttext synchronized">Demand could not be read</p>
  METHODS read_open_demand
    IMPORTING
      iv_matnr         TYPE mard-matnr
      iv_werks         TYPE mard-werks
    RETURNING
      VALUE(rt_demand) TYPE zif_allocation=>ty_demand_tab
    RAISING
      zcx_allocation.

ENDINTERFACE.
