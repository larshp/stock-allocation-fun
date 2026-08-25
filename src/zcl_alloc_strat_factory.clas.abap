"! Allocation strategy factory - creates strategy instances by name so
"! callers can pick a strategy from configuration without class references.
CLASS zcl_alloc_strat_factory DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF gc_strategy,
        fifo    TYPE char10 VALUE 'FIFO',
        largest TYPE char10 VALUE 'LARGEST',
      END OF gc_strategy.

    "! Create a strategy instance by name; FIFO is the fallback for
    "! unknown names.
    CLASS-METHODS create
      IMPORTING
        iv_name            TYPE char10
      RETURNING
        VALUE(ro_strategy) TYPE REF TO zif_alloc_strategy.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_alloc_strat_factory IMPLEMENTATION.


  METHOD create.
    CASE iv_name.
      WHEN gc_strategy-largest.
        ro_strategy = NEW zcl_alloc_strat_largest( ).
      WHEN OTHERS.
        ro_strategy = NEW zcl_alloc_strat_fifo( ).
    ENDCASE.
  ENDMETHOD.


ENDCLASS.
