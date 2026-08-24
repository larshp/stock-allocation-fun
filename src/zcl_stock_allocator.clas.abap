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
           END OF ty_result.

    "! Run allocation for one material at a plant across all storage locations
    CLASS-METHODS allocate_material
      IMPORTING
        iv_matnr         TYPE matnr
        iv_werks         TYPE werks_d
      RETURNING
        VALUE(rs_result) TYPE ty_result.

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
      ENDLOOP.

      rs_result-qty_shortage = rs_result-qty_shortage + lv_remaining.
      APPEND ls_alloc TO rs_result-allocations.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_available_stock.
    rt_mard = zcl_stub_mard=>read_by_material_plant(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ).
  ENDMETHOD.


ENDCLASS.
