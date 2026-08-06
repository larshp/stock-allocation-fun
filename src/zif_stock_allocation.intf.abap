INTERFACE zif_stock_allocation PUBLIC.

  TYPES: BEGIN OF ty_demand,
           material TYPE matnr,
           plant    TYPE werks_d,
           quantity TYPE labst,
         END OF ty_demand.

  TYPES ty_demand_tab TYPE STANDARD TABLE OF ty_demand WITH DEFAULT KEY.

  TYPES: BEGIN OF ty_allocation,
           material TYPE matnr,
           plant    TYPE werks_d,
           quantity TYPE labst,
         END OF ty_allocation.

  TYPES ty_allocation_tab TYPE STANDARD TABLE OF ty_allocation WITH DEFAULT KEY.

  METHODS allocate
    IMPORTING
      it_demand       TYPE ty_demand_tab
      iv_available    TYPE labst
    RETURNING
      VALUE(rt_alloc) TYPE ty_allocation_tab.

ENDINTERFACE.