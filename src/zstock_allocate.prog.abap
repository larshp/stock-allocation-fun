REPORT zstock_allocate.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_location OBLIGATORY.
PARAMETERS p_charg TYPE zif_stock_allocation=>ty_batch.
PARAMETERS p_bwart TYPE zif_stock_allocation=>ty_movement_type DEFAULT '201'.
PARAMETERS p_meins TYPE zif_stock_allocation=>ty_unit DEFAULT 'EA'.
PARAMETERS p_shelf TYPE i DEFAULT 0.
PARAMETERS p_test AS CHECKBOX.

START-OF-SELECTION.
  DATA lo_stock_source TYPE REF TO zif_stock_source.
  DATA lo_order_source TYPE REF TO zif_order_source.
  DATA lo_sink TYPE REF TO zif_allocation_sink.
  DATA lo_allocator TYPE REF TO zif_stock_allocation.
  DATA lo_reservation TYPE REF TO zif_stock_reservation.
  DATA lo_unit_converter TYPE REF TO zif_unit_conversion.
  DATA lo_lock TYPE REF TO zif_stock_allocation_lock.
  DATA lo_authority TYPE REF TO zif_stock_allocation_authority.
  DATA lo_audit TYPE REF TO zif_allocation_audit.
  DATA lo_service TYPE REF TO zcl_stock_allocation_service.
  DATA lv_remaining TYPE zif_stock_allocation=>ty_quantity.
  DATA ls_summary TYPE zif_allocation_audit=>ty_summary.

  CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
  CREATE OBJECT lo_order_source TYPE zcl_order_source_sap.
  CREATE OBJECT lo_sink TYPE zcl_allocation_sink_sap.
  CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
  CREATE OBJECT lo_reservation TYPE zcl_stock_reservation_sap.
  CREATE OBJECT lo_unit_converter TYPE zcl_unit_conversion_sap.
  CREATE OBJECT lo_lock TYPE zcl_stock_allocation_lock_sap.
  CREATE OBJECT lo_authority TYPE zcl_stock_allocation_authority_sap.
  CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
  CREATE OBJECT lo_service
    EXPORTING
      io_stock_source   = lo_stock_source
      io_order_source   = lo_order_source
      io_sink           = lo_sink
      io_allocator      = lo_allocator
      io_reservation    = lo_reservation
      io_unit_converter = lo_unit_converter
      io_lock           = lo_lock
      io_authority      = lo_authority
      io_audit          = lo_audit.

  TRY.
      lv_remaining = lo_service->allocate(
        iv_material         = p_matnr
        iv_plant            = p_werks
        iv_storage_location = p_lgort
        iv_movement_type    = p_bwart
        iv_unit             = p_meins
        iv_batch            = p_charg
        iv_min_shelf_life   = p_shelf
        iv_preview          = p_test ).
    CATCH zcx_stock_allocation.
      TRY.
          ls_summary = lo_audit->get_summary(
            iv_material         = p_matnr
            iv_plant            = p_werks
            iv_storage_location = p_lgort
            iv_batch            = p_charg
            iv_unit             = p_meins ).
          WRITE: / 'Allocation failed.'
                 , / 'Last status:', ls_summary-last_status
                 , / 'Last message:', ls_summary-last_message.
        CATCH zcx_stock_allocation.
          WRITE: / 'Allocation failed; audit status is unavailable.'.
      ENDTRY.
      RETURN.
  ENDTRY.
  ls_summary = lo_audit->get_summary(
    iv_material         = p_matnr
    iv_plant            = p_werks
    iv_storage_location = p_lgort
    iv_batch            = p_charg
    iv_unit             = p_meins ).
  WRITE: / 'Remaining:', lv_remaining, p_meins,
         / 'Runs:', ls_summary-total_runs,
         / 'Successful:', ls_summary-success_runs,
         / 'Partial:', ls_summary-partial_runs,
         / 'Errors:', ls_summary-error_runs,
         / 'Allocated:', ls_summary-allocated, ls_summary-unit,
         / 'Shortage:', ls_summary-shortage, ls_summary-unit,
         / 'Last run:', ls_summary-last_run_id,
         / 'Last status:', ls_summary-last_status,
         / 'Last message:', ls_summary-last_message.
