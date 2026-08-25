"! SAP standard stub: sales order reading/writing (VBAK/VBAP via BAPI-like API)
"! Simulates reading sales order documents for allocation processing.
CLASS zcl_stub_sales_order DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_order_item,
             vbeln  TYPE vbap-vbeln,
             posnr  TYPE vbap-posnr,
             matnr  TYPE vbap-matnr,
             kwmeng TYPE vbap-kwmeng,   " order quantity
             vrkme  TYPE vbap-vrkme,    " sales unit
             werks  TYPE vbap-werks,
             lgort  TYPE vbap-lgort,
             lprio  TYPE lprio,         " delivery priority (1 = highest)
             auart  TYPE char4,         " sales document type
             edatu  TYPE edatu,         " requested delivery date
             maxpw  TYPE i,             " max partial deliveries allowed
                                           " 0 = full delivery only
           END OF ty_order_item.
    TYPES tt_order_items TYPE STANDARD TABLE OF ty_order_item WITH DEFAULT KEY.

    "! Read open order items for a material at a plant
    CLASS-METHODS read_open_items
      IMPORTING
        iv_matnr        TYPE matnr
        iv_werks        TYPE werks_d
      RETURNING
        VALUE(rt_items) TYPE tt_order_items.

    "! Read open items with requested delivery date up to iv_date
    "! (items due later are excluded - their stock stays free)
    CLASS-METHODS read_open_items_until
      IMPORTING
        iv_matnr        TYPE matnr
        iv_werks        TYPE werks_d
        iv_date         TYPE edatu
      RETURNING
        VALUE(rt_items) TYPE tt_order_items.

    "! Test helper: create a simulated open order item
    CLASS-METHODS add_item
      IMPORTING
        is_item TYPE ty_order_item.

    "! Test helper: confirm quantity on an item (simulates delivery confirmation)
    CLASS-METHODS confirm_quantity
      IMPORTING
        iv_vbeln TYPE vbap-vbeln
        iv_posnr TYPE vbap-posnr
        iv_qty   TYPE kwmeng.

    "! Test helper: clear all simulated orders
    CLASS-METHODS clear.

    "! Test helper: number of open items currently simulated
    CLASS-METHODS count_items
      RETURNING
        VALUE(rv_count) TYPE i.

    "! Block an order type: its items are excluded from allocation
    CLASS-METHODS block_order_type
      IMPORTING
        iv_auart TYPE char4.

    "! Unblock an order type
    CLASS-METHODS unblock_order_type
      IMPORTING
        iv_auart TYPE char4.

    "! Check whether an order type is blocked
    CLASS-METHODS is_blocked
      IMPORTING
        iv_auart          TYPE char4
      RETURNING
        VALUE(rv_blocked) TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA gt_items TYPE tt_order_items.
    CLASS-DATA gt_blocked_types TYPE STANDARD TABLE OF char4 WITH DEFAULT KEY.

ENDCLASS.



CLASS zcl_stub_sales_order IMPLEMENTATION.


  METHOD read_open_items.
    LOOP AT gt_items INTO DATA(ls_item)
        WHERE matnr = iv_matnr AND werks = iv_werks.
      " skip items of blocked order types
      IF is_blocked( ls_item-auart ) = abap_true.
        CONTINUE.
      ENDIF.
      APPEND ls_item TO rt_items.
    ENDLOOP.
  ENDMETHOD.


  METHOD read_open_items_until.
    " items without a delivery date are always due (treated as urgent);
    " dated items are included only if due on or before iv_date
    LOOP AT read_open_items(
             iv_matnr = iv_matnr
             iv_werks = iv_werks ) INTO DATA(ls_item).
      IF ls_item-edatu IS NOT INITIAL AND ls_item-edatu > iv_date.
        CONTINUE.
      ENDIF.
      APPEND ls_item TO rt_items.
    ENDLOOP.
  ENDMETHOD.


  METHOD add_item.
    APPEND is_item TO gt_items.
  ENDMETHOD.


  METHOD confirm_quantity.
    READ TABLE gt_items ASSIGNING FIELD-SYMBOL(<ls_item>)
      WITH KEY vbeln = iv_vbeln posnr = iv_posnr.
    IF sy-subrc = 0.
      <ls_item>-kwmeng = <ls_item>-kwmeng - iv_qty.
      IF <ls_item>-kwmeng <= 0.
        DELETE gt_items WHERE vbeln = iv_vbeln AND posnr = iv_posnr.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD clear.
    CLEAR gt_items.
    CLEAR gt_blocked_types.
  ENDMETHOD.


  METHOD count_items.
    rv_count = lines( gt_items ).
  ENDMETHOD.


  METHOD block_order_type.
    IF is_blocked( iv_auart ) = abap_false.
      APPEND iv_auart TO gt_blocked_types.
    ENDIF.
  ENDMETHOD.


  METHOD unblock_order_type.
    DELETE gt_blocked_types WHERE table_line = iv_auart.
  ENDMETHOD.


  METHOD is_blocked.
    READ TABLE gt_blocked_types TRANSPORTING NO FIELDS
      WITH KEY table_line = iv_auart.
    rv_blocked = boolc( sy-subrc = 0 ).
  ENDMETHOD.


ENDCLASS.
