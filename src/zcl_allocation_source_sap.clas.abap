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
        requested_qty TYPE zif_stock_allocation=>ty_quantity,
        allocated_qty TYPE zif_stock_allocation=>ty_quantity,
        shortage_qty  TYPE zif_stock_allocation=>ty_quantity,
        full_count    TYPE i,
        partial_count TYPE i,
        none_count    TYPE i,
        meins         TYPE zif_stock_allocation=>ty_unit,
        strategy      TYPE zif_stock_allocation=>ty_strategy,
        start_date    TYPE zif_stock_allocation=>ty_delivery_date,
        cutoff_date   TYPE zif_stock_allocation=>ty_delivery_date,
        run_note      TYPE zif_stock_allocation=>ty_run_note,
        created_on    TYPE d,
        created_at    TYPE t,
        created_by    TYPE zif_stock_allocation=>ty_created_by,
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
  METHOD zif_allocation_source~list_versions.
    DATA(lv_created_from) = iv_created_from.
    DATA(lv_created_to) = iv_created_to.
    IF lv_created_from IS INITIAL.
      lv_created_from = '00010101'.
    ENDIF.
    IF lv_created_to IS INITIAL.
      lv_created_to = '99991231'.
    ENDIF.
    DATA lv_min_shortage TYPE zif_stock_allocation=>ty_quantity.
    IF iv_shortages_only = abap_true.
      lv_min_shortage = '0.001'.
    ENDIF.
    DATA lt_strategies TYPE RANGE OF zstockphist-strategy.
    IF iv_strategy IS INITIAL.
      APPEND VALUE #( sign = 'I' option = 'CP' low = '*' ) TO lt_strategies.
    ELSE.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = iv_strategy ) TO lt_strategies.
    ENDIF.
    DATA lt_creators TYPE RANGE OF zstockphist-created_by.
    IF iv_created_by IS INITIAL.
      APPEND VALUE #( sign = 'I' option = 'CP' low = '*' ) TO lt_creators.
    ELSE.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = iv_created_by ) TO lt_creators.
    ENDIF.
    IF iv_before_version IS INITIAL.
      SELECT version_no, stock_qty, available_qty, reserve_qty, demand_count,
             requested_qty, allocated_qty, shortage_qty,
             full_count, partial_count, none_count,
             meins, strategy, start_date, cutoff_date, run_note, created_on, created_at,
             created_by
        FROM zstockphist
        WHERE matnr = @iv_material
          AND werks = @iv_plant
          AND lgort = @iv_storage_location
          AND created_on >= @lv_created_from
          AND created_on <= @lv_created_to
          AND shortage_qty >= @lv_min_shortage
          AND strategy IN @lt_strategies
          AND created_by IN @lt_creators
        ORDER BY version_no DESCENDING
        INTO TABLE @DATA(lt_headers)
        UP TO @iv_max_versions ROWS.
    ELSE.
      SELECT version_no, stock_qty, available_qty, reserve_qty, demand_count,
             requested_qty, allocated_qty, shortage_qty,
             full_count, partial_count, none_count,
             meins, strategy, start_date, cutoff_date, run_note, created_on, created_at,
             created_by
        FROM zstockphist
        WHERE matnr = @iv_material
          AND werks = @iv_plant
          AND lgort = @iv_storage_location
          AND version_no < @iv_before_version
          AND created_on >= @lv_created_from
          AND created_on <= @lv_created_to
          AND shortage_qty >= @lv_min_shortage
          AND strategy IN @lt_strategies
          AND created_by IN @lt_creators
        ORDER BY version_no DESCENDING
        INTO TABLE @lt_headers
        UP TO @iv_max_versions ROWS.
    ENDIF.

    LOOP AT lt_headers INTO DATA(ls_header).
      APPEND VALUE #(
        version_no      = ls_header-version_no
        stock_qty       = ls_header-stock_qty
        allocatable_qty = ls_header-available_qty
        reserve_qty     = ls_header-reserve_qty
        demand_count    = ls_header-demand_count
        requested_qty   = ls_header-requested_qty
        allocated_qty   = ls_header-allocated_qty
        shortage_qty    = ls_header-shortage_qty
        full_count      = ls_header-full_count
        partial_count   = ls_header-partial_count
        none_count      = ls_header-none_count
        unit            = ls_header-meins
        strategy        = ls_header-strategy
        start_date      = ls_header-start_date
        cutoff_date     = ls_header-cutoff_date
        run_note        = ls_header-run_note
        created_on      = ls_header-created_on
        created_at      = ls_header-created_at
        created_by      = ls_header-created_by ) TO rt_versions.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_allocation_source~get_saved.
    DATA ls_header TYPE ty_header.
    DATA lt_rows TYPE ty_details.

    IF iv_version_no IS INITIAL.
      SELECT SINGLE version_no, stock_qty, available_qty, reserve_qty,
                    demand_count, requested_qty, allocated_qty, shortage_qty,
                    full_count, partial_count, none_count,
                    meins, strategy, start_date, cutoff_date, run_note,
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
                    demand_count, requested_qty, allocated_qty, shortage_qty,
                    full_count, partial_count, none_count,
                    meins, strategy, start_date, cutoff_date, run_note,
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
    rs_saved-plan-version_no = ls_header-version_no.
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
    rs_saved-run_note = ls_header-run_note.

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
    DATA(ls_summary) = zcl_stock_alloc_summary=>summarize(
      it_allocations     = rs_saved-plan-allocations
      iv_stock_qty       = rs_saved-plan-stock_qty
      iv_allocatable_qty = rs_saved-plan-allocatable_qty
      iv_reserve         = rs_saved-plan-reserve_qty
      iv_unit            = rs_saved-plan-unit ).
    DATA lv_requested_qty TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_allocated_qty TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_shortage_qty TYPE zif_stock_allocation=>ty_quantity.
    lv_requested_qty = ls_summary-requested_qty.
    lv_allocated_qty = ls_summary-allocated_qty.
    lv_shortage_qty = ls_summary-shortage_qty.
    IF ls_header-requested_qty <> lv_requested_qty
        OR ls_header-allocated_qty <> lv_allocated_qty
        OR ls_header-shortage_qty <> lv_shortage_qty
        OR ls_header-full_count <> ls_summary-full_count
        OR ls_header-partial_count <> ls_summary-partial_count
        OR ls_header-none_count <> ls_summary-none_count.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Persisted allocation header outcome differs from its details' ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
