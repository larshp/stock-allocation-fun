CLASS zcl_allocation_source_sap DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_allocation_source.
ENDCLASS.

CLASS zcl_allocation_source_sap IMPLEMENTATION.
  METHOD zif_allocation_source~get_saved.
    SELECT SINGLE *
      FROM zstockplan
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND lgort = @iv_storage_location
      INTO @DATA(ls_header).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    rs_saved-found = abap_true.
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

    SELECT *
      FROM zstockalloc
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND lgort = @iv_storage_location
      INTO TABLE @DATA(lt_rows).
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
