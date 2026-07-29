CLASS zcl_priority_sink_sap DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_priority_sink.
ENDCLASS.

CLASS zcl_priority_sink_sap IMPLEMENTATION.
  METHOD zif_priority_sink~save.
    DATA(ls_priority) = VALUE zstockprio(
      matnr      = iv_material
      werks      = iv_plant
      lgort      = iv_storage_location
      vbeln      = iv_sales_order
      posnr      = iv_sales_item
      changed_on = sy-datum
      changed_at = sy-uzeit
      changed_by = sy-uname
      priority   = iv_priority ).
    MODIFY zstockprio FROM @ls_priority.
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Allocation priority could not be persisted' ).
    ENDIF.
    SELECT SINGLE priority
      FROM zstockprio
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND lgort = @iv_storage_location
        AND vbeln = @iv_sales_order
        AND posnr = @iv_sales_item
      INTO @DATA(lv_saved_priority).
    IF sy-subrc <> 0 OR lv_saved_priority <> iv_priority.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Allocation priority verification failed' ).
    ENDIF.
  ENDMETHOD.

  METHOD zif_priority_sink~remove.
    DELETE FROM zstockprio
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND lgort = @iv_storage_location
        AND vbeln = @iv_sales_order
        AND posnr = @iv_sales_item.
    IF sy-subrc <> 0 AND sy-subrc <> 4.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Allocation priority could not be removed' ).
    ENDIF.
    SELECT COUNT( * )
      FROM zstockprio
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND lgort = @iv_storage_location
        AND vbeln = @iv_sales_order
        AND posnr = @iv_sales_item
      INTO @DATA(lv_remaining_count).
    IF lv_remaining_count <> 0.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Allocation priority deletion verification failed' ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
