CLASS zcl_allocation_sink_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_allocation_sink.
ENDCLASS.

CLASS zcl_allocation_sink_sap IMPLEMENTATION.
  METHOD zif_allocation_sink~save_allocations.
    DATA ls_allocation TYPE zstockalloc.
    FIELD-SYMBOLS <ls_demand> TYPE zif_stock_allocation=>ty_demand.

    LOOP AT it_demands ASSIGNING <ls_demand>.
      CLEAR ls_allocation.
      ls_allocation-mandt = sy-mandt.
      ls_allocation-matnr = iv_material.
      ls_allocation-werks = iv_plant.
      ls_allocation-order_id = <ls_demand>-order_id.
      ls_allocation-requested = <ls_demand>-requested.
      ls_allocation-allocated = <ls_demand>-allocated.
      ls_allocation-shortage = <ls_demand>-shortage.
      ls_allocation-reservation_id = <ls_demand>-reservation_id.
      MODIFY zstockalloc FROM @ls_allocation.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_stock_allocation.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
