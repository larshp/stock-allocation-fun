CLASS zcl_allocation_sink_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_allocation_sink.
ENDCLASS.

CLASS zcl_allocation_sink_sap IMPLEMENTATION.
  METHOD zif_allocation_sink~save_allocations.
    FIELD-SYMBOLS <ls_demand> TYPE zif_stock_allocation=>ty_demand.

    LOOP AT it_demands ASSIGNING <ls_demand>.
      IF <ls_demand>-allocated < 0.
        RAISE EXCEPTION TYPE zcx_stock_allocation.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
