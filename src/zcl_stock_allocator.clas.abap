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


  METHOD allocate_from_sorted.
    DATA lv_remaining TYPE kwmeng.
    DATA lv_qty_take  TYPE kwmeng.

    " get open order items sorted by priority, then FIFO by document/item
    DATA(lt_items) = zcl_stub_sales_order=>read_open_items(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ).
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

      " fulfill from storage locations in order; one allocation row per
      " storage location so every row references exactly one SLoc
      LOOP AT it_mard ASSIGNING FIELD-SYMBOL(<ls_mard>).
        IF lv_remaining <= 0.
          EXIT.
        ENDIF.
        IF <ls_mard>-labst <= 0.
          CONTINUE.
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
  ENDMETHOD.


ENDCLASS.
