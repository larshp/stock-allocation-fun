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
             qty_req   TYPE kwmeng,         " requested quantity
             qty_alloc TYPE kwmeng,         " allocated quantity
           END OF ty_allocation.
    TYPES tt_allocations TYPE STANDARD TABLE OF ty_allocation WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             allocations  TYPE tt_allocations,
             qty_shortage TYPE kwmeng,       " total unallocated quantity
             messages     TYPE zcl_stub_message=>tt_message, " log messages
           END OF ty_result.

    "! Run allocation for one material at a plant across all storage locations
    CLASS-METHODS allocate_material
      IMPORTING
        iv_matnr         TYPE matnr
        iv_werks         TYPE werks_d
      RETURNING
        VALUE(rs_result) TYPE ty_result.

    "! Post allocations: confirm quantities on the sales order items and
    "! reduce unrestricted stock in the storage locations (goods issue).
    CLASS-METHODS post_allocations
      IMPORTING
        it_allocations TYPE tt_allocations
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

ENDCLASS.



CLASS zcl_stock_allocator IMPLEMENTATION.


  METHOD allocate_material.
    DATA lv_remaining TYPE kwmeng.
    DATA lv_qty_take  TYPE kwmeng.

    " get stock per storage location
    DATA(lt_mard) = get_available_stock(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ).

    " get open order items sorted FIFO by document/item
    DATA(lt_items) = zcl_stub_sales_order=>read_open_items(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ).
    SORT lt_items BY vbeln posnr.

    LOOP AT lt_items INTO DATA(ls_item).
      DATA(ls_alloc) = VALUE ty_allocation(
          vbeln   = ls_item-vbeln
          posnr   = ls_item-posnr
          matnr   = ls_item-matnr
          werks   = ls_item-werks
          qty_req = ls_item-kwmeng ).

      lv_remaining = ls_item-kwmeng.

      " fulfill from storage locations in order (FIFO over MARD rows)
      LOOP AT lt_mard ASSIGNING FIELD-SYMBOL(<ls_mard>).
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
        ls_alloc-lgort     = <ls_mard>-lgort.
        ls_alloc-qty_alloc = ls_alloc-qty_alloc + lv_qty_take.
        lv_remaining       = lv_remaining - lv_qty_take.
        " consume the stock so following order items see reduced quantity
        <ls_mard>-labst    = <ls_mard>-labst - lv_qty_take.
      ENDLOOP.

      rs_result-qty_shortage = rs_result-qty_shortage + lv_remaining.

      " log the allocation outcome for the order item
      IF lv_remaining <= 0.
        APPEND zcl_stub_message=>build(
            iv_msgty = 'S'
            iv_msgno = zcl_stub_message=>gc_msgno-full_alloc
            iv_msgv1 = CONV symsgv( ls_item-vbeln ) ) TO rs_result-messages.
      ELSEIF ls_alloc-qty_alloc > 0.
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

      APPEND ls_alloc TO rs_result-allocations.
    ENDLOOP.
  ENDMETHOD.


  METHOD post_allocations.
    rv_ok = abap_true.
    LOOP AT it_allocations INTO DATA(ls_alloc).
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
