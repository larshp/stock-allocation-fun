"! Local helper classes for the unit tests of zcl_stock_allocator.
"! (kept minimal; tests live in zcl_stock_allocator.clas.testclasses.abap)

"! Test strategy: reverse stock order (largest lgort first)
CLASS lcl_reverse_strategy DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_alloc_strategy.
ENDCLASS.

CLASS lcl_reverse_strategy IMPLEMENTATION.


  METHOD zif_alloc_strategy~sort_stock.
    " consume storage locations in descending lgort order
    rt_mard = it_mard.
    SORT rt_mard BY lgort DESCENDING.
  ENDMETHOD.


ENDCLASS.
