"! Allocation strategy: consume storage locations in insertion order
"! (as read from MARD). This is the default behavior.
CLASS zcl_alloc_strat_fifo DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_alloc_strategy.
ENDCLASS.

CLASS zcl_alloc_strat_fifo IMPLEMENTATION.


  METHOD zif_alloc_strategy~sort_stock.
    " keep the original order
    rt_mard = it_mard.
  ENDMETHOD.


ENDCLASS.
