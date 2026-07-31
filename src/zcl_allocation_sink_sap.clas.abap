CLASS zcl_allocation_sink_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_allocation_sink.
ENDCLASS.

CLASS zcl_allocation_sink_sap IMPLEMENTATION.
  METHOD zif_allocation_sink~get_allocations.
    SELECT sales_document, sales_item, schedule_line, order_unit,
           order_id,
           requested, allocated, shortage, allocation_status,
           reservation_id,
           reservation_date, reservation_movement_type, reservation_unit
      FROM zstockalloc
      INTO TABLE @rt_demands
      WHERE mandt = @sy-mandt
        AND matnr = @iv_material
        AND werks = @iv_plant
        AND lgort = @iv_storage_location.
    IF sy-subrc <> 0.
      CLEAR rt_demands.
    ENDIF.
  ENDMETHOD.

  METHOD zif_allocation_sink~save_allocations.
    DATA ls_allocation TYPE zstockalloc.
    FIELD-SYMBOLS <ls_demand> TYPE zif_stock_allocation=>ty_demand.

    DELETE FROM zstockalloc
      WHERE mandt = @sy-mandt
        AND matnr = @iv_material
        AND werks = @iv_plant
        AND lgort = @iv_storage_location.

    LOOP AT it_demands ASSIGNING <ls_demand>.
      CLEAR ls_allocation.
      ls_allocation-mandt = sy-mandt.
      ls_allocation-matnr = iv_material.
      ls_allocation-werks = iv_plant.
      ls_allocation-lgort = iv_storage_location.
      ls_allocation-sales_document = <ls_demand>-sales_document.
      ls_allocation-sales_item = <ls_demand>-sales_item.
      ls_allocation-schedule_line = <ls_demand>-schedule_line.
      ls_allocation-order_unit = <ls_demand>-order_unit.
      ls_allocation-order_id = <ls_demand>-order_id.
      ls_allocation-requested = <ls_demand>-requested.
      ls_allocation-allocated = <ls_demand>-allocated.
      ls_allocation-shortage = <ls_demand>-shortage.
      ls_allocation-allocation_status = <ls_demand>-allocation_status.
      ls_allocation-reservation_id = <ls_demand>-reservation_id.
      ls_allocation-reservation_date = <ls_demand>-reservation_date.
      ls_allocation-reservation_movement_type =
        <ls_demand>-reservation_movement_type.
      ls_allocation-reservation_unit = <ls_demand>-reservation_unit.
      MODIFY zstockalloc FROM @ls_allocation.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_stock_allocation.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
