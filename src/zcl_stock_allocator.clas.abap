CLASS zcl_stock_allocator DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS allocate
      IMPORTING
        iv_available          TYPE zif_stock_allocation=>ty_quantity
        it_demands            TYPE zif_stock_allocation=>tt_demands
        iv_unit               TYPE zif_stock_allocation=>ty_unit OPTIONAL
        iv_reserve            TYPE zif_stock_allocation=>ty_quantity OPTIONAL
        iv_strategy           TYPE zif_stock_allocation=>ty_strategy DEFAULT zif_stock_allocation=>c_strategy_fifo
        iv_cutoff_date        TYPE zif_stock_allocation=>ty_cutoff_date OPTIONAL
      RETURNING
        VALUE(rt_allocations) TYPE zif_stock_allocation=>tt_allocations
      RAISING
        zcx_stock_allocation.
  PRIVATE SECTION.
    METHODS allocate_tier
      IMPORTING
        iv_available          TYPE zif_stock_allocation=>ty_quantity
        it_demands            TYPE zif_stock_allocation=>tt_demands
        iv_unit               TYPE zif_stock_allocation=>ty_unit
        iv_reserve            TYPE zif_stock_allocation=>ty_quantity
        iv_strategy           TYPE zif_stock_allocation=>ty_strategy
        iv_cutoff_date        TYPE zif_stock_allocation=>ty_cutoff_date
      RETURNING
        VALUE(rt_allocations) TYPE zif_stock_allocation=>tt_allocations.
    METHODS build_result
      IMPORTING
        is_demand            TYPE zif_stock_allocation=>ty_demand
        iv_allocated         TYPE zif_stock_allocation=>ty_quantity
        iv_unit              TYPE zif_stock_allocation=>ty_unit
        iv_reserve           TYPE zif_stock_allocation=>ty_quantity
        iv_strategy          TYPE zif_stock_allocation=>ty_strategy
        iv_cutoff_date       TYPE zif_stock_allocation=>ty_cutoff_date
      RETURNING
        VALUE(rs_allocation) TYPE zif_stock_allocation=>ty_allocation.
ENDCLASS.

CLASS zcl_stock_allocator IMPLEMENTATION.
  METHOD allocate.
    DATA lv_remaining TYPE zif_stock_allocation=>ty_quantity.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lt_tier TYPE zif_stock_allocation=>tt_demands.
    DATA lv_tier_priority TYPE zif_stock_allocation=>ty_priority.

    IF iv_strategy <> zif_stock_allocation=>c_strategy_fifo
        AND iv_strategy <> zif_stock_allocation=>c_strategy_proportional
        AND iv_strategy <> zif_stock_allocation=>c_strategy_fair_share
        AND iv_strategy <> zif_stock_allocation=>c_strategy_smallest_first
        AND iv_strategy <> zif_stock_allocation=>c_strategy_complete_only.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Unknown stock allocation strategy' ).
    ENDIF.

    lv_remaining = iv_available.
    IF lv_remaining < 0.
      CLEAR lv_remaining.
    ENDIF.

    lt_demands = it_demands.
    DELETE lt_demands WHERE requested_qty <= 0.
    SORT lt_demands BY priority DESCENDING
                       delivery_date ASCENDING
                       sales_order ASCENDING
                       sales_item ASCENDING
                       schedule_line ASCENDING.

    LOOP AT lt_demands INTO DATA(ls_demand).
      IF lt_tier IS NOT INITIAL AND ls_demand-priority <> lv_tier_priority.
        DATA(lt_tier_result) = allocate_tier(
          iv_available = lv_remaining
          it_demands = lt_tier
          iv_unit = iv_unit
          iv_reserve = iv_reserve
          iv_strategy = iv_strategy
          iv_cutoff_date = iv_cutoff_date ).
        LOOP AT lt_tier_result INTO DATA(ls_tier_result).
          lv_remaining = lv_remaining - ls_tier_result-allocated_qty.
          APPEND ls_tier_result TO rt_allocations.
        ENDLOOP.
        IF iv_strategy = zif_stock_allocation=>c_strategy_complete_only.
          READ TABLE lt_tier_result TRANSPORTING NO FIELDS
            WITH KEY status = zif_stock_allocation=>c_status_none.
          IF sy-subrc = 0.
            CLEAR lv_remaining.
          ENDIF.
        ENDIF.
        CLEAR lt_tier.
      ENDIF.
      lv_tier_priority = ls_demand-priority.
      APPEND ls_demand TO lt_tier.
    ENDLOOP.

    IF lt_tier IS NOT INITIAL.
      lt_tier_result = allocate_tier(
        iv_available = lv_remaining
        it_demands = lt_tier
        iv_unit = iv_unit
        iv_reserve = iv_reserve
        iv_strategy = iv_strategy
        iv_cutoff_date = iv_cutoff_date ).
      APPEND LINES OF lt_tier_result TO rt_allocations.
    ENDIF.
  ENDMETHOD.

  METHOD allocate_tier.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lv_remaining TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_remaining_requested TYPE zif_stock_allocation=>ty_total_quantity.

    lt_demands = it_demands.
    lv_remaining = iv_available.
    LOOP AT lt_demands INTO DATA(ls_requested).
      lv_remaining_requested = lv_remaining_requested + ls_requested-requested_qty.
    ENDLOOP.

    IF iv_strategy = zif_stock_allocation=>c_strategy_fair_share
        OR iv_strategy = zif_stock_allocation=>c_strategy_smallest_first.
      SORT lt_demands BY requested_qty ASCENDING
                         delivery_date ASCENDING
                         sales_order ASCENDING
                         sales_item ASCENDING
                         schedule_line ASCENDING.
    ENDIF.

    DATA(lv_remaining_count) = lines( lt_demands ).
    LOOP AT lt_demands INTO DATA(ls_demand).
      DATA lv_allocated TYPE zif_stock_allocation=>ty_quantity.
      IF lv_remaining <= 0.
        CLEAR lv_allocated.
      ELSEIF lv_remaining >= lv_remaining_requested.
        lv_allocated = ls_demand-requested_qty.
      ELSEIF iv_strategy = zif_stock_allocation=>c_strategy_fifo
          OR iv_strategy = zif_stock_allocation=>c_strategy_smallest_first.
        lv_allocated = nmin( val1 = lv_remaining val2 = ls_demand-requested_qty ).
      ELSEIF iv_strategy = zif_stock_allocation=>c_strategy_complete_only.
        IF lv_remaining >= ls_demand-requested_qty.
          lv_allocated = ls_demand-requested_qty.
        ENDIF.
      ELSEIF iv_strategy = zif_stock_allocation=>c_strategy_proportional.
        lv_allocated = lv_remaining * ls_demand-requested_qty
                     / lv_remaining_requested.
        lv_allocated = nmin( val1 = lv_allocated val2 = ls_demand-requested_qty ).
        lv_allocated = nmin( val1 = lv_allocated val2 = lv_remaining ).
      ELSE.
        lv_allocated = lv_remaining / lv_remaining_count.
        lv_allocated = nmin( val1 = lv_allocated val2 = ls_demand-requested_qty ).
        lv_allocated = nmin( val1 = lv_allocated val2 = lv_remaining ).
      ENDIF.

      APPEND build_result(
        is_demand = ls_demand
        iv_allocated = lv_allocated
        iv_unit = iv_unit
        iv_reserve = iv_reserve
        iv_strategy = iv_strategy
        iv_cutoff_date = iv_cutoff_date ) TO rt_allocations.
      lv_remaining = lv_remaining - lv_allocated.
      lv_remaining_requested = lv_remaining_requested - ls_demand-requested_qty.
      lv_remaining_count = lv_remaining_count - 1.
    ENDLOOP.

    SORT rt_allocations BY priority DESCENDING
                           delivery_date ASCENDING
                           sales_order ASCENDING
                           sales_item ASCENDING
                           schedule_line ASCENDING.
  ENDMETHOD.

  METHOD build_result.
    rs_allocation = VALUE #(
      sales_order = is_demand-sales_order
      sales_item = is_demand-sales_item
      schedule_line = is_demand-schedule_line
      delivery_date = is_demand-delivery_date
      priority = is_demand-priority
      requested_qty = is_demand-requested_qty
      allocated_qty = iv_allocated
      shortage_qty = is_demand-requested_qty - iv_allocated
      reserve_qty = iv_reserve
      unit = iv_unit
      strategy = iv_strategy ).
    rs_allocation-cutoff_date = iv_cutoff_date.
    IF iv_allocated = is_demand-requested_qty.
      rs_allocation-status = zif_stock_allocation=>c_status_full.
    ELSEIF iv_allocated > 0.
      rs_allocation-status = zif_stock_allocation=>c_status_partial.
    ELSE.
      rs_allocation-status = zif_stock_allocation=>c_status_none.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
