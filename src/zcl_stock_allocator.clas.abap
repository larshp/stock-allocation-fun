"! Stock allocation engine - core logic
"! Allocates available stock (from MARD) to open sales order items,
"! following FIFO order by document number.
CLASS zcl_stock_allocator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_allocation,
             vbeln     TYPE vbap-vbeln,     " sales order
             posnr     TYPE vbap-posnr,     " item
             matnr     TYPE vbap-matnr,     " material
             werks     TYPE vbap-werks,     " plant
             lgort     TYPE mard-lgort,     " storage location allocated from
             lprio     TYPE lprio,          " delivery priority (1 = highest)
             qty_req   TYPE kwmeng,         " requested quantity
             qty_alloc TYPE kwmeng,         " allocated quantity
           END OF ty_allocation.
    TYPES tt_allocations TYPE STANDARD TABLE OF ty_allocation WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_sub_allocation,
             vbeln      TYPE vbap-vbeln,  " sales order
             posnr      TYPE vbap-posnr,  " item
             matnr_req  TYPE matnr,       " originally requested material
             matnr_used TYPE matnr,       " material actually allocated
             werks      TYPE vbap-werks,
             lgort      TYPE mard-lgort,
             qty_alloc  TYPE kwmeng,
           END OF ty_sub_allocation.
    TYPES tt_sub_allocations TYPE STANDARD TABLE OF ty_sub_allocation WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_stats,
             items_total   TYPE i,            " open order items processed
             items_full    TYPE i,            " fully allocated
             items_partial TYPE i,            " partially allocated
             items_none    TYPE i,            " nothing allocated
             qty_requested TYPE kwmeng,       " total requested quantity
             qty_allocated TYPE kwmeng,       " total allocated quantity
           END OF ty_stats.

    TYPES: BEGIN OF ty_result,
             allocations  TYPE tt_allocations,
             qty_shortage TYPE kwmeng,       " total unallocated quantity
             messages     TYPE zcl_stub_message=>tt_message, " log messages
             stats        TYPE ty_stats,     " run statistics
           END OF ty_result.

    "! Run allocation for one material at a plant across all storage locations
    CLASS-METHODS allocate_material
      IMPORTING
        iv_matnr         TYPE matnr
        iv_werks         TYPE werks_d
      RETURNING
        VALUE(rs_result) TYPE ty_result.

    "! Run allocation with a preferred storage location: stock is taken from
    "! iv_lgort first, remaining demand is filled from the other locations.
    CLASS-METHODS allocate_material_with_sloc
      IMPORTING
        iv_matnr         TYPE matnr
        iv_werks         TYPE werks_d
        iv_lgort         TYPE lgort_d
      RETURNING
        VALUE(rs_result) TYPE ty_result.

    "! Run allocation with FEFO strategy (first expired, first out):
    "! stock locations are consumed by ascending batch date BDATR,
    "! oldest batch first. Locations without a date are used last.
    CLASS-METHODS allocate_material_fefo
      IMPORTING
        iv_matnr         TYPE matnr
        iv_werks         TYPE werks_d
      RETURNING
        VALUE(rs_result) TYPE ty_result.

    "! Run allocation with a pluggable strategy: io_strategy decides in
    "! which order storage locations are consumed.
    CLASS-METHODS allocate_material_by_strategy
      IMPORTING
        iv_matnr         TYPE matnr
        iv_werks         TYPE werks_d
        io_strategy      TYPE REF TO zif_alloc_strategy
      RETURNING
        VALUE(rs_result) TYPE ty_result.

    "! Run allocation only for items due up to iv_date (requested delivery
    "! date horizon). Items due later keep their stock free.
    CLASS-METHODS allocate_material_until
      IMPORTING
        iv_matnr         TYPE matnr
        iv_werks         TYPE werks_d
        iv_date          TYPE edatu
      RETURNING
        VALUE(rs_result) TYPE ty_result.

    "! Post allocations: confirm quantities on the sales order items and
    "! reduce unrestricted stock in the storage locations (goods issue).
    "! Items below iv_min_qty are not posted (kept open for a later run);
    "! if iv_min_qty is initial, everything allocated is posted.
    CLASS-METHODS post_allocations
      IMPORTING
        it_allocations TYPE tt_allocations
        iv_min_qty     TYPE kwmeng OPTIONAL
      RETURNING
        VALUE(rv_ok)   TYPE abap_bool.

    "! Allocate with material substitution: if the requested material cannot
    "! fully cover an item, substitute materials (by priority) serve the
    "! remaining demand. Returns one row per material actually used.
    CLASS-METHODS allocate_with_substitution
      IMPORTING
        iv_matnr            TYPE matnr
        iv_werks            TYPE werks_d
      RETURNING
        VALUE(rt_sub_alloc) TYPE tt_sub_allocations.

    "! Allocate across several plants: plants are consumed in the given
    "! order; each plant keeps its safety stock untouched. Rows carry the
    "! plant so the caller can create per-plant deliveries.
    CLASS-METHODS allocate_multi_plant
      IMPORTING
        iv_matnr            TYPE matnr
        it_plants           TYPE tt_plants
        iv_safety_stock     TYPE labst DEFAULT 0
      RETURNING
        VALUE(rt_sub_alloc) TYPE tt_sub_allocations.

    TYPES: BEGIN OF ty_plant,
             werks TYPE werks_d,
           END OF ty_plant.
    TYPES tt_plants TYPE STANDARD TABLE OF ty_plant WITH DEFAULT KEY.

  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES tt_mard TYPE STANDARD TABLE OF mard WITH DEFAULT KEY.
    "! Sum available stock across all storage locations for material/plant
    CLASS-METHODS get_available_stock
      IMPORTING
        iv_matnr       TYPE matnr
        iv_werks       TYPE werks_d
      RETURNING
        VALUE(rt_mard) TYPE tt_mard.

    "! Sort stock rows so iv_lgort comes first, rest keeps its order
    CLASS-METHODS sort_mard_preferred
      IMPORTING
        it_mard        TYPE tt_mard
        iv_lgort       TYPE lgort_d
      RETURNING
        VALUE(rt_mard) TYPE tt_mard.

    "! Sort stock rows by batch date ascending (FEFO); rows without a
    "! date (initial BDATR) are moved to the end, keeping relative order
    CLASS-METHODS sort_mard_fefo
      IMPORTING
        it_mard        TYPE tt_mard
      RETURNING
        VALUE(rt_mard) TYPE tt_mard.

    "! Core allocation loop over open items against a given stock list
    CLASS-METHODS allocate_from_sorted
      IMPORTING
        iv_matnr         TYPE matnr
        iv_werks         TYPE werks_d
        it_mard          TYPE tt_mard
      RETURNING
        VALUE(rs_result) TYPE ty_result.

    "! Core allocation loop with a delivery-date horizon filter
    CLASS-METHODS allocate_from_sorted_until
      IMPORTING
        iv_matnr         TYPE matnr
        iv_werks         TYPE werks_d
        it_mard          TYPE tt_mard
        iv_date          TYPE edatu
      RETURNING
        VALUE(rs_result) TYPE ty_result.

    "! Safety stock: quantity per SLoc that allocation must not touch
    CLASS-DATA gv_safety_stock TYPE labst.

ENDCLASS.



CLASS zcl_stock_allocator IMPLEMENTATION.


  METHOD allocate_material.
    DATA(lt_mard) = get_available_stock(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ).

    rs_result = allocate_from_sorted(
        iv_matnr = iv_matnr
        iv_werks = iv_werks
        it_mard  = lt_mard ).
  ENDMETHOD.


  METHOD allocate_material_with_sloc.
    DATA(lt_mard) = get_available_stock(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ).

    " preferred storage location first, remaining locations keep their order
    DATA(lt_sorted) = sort_mard_preferred(
        it_mard  = lt_mard
        iv_lgort = iv_lgort ).

    rs_result = allocate_from_sorted(
        iv_matnr = iv_matnr
        iv_werks = iv_werks
        it_mard  = lt_sorted ).
  ENDMETHOD.


  METHOD allocate_material_fefo.
    DATA(lt_mard) = get_available_stock(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ).

    " oldest batch first (FEFO)
    DATA(lt_sorted) = sort_mard_fefo( it_mard = lt_mard ).

    rs_result = allocate_from_sorted(
        iv_matnr = iv_matnr
        iv_werks = iv_werks
        it_mard  = lt_sorted ).
  ENDMETHOD.


  METHOD allocate_material_by_strategy.
    DATA(lt_mard) = get_available_stock(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ).

    " the strategy decides the consumption order
    DATA(lt_sorted) = io_strategy->sort_stock(
        it_mard  = lt_mard
        iv_matnr = iv_matnr
        iv_werks = iv_werks ).

    rs_result = allocate_from_sorted(
        iv_matnr = iv_matnr
        iv_werks = iv_werks
        it_mard  = lt_sorted ).
  ENDMETHOD.


  METHOD allocate_material_until.
    DATA(lt_mard) = get_available_stock(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ).

    rs_result = allocate_from_sorted_until(
        iv_matnr = iv_matnr
        iv_werks = iv_werks
        it_mard  = lt_mard
        iv_date  = iv_date ).
  ENDMETHOD.


  METHOD allocate_from_sorted.
    " no delivery-date horizon: all items are due
    rs_result = allocate_from_sorted_until(
        iv_matnr = iv_matnr
        iv_werks = iv_werks
        it_mard  = it_mard
        iv_date  = '99991231' ).
  ENDMETHOD.


  METHOD allocate_from_sorted_until.
    DATA lv_remaining TYPE kwmeng.
    DATA lv_qty_take  TYPE kwmeng.

    " get open items due up to iv_date, sorted by priority then FIFO
    DATA(lt_items) = zcl_stub_sales_order=>read_open_items_until(
        iv_matnr = iv_matnr
        iv_werks = iv_werks
        iv_date  = iv_date ).
    SORT lt_items BY lprio ASCENDING vbeln ASCENDING posnr ASCENDING.

    LOOP AT lt_items INTO DATA(ls_item).
      " convert the order quantity from sales unit to base unit
      DATA(lv_qty_base) = zcl_stub_uom=>convert_to_base(
          iv_matnr = ls_item-matnr
          iv_vrkme = ls_item-vrkme
          iv_qty   = ls_item-kwmeng ).

      DATA(ls_alloc) = VALUE ty_allocation(
          vbeln   = ls_item-vbeln
          posnr   = ls_item-posnr
          matnr   = ls_item-matnr
          werks   = ls_item-werks
          lprio   = ls_item-lprio
          qty_req = lv_qty_base ).

      lv_remaining = lv_qty_base.

      " full-delivery-only items (maxpw = 1) need the whole quantity from a
      " single storage location; skip if no single SLoc can cover it.
      " maxpw = 0 (initial) means unlimited partial deliveries.
      IF ls_item-maxpw = 1 AND lv_remaining > 0.
        DATA(lv_covered) = abap_false.
        LOOP AT it_mard ASSIGNING FIELD-SYMBOL(<ls_mard_check>).
          IF <ls_mard_check>-labst >= lv_remaining.
            lv_covered = abap_true.
            EXIT.
          ENDIF.
        ENDLOOP.
        IF lv_covered = abap_false.
          " cannot deliver completely -> allocate nothing, log message
          rs_result-qty_shortage = rs_result-qty_shortage + lv_remaining.
          rs_result-stats-items_total = rs_result-stats-items_total + 1.
          rs_result-stats-qty_requested = rs_result-stats-qty_requested
                                          + lv_qty_base.
          rs_result-stats-items_none = rs_result-stats-items_none + 1.
          APPEND zcl_stub_message=>build(
              iv_msgty = 'W'
              iv_msgno = zcl_stub_message=>gc_msgno-partial_alloc
              iv_msgv1 = CONV symsgv( ls_item-vbeln )
              iv_msgv2 = CONV symsgv( 'FULL' ) )
              TO rs_result-messages.
          CONTINUE.
        ENDIF.
      ENDIF.

      " fulfill from storage locations in order; one allocation row per
      " storage location so every row references exactly one SLoc.
      " maxpw limits the number of partial deliveries (1 = full delivery
      " from one location only, 0 = unlimited)
      DATA(lv_deliveries) = 0.
      LOOP AT it_mard ASSIGNING FIELD-SYMBOL(<ls_mard>).
        IF lv_remaining <= 0.
          EXIT.
        ENDIF.
        IF <ls_mard>-labst <= 0.
          CONTINUE.
        ENDIF.
        IF ls_item-maxpw > 0 AND lv_deliveries >= ls_item-maxpw.
          " partial delivery limit reached -> stop allocating
          EXIT.
        ENDIF.
        IF <ls_mard>-labst >= lv_remaining.
          lv_qty_take = lv_remaining.
        ELSE.
          lv_qty_take = <ls_mard>-labst.
        ENDIF.
        DATA(ls_part) = ls_alloc.
        ls_part-lgort     = <ls_mard>-lgort.
        ls_part-qty_alloc = lv_qty_take.
        lv_remaining      = lv_remaining - lv_qty_take.
        " consume the stock so following order items see reduced quantity
        <ls_mard>-labst   = <ls_mard>-labst - lv_qty_take.
        lv_deliveries     = lv_deliveries + 1.
        APPEND ls_part TO rs_result-allocations.
      ENDLOOP.

      " remember the total allocated quantity for statistics/messages
      DATA(lv_allocated_total) = ls_item-kwmeng - lv_remaining.

      rs_result-qty_shortage = rs_result-qty_shortage + lv_remaining.

      " collect run statistics
      rs_result-stats-items_total = rs_result-stats-items_total + 1.
      rs_result-stats-qty_requested = rs_result-stats-qty_requested
                                      + lv_qty_base.
      rs_result-stats-qty_allocated = rs_result-stats-qty_allocated
                                      + lv_allocated_total.
      IF lv_remaining <= 0.
        rs_result-stats-items_full = rs_result-stats-items_full + 1.
      ELSEIF lv_allocated_total > 0.
        rs_result-stats-items_partial = rs_result-stats-items_partial + 1.
      ELSE.
        rs_result-stats-items_none = rs_result-stats-items_none + 1.
      ENDIF.

      " log the allocation outcome for the order item
      IF lv_remaining <= 0.
        APPEND zcl_stub_message=>build(
            iv_msgty = 'S'
            iv_msgno = zcl_stub_message=>gc_msgno-full_alloc
            iv_msgv1 = CONV symsgv( ls_item-vbeln ) ) TO rs_result-messages.
      ELSEIF lv_allocated_total > 0.
        APPEND zcl_stub_message=>build(
            iv_msgty = 'W'
            iv_msgno = zcl_stub_message=>gc_msgno-partial_alloc
            iv_msgv1 = CONV symsgv( ls_item-vbeln )
            iv_msgv2 = CONV symsgv( |{ lv_remaining }| ) )
            TO rs_result-messages.
      ELSE.
        APPEND zcl_stub_message=>build(
            iv_msgty = 'E'
            iv_msgno = zcl_stub_message=>gc_msgno-no_stock
            iv_msgv1 = CONV symsgv( ls_item-vbeln ) ) TO rs_result-messages.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD sort_mard_preferred.
    " preferred storage location first, remaining locations keep their order
    LOOP AT it_mard INTO DATA(ls_mard).
      IF ls_mard-lgort = iv_lgort.
        APPEND ls_mard TO rt_mard.
      ENDIF.
    ENDLOOP.
    LOOP AT it_mard INTO ls_mard.
      IF ls_mard-lgort <> iv_lgort.
        APPEND ls_mard TO rt_mard.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD sort_mard_fefo.
    " dated batches first, oldest batch date first; undated rows last
    DATA lt_dated TYPE tt_mard.
    DATA lt_undated TYPE tt_mard.

    LOOP AT it_mard INTO DATA(ls_mard).
      IF ls_mard-bdatr IS INITIAL.
        APPEND ls_mard TO lt_undated.
      ELSE.
        APPEND ls_mard TO lt_dated.
      ENDIF.
    ENDLOOP.

    " stable insertion sort by batch date ascending (small row counts)
    LOOP AT lt_dated INTO ls_mard.
      DATA(lv_inserted) = abap_false.
      LOOP AT rt_mard ASSIGNING FIELD-SYMBOL(<ls_target>).
        IF ls_mard-bdatr < <ls_target>-bdatr.
          INSERT ls_mard INTO rt_mard INDEX sy-tabix.
          lv_inserted = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.
      IF lv_inserted = abap_false.
        APPEND ls_mard TO rt_mard.
      ENDIF.
    ENDLOOP.

    APPEND LINES OF lt_undated TO rt_mard.
  ENDMETHOD.


  METHOD post_allocations.
    rv_ok = abap_true.
    LOOP AT it_allocations INTO DATA(ls_alloc).
      " minimum quantity threshold: keep small allocations open
      IF iv_min_qty IS NOT INITIAL AND ls_alloc-qty_alloc < iv_min_qty.
        CONTINUE.
      ENDIF.
      IF ls_alloc-qty_alloc <= 0.
        CONTINUE.
      ENDIF.
      " confirm the allocated quantity on the sales order item
      zcl_stub_sales_order=>confirm_quantity(
          iv_vbeln = ls_alloc-vbeln
          iv_posnr = ls_alloc-posnr
          iv_qty   = ls_alloc-qty_alloc ).
      " reduce unrestricted stock in the storage location (goods issue)
      zcl_stub_mard=>reduce_stock(
          iv_matnr = ls_alloc-matnr
          iv_werks = ls_alloc-werks
          iv_lgort = ls_alloc-lgort
          iv_qty   = ls_alloc-qty_alloc ).
    ENDLOOP.
  ENDMETHOD.


  METHOD get_available_stock.
    rt_mard = zcl_stub_mard=>read_by_material_plant(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ).

    " respect reservations: reduce each location's stock by the quantity
    " already reserved for other purposes
    LOOP AT rt_mard ASSIGNING FIELD-SYMBOL(<ls_mard>).
      DATA(lv_reserved) = <ls_mard>-labst
                          - zcl_stub_mard=>get_available(
                                iv_matnr = iv_matnr
                                iv_werks = iv_werks
                                iv_lgort = <ls_mard>-lgort ).
      IF lv_reserved > 0.
        <ls_mard>-labst = <ls_mard>-labst - lv_reserved.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD allocate_with_substitution.
    DATA lt_allocations TYPE tt_allocations.
    DATA lt_final TYPE tt_sub_allocations.
    DATA lv_remaining TYPE kwmeng.

    " allocate from the requested material first
    DATA(ls_result) = allocate_material(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ).
    APPEND LINES OF ls_result-allocations TO lt_allocations.
    lv_remaining = ls_result-qty_shortage.

    " try substitutes in priority order for the remaining demand
    LOOP AT zcl_stub_substitution=>get_substitutes( iv_matnr )
        INTO DATA(ls_sub).
      IF lv_remaining <= 0.
        EXIT.
      ENDIF.

      " temporarily add an order item for the remaining demand so the
      " standard allocation can serve it from the substitute material
      DATA(ls_item) = VALUE zcl_stub_sales_order=>ty_order_item(
          vbeln  = 'SUBST'
          posnr  = '000001'
          matnr  = ls_sub-sub_matnr
          kwmeng = lv_remaining
          werks  = iv_werks
          lprio  = '1' ).
      zcl_stub_sales_order=>add_item( is_item = ls_item ).

      DATA(ls_sub_result) = allocate_material(
          iv_matnr = ls_sub-sub_matnr
          iv_werks = iv_werks ).

      " map substitute allocations back to the original order item
      LOOP AT ls_sub_result-allocations INTO DATA(ls_row).
        APPEND VALUE ty_sub_allocation(
            vbeln      = ls_row-vbeln
            posnr      = ls_row-posnr
            matnr_req  = iv_matnr
            matnr_used = ls_sub-sub_matnr
            werks      = ls_row-werks
            lgort      = ls_row-lgort
            qty_alloc  = ls_row-qty_alloc ) TO rt_sub_alloc.
        lv_remaining = lv_remaining - ls_row-qty_alloc.
      ENDLOOP.
    ENDLOOP.

    " prepend the original-material allocations (converted to sub format)
    LOOP AT lt_allocations INTO ls_row.
      APPEND VALUE ty_sub_allocation(
          vbeln      = ls_row-vbeln
          posnr      = ls_row-posnr
          matnr_req  = iv_matnr
          matnr_used = iv_matnr
          werks      = ls_row-werks
          lgort      = ls_row-lgort
          qty_alloc  = ls_row-qty_alloc ) TO lt_final.
    ENDLOOP.
    APPEND LINES OF rt_sub_alloc TO lt_final.
    rt_sub_alloc = lt_final.
  ENDMETHOD.


  METHOD allocate_multi_plant.
    DATA lv_remaining TYPE kwmeng.
    DATA lt_mard TYPE tt_mard.
    DATA lv_plant_stock TYPE labst.
    DATA lv_usable TYPE labst.
    DATA lv_take TYPE kwmeng.

    " remember the safety stock for this run
    gv_safety_stock = iv_safety_stock.

    " determine total demand across all open items for this material
    DATA(lt_first) = allocate_material(
        iv_matnr = iv_matnr
        iv_werks = it_plants[ 1 ]-werks ).
    lv_remaining = lt_first-qty_shortage.

    " walk the plants in the given order, respecting safety stock
    LOOP AT it_plants INTO DATA(ls_plant).
      IF lv_remaining <= 0.
        EXIT.
      ENDIF.

      " available stock at this plant minus its safety stock
      lt_mard = get_available_stock(
          iv_matnr = iv_matnr
          iv_werks = ls_plant-werks ).

      lv_plant_stock = 0.
      LOOP AT lt_mard ASSIGNING FIELD-SYMBOL(<ls_mard>).
        lv_plant_stock = lv_plant_stock + <ls_mard>-labst.
      ENDLOOP.
      lv_usable = lv_plant_stock - gv_safety_stock.
      IF lv_usable <= 0.
        CONTINUE.
      ENDIF.

      " cap the demand at what this plant can serve
      lv_take = lv_remaining.
      IF lv_usable < lv_take.
        lv_take = lv_usable.
      ENDIF.

      " add a temporary order item so the standard allocation serves it
      zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
          vbeln  = 'MULTI'
          posnr  = '000001'
          matnr  = iv_matnr
          kwmeng = lv_take
          werks  = ls_plant-werks
          lprio  = '1' ) ).

      DATA(ls_result) = allocate_material(
          iv_matnr = iv_matnr
          iv_werks = ls_plant-werks ).

      LOOP AT ls_result-allocations INTO DATA(ls_row).
        APPEND VALUE ty_sub_allocation(
            vbeln      = ls_row-vbeln
            posnr      = ls_row-posnr
            matnr_req  = iv_matnr
            matnr_used = iv_matnr
            werks      = ls_plant-werks
            lgort      = ls_row-lgort
            qty_alloc  = ls_row-qty_alloc ) TO rt_sub_alloc.
        lv_remaining = lv_remaining - ls_row-qty_alloc.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


ENDCLASS.
