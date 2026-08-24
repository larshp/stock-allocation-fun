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
           END OF ty_order_item.
    TYPES tt_order_items TYPE STANDARD TABLE OF ty_order_item WITH DEFAULT KEY.

    "! Read open order items for a material at a plant
    CLASS-METHODS read_open_items
      IMPORTING
        iv_matnr        TYPE matnr
        iv_werks        TYPE werks_d
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

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA gt_items TYPE tt_order_items.

ENDCLASS.



CLASS zcl_stub_sales_order IMPLEMENTATION.


  METHOD read_open_items.
    LOOP AT gt_items INTO DATA(ls_item)
        WHERE matnr = iv_matnr AND werks = iv_werks.
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
  ENDMETHOD.


ENDCLASS.
