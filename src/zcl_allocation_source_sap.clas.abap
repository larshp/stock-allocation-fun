CLASS zcl_allocation_source_sap DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_allocation_source.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_header,
        version_no    TYPE i,
        stock_qty     TYPE zif_stock_allocation=>ty_quantity,
        available_qty TYPE zif_stock_allocation=>ty_quantity,
        reserve_qty   TYPE zif_stock_allocation=>ty_quantity,
        demand_count  TYPE i,
        meins         TYPE zif_stock_allocation=>ty_unit,
        strategy      TYPE zif_stock_allocation=>ty_strategy,
        start_date    TYPE zif_stock_allocation=>ty_delivery_date,
        cutoff_date   TYPE zif_stock_allocation=>ty_delivery_date,
        created_on    TYPE d,
        created_at    TYPE t,
        created_by    TYPE c LENGTH 12,
      END OF ty_header,
      BEGIN OF ty_detail,
        vbeln        TYPE zif_stock_allocation=>ty_sales_order,
        posnr        TYPE zif_stock_allocation=>ty_sales_item,
        etenr        TYPE zif_stock_allocation=>ty_schedule_line,
        mbdat        TYPE zif_stock_allocation=>ty_delivery_date,
        priority     TYPE zif_stock_allocation=>ty_priority,
        req_qty      TYPE zif_stock_allocation=>ty_quantity,
        alloc_qty    TYPE zif_stock_allocation=>ty_quantity,
        short_qty    TYPE zif_stock_allocation=>ty_quantity,
        reserve_qty  TYPE zif_stock_allocation=>ty_quantity,
        meins        TYPE zif_stock_allocation=>ty_unit,
        strategy     TYPE zif_stock_allocation=>ty_strategy,
        start_date   TYPE zif_stock_allocation=>ty_delivery_date,
        cutoff_date  TYPE zif_stock_allocation=>ty_delivery_date,
        alloc_status TYPE zif_stock_allocation=>ty_status,
      END OF ty_detail,
      ty_details TYPE STANDARD TABLE OF ty_detail WITH EMPTY KEY.
ENDCLASS.

CLASS zcl_allocation_source_sap IMPLEMENTATION.
  METHOD zif_allocation_source~get_saved.
    DATA ls_header TYPE ty_header.
    DATA lt_rows TYPE ty_details.

    IF iv_version_no IS INITIAL.
      SELECT SINGLE version_no, stock_qty, available_qty, reserve_qty,
                    demand_count, meins, strategy, start_date, cutoff_date,
                    created_on, created_at, created_by
        FROM zstockplan
        WHERE matnr = @iv_material
          AND werks = @iv_plant
          AND lgort = @iv_storage_location
        INTO CORRESPONDING FIELDS OF @ls_header.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.

      SELECT vbeln, posnr, etenr, mbdat, priority, req_qty, alloc_qty,
             short_qty, reserve_qty, meins, strategy, start_date,
             cutoff_date, alloc_status
        FROM zstockalloc
        WHERE matnr = @iv_material
          AND werks = @iv_plant
          AND lgort = @iv_storage_location
        INTO CORRESPONDING FIELDS OF TABLE @lt_rows.
    ELSE.
      SELECT SINGLE version_no, stock_qty, available_qty, reserve_qty,
                    demand_count, meins, strategy, start_date, cutoff_date,
                    created_on, created_at, created_by
        FROM zstockphist
        WHERE matnr = @iv_material
          AND werks = @iv_plant
          AND lgort = @iv_storage_location
          AND version_no = @iv_version_no
        INTO CORRESPONDING FIELDS OF @ls_header.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.

      SELECT vbeln, posnr, etenr, mbdat, priority, req_qty, alloc_qty,
             short_qty, reserve_qty, meins, strategy, start_date,
             cutoff_date, alloc_status
        FROM zstockahist
        WHERE matnr = @iv_material
          AND werks = @iv_plant
          AND lgort = @iv_storage_location
          AND version_no = @iv_version_no
        INTO CORRESPONDING FIELDS OF TABLE @lt_rows.
    ENDIF.

    rs_saved-found = abap_true.
    rs_saved-version_no = ls_header-version_no.
    rs_saved-plan-stock_qty = ls_header-stock_qty.
    rs_saved-plan-allocatable_qty = ls_header-available_qty.
    rs_saved-plan-reserve_qty = ls_header-reserve_qty.
    rs_saved-plan-unit = ls_header-meins.
    rs_saved-plan-strategy = ls_header-strategy.
    rs_saved-plan-start_date = ls_header-start_date.
    rs_saved-plan-cutoff_date = ls_header-cutoff_date.
    rs_saved-created_on = ls_header-created_on.
    rs_saved-created_at = ls_header-created_at.
    rs_saved-created_by = ls_header-created_by.

    LOOP AT lt_rows INTO DATA(ls_row).
      APPEND VALUE #(
        sales_order   = ls_row-vbeln
        sales_item    = ls_row-posnr
        schedule_line = ls_row-etenr
        delivery_date = ls_row-mbdat
        priority      = ls_row-priority
        requested_qty = ls_row-req_qty
        allocated_qty = ls_row-alloc_qty
        shortage_qty  = ls_row-short_qty
        reserve_qty   = ls_row-reserve_qty
        unit          = ls_row-meins
        strategy      = ls_row-strategy
        start_date    = ls_row-start_date
        cutoff_date   = ls_row-cutoff_date
        status        = ls_row-alloc_status ) TO rs_saved-plan-allocations.
    ENDLOOP.
    SORT rs_saved-plan-allocations BY priority DESCENDING
                                       delivery_date ASCENDING
                                       sales_order ASCENDING
                                       sales_item ASCENDING
                                       schedule_line ASCENDING.
    IF lines( rs_saved-plan-allocations ) <> ls_header-demand_count.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Persisted allocation header and detail count differ' ).
    ENDIF.
    zcl_stock_alloc_validator=>validate_plan( rs_saved-plan ).
  ENDMETHOD.
ENDCLASS.
