CLASS zcl_priority_sink_sap DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_priority_sink.
ENDCLASS.

CLASS zcl_priority_sink_sap IMPLEMENTATION.
  METHOD zif_priority_sink~save.
    DATA(ls_priority) = VALUE zstockprio(
      matnr = iv_material
      werks = iv_plant
      lgort = iv_storage_location
      vbeln = iv_sales_order
      posnr = iv_sales_item
      priority = iv_priority ).
    MODIFY zstockprio FROM @ls_priority.
  ENDMETHOD.

  METHOD zif_priority_sink~remove.
    DELETE FROM zstockprio
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND lgort = @iv_storage_location
        AND vbeln = @iv_sales_order
        AND posnr = @iv_sales_item.
  ENDMETHOD.
ENDCLASS.
