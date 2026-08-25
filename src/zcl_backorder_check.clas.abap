"! Backorder check - identifies order items that could not be (fully)
"! allocated in a run. Backorders need follow-up (expediting, procurement).
CLASS zcl_backorder_check DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_backorder,
             vbeln    TYPE vbap-vbeln,
             posnr    TYPE vbap-posnr,
             matnr    TYPE vbap-matnr,
             qty_open TYPE kwmeng,   " quantity still missing
           END OF ty_backorder.
    TYPES tt_backorders TYPE STANDARD TABLE OF ty_backorder WITH DEFAULT KEY.

    "! Detect backorders: compare what was requested per order item with
    "! what was allocated. Items fully covered are not reported.
    CLASS-METHODS detect
      IMPORTING
        it_allocations       TYPE zcl_stock_allocator=>tt_allocations
        it_open_items        TYPE zcl_stub_sales_order=>tt_order_items
      RETURNING
        VALUE(rt_backorders) TYPE tt_backorders.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_backorder_check IMPLEMENTATION.


  METHOD detect.
    DATA lv_allocated TYPE kwmeng.

    LOOP AT it_open_items INTO DATA(ls_item).
      " sum the allocations for this order item
      lv_allocated = 0.
      LOOP AT it_allocations INTO DATA(ls_alloc)
          WHERE vbeln = ls_item-vbeln AND posnr = ls_item-posnr.
        lv_allocated = lv_allocated + ls_alloc-qty_alloc.
      ENDLOOP.

      " open quantity remains -> backorder
      IF ls_item-kwmeng > lv_allocated.
        APPEND VALUE ty_backorder(
            vbeln    = ls_item-vbeln
            posnr    = ls_item-posnr
            matnr    = ls_item-matnr
            qty_open = ls_item-kwmeng - lv_allocated ) TO rt_backorders.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


ENDCLASS.
