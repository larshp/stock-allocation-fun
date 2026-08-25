"! Allocation strategy: consume storage locations with the largest free
"! stock first. Fewer locations are touched per order item.
CLASS zcl_alloc_strat_largest DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_alloc_strategy.
ENDCLASS.

CLASS zcl_alloc_strat_largest IMPLEMENTATION.


  METHOD zif_alloc_strategy~sort_stock.
    rt_mard = it_mard.
    SORT rt_mard BY labst DESCENDING.
  ENDMETHOD.


ENDCLASS.
