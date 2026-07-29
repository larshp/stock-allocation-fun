CLASS zcl_allocation_sink_sap DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_allocation_sink.
ENDCLASS.

CLASS zcl_allocation_sink_sap IMPLEMENTATION.
  METHOD zif_allocation_sink~save.
    DELETE FROM zstockalloc
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND lgort = @iv_storage_location.

    LOOP AT it_allocations INTO DATA(ls_allocation).
      DATA(ls_persisted) = VALUE zstockalloc(
        matnr = iv_material
        werks = iv_plant
        lgort = iv_storage_location
        vbeln = ls_allocation-sales_order
        posnr = ls_allocation-sales_item
        etenr = ls_allocation-schedule_line
        mbdat = ls_allocation-delivery_date
        priority = ls_allocation-priority
        req_qty = ls_allocation-requested_qty
        alloc_qty = ls_allocation-allocated_qty
        short_qty = ls_allocation-shortage_qty
        reserve_qty = ls_allocation-reserve_qty
        meins = ls_allocation-unit
        created_on = sy-datum
        created_at = sy-uzeit
        created_by = sy-uname
        alloc_status = ls_allocation-status ).
      MODIFY zstockalloc FROM @ls_persisted.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
