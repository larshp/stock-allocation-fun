INTERFACE zif_stock_reservation PUBLIC.
  TYPES ty_messages TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.
  TYPES: BEGIN OF ty_result,
           reservation TYPE n LENGTH 10,
           simulated   TYPE abap_bool,
           messages    TYPE ty_messages,
         END OF ty_result.
  METHODS create
    IMPORTING allocations   TYPE zif_stock_alloc_types=>ty_allocations
              cost_center   TYPE bapi2093_res_head-cost_ctr
              base_date     TYPE d
              test_run      TYPE abap_bool DEFAULT abap_true
    RETURNING VALUE(result) TYPE ty_result
    RAISING   zcx_stock_alloc.
ENDINTERFACE.
