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

    DATA(lv_created_on) = sy-datum.
    DATA(lv_created_at) = sy-uzeit.
    DATA(lv_created_by) = sy-uname.
    DATA lt_persisted TYPE STANDARD TABLE OF zstockalloc WITH EMPTY KEY.
    LOOP AT it_allocations INTO DATA(ls_allocation).
      APPEND VALUE zstockalloc(
        matnr        = iv_material
        werks        = iv_plant
        lgort        = iv_storage_location
        vbeln        = ls_allocation-sales_order
        posnr        = ls_allocation-sales_item
        etenr        = ls_allocation-schedule_line
        mbdat        = ls_allocation-delivery_date
        priority     = ls_allocation-priority
        req_qty      = ls_allocation-requested_qty
        alloc_qty    = ls_allocation-allocated_qty
        short_qty    = ls_allocation-shortage_qty
        reserve_qty  = ls_allocation-reserve_qty
        meins        = ls_allocation-unit
        strategy     = ls_allocation-strategy
        cutoff_date  = ls_allocation-cutoff_date
        created_on   = lv_created_on
        created_at   = lv_created_at
        created_by   = lv_created_by
        alloc_status = ls_allocation-status ) TO lt_persisted.
    ENDLOOP.

    IF lt_persisted IS NOT INITIAL.
      MODIFY zstockalloc FROM TABLE @lt_persisted.
      IF sy-subrc <> 0.
        RAISE EXCEPTION NEW zcx_stock_allocation(
          'Allocation snapshot could not be persisted completely' ).
      ENDIF.
      SELECT COUNT( * )
        FROM zstockalloc
        WHERE matnr = @iv_material
          AND werks = @iv_plant
          AND lgort = @iv_storage_location
        INTO @DATA(lv_saved_count).
      IF lv_saved_count <> lines( lt_persisted ).
        RAISE EXCEPTION NEW zcx_stock_allocation(
          'Allocation snapshot row count is inconsistent' ).
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
