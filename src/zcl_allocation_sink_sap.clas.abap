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
    DATA(ls_header) = VALUE zstockplan(
      matnr         = iv_material
      werks         = iv_plant
      lgort         = iv_storage_location
      stock_qty     = is_plan-stock_qty
      available_qty = is_plan-allocatable_qty
      reserve_qty   = is_plan-reserve_qty
      demand_count  = lines( is_plan-allocations )
      meins         = is_plan-unit
      strategy      = is_plan-strategy
      start_date    = is_plan-start_date
      cutoff_date   = is_plan-cutoff_date
      created_on    = lv_created_on
      created_at    = lv_created_at
      created_by    = lv_created_by ).
    MODIFY zstockplan FROM @ls_header.
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Allocation plan header could not be persisted' ).
    ENDIF.
    SELECT SINGLE stock_qty, available_qty, reserve_qty, demand_count,
                  meins, strategy, start_date, cutoff_date,
                  created_on, created_at, created_by
      FROM zstockplan
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND lgort = @iv_storage_location
      INTO @DATA(ls_saved_header).
    IF sy-subrc <> 0
        OR ls_saved_header-stock_qty <> is_plan-stock_qty
        OR ls_saved_header-available_qty <> is_plan-allocatable_qty
        OR ls_saved_header-reserve_qty <> is_plan-reserve_qty
        OR ls_saved_header-demand_count <> lines( is_plan-allocations )
        OR ls_saved_header-meins <> is_plan-unit
        OR ls_saved_header-strategy <> is_plan-strategy
        OR ls_saved_header-start_date <> is_plan-start_date
        OR ls_saved_header-cutoff_date <> is_plan-cutoff_date
        OR ls_saved_header-created_on <> lv_created_on
        OR ls_saved_header-created_at <> lv_created_at
        OR ls_saved_header-created_by <> lv_created_by.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Allocation plan header verification failed' ).
    ENDIF.

    DATA lt_persisted TYPE STANDARD TABLE OF zstockalloc WITH EMPTY KEY.
    LOOP AT is_plan-allocations INTO DATA(ls_allocation).
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
        start_date   = ls_allocation-start_date
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
