INTERFACE zif_allocation_strategy PUBLIC.

  "! <p class="shorttext synchronized">Distribute available stock over competing demand</p>
  "!
  "! Every demand line passed in is answered by exactly one allocation line.
  "! The order of the result is the order in which the strategy served the
  "! demand, which is not necessarily the order it was passed in.
  "!
  "! @parameter it_demand     | <p class="shorttext synchronized">Demand competing for the stock</p>
  "! @parameter iv_available  | <p class="shorttext synchronized">Quantity available for allocation</p>
  "! @parameter rt_allocation | <p class="shorttext synchronized">Confirmed quantity per demand line</p>
  METHODS allocate
    IMPORTING
      iv_available         TYPE zif_allocation=>ty_quantity
      it_demand            TYPE zif_allocation=>ty_demand_tab
    RETURNING
      VALUE(rt_allocation) TYPE zif_allocation=>ty_allocation_tab.

ENDINTERFACE.
