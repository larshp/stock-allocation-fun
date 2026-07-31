REPORT zstock_allocate.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_location OBLIGATORY.
PARAMETERS p_bwart TYPE zif_stock_allocation=>ty_movement_type DEFAULT '201'.
PARAMETERS p_meins TYPE zif_stock_allocation=>ty_unit DEFAULT 'EA'.

START-OF-SELECTION.
  DATA lo_stock_source TYPE REF TO zif_stock_source.
  DATA lo_order_source TYPE REF TO zif_order_source.
  DATA lo_sink TYPE REF TO zif_allocation_sink.
  DATA lo_allocator TYPE REF TO zif_stock_allocation.
  DATA lo_reservation TYPE REF TO zif_stock_reservation.
  DATA lo_service TYPE REF TO zcl_stock_allocation_service.
  DATA lv_remaining TYPE zif_stock_allocation=>ty_quantity.

  CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
  CREATE OBJECT lo_order_source TYPE zcl_order_source_sap.
  CREATE OBJECT lo_sink TYPE zcl_allocation_sink_sap.
  CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
  CREATE OBJECT lo_reservation TYPE zcl_stock_reservation_sap.
  CREATE OBJECT lo_service
    EXPORTING
      io_stock_source = lo_stock_source
      io_order_source = lo_order_source
      io_sink         = lo_sink
      io_allocator    = lo_allocator
      io_reservation  = lo_reservation.

  lv_remaining = lo_service->allocate(
    iv_material         = p_matnr
    iv_plant            = p_werks
    iv_storage_location = p_lgort
    iv_movement_type    = p_bwart
    iv_unit             = p_meins ).
  WRITE / lv_remaining.
