CLASS zcl_so_demand_reader DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

  PRIVATE SECTION.

    "! One open sales order item joined with the header data the allocation
    "! needs. Declared explicitly rather than inferred with INTO TABLE @DATA(),
    "! see ANOMALIES.md.
    TYPES:
      BEGIN OF ty_item,
        vbeln  TYPE vbap-vbeln,
        posnr  TYPE vbap-posnr,
        matnr  TYPE vbap-matnr,
        werks  TYPE vbap-werks,
        kwmeng TYPE vbap-kwmeng,
        lprio  TYPE vbap-lprio,
        vdatu  TYPE vbak-vdatu,
      END OF ty_item.
    TYPES ty_item_tab TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.

    "! Sales order items without a delivery priority sort last rather than
    "! first, which is what LPRIO = '00' would otherwise do.
    CONSTANTS c_lowest_priority TYPE zif_allocation=>ty_priority VALUE '99'.

    METHODS build_demand_id
      IMPORTING
        iv_vbeln            TYPE vbap-vbeln
        iv_posnr            TYPE vbap-posnr
      RETURNING
        VALUE(rv_demand_id) TYPE zif_allocation=>ty_demand_id.

ENDCLASS.


CLASS zcl_so_demand_reader IMPLEMENTATION.

  METHOD zif_demand_reader~read_open_demand.

    DATA lt_item TYPE ty_item_tab.

    SELECT item~vbeln,
           item~posnr,
           item~matnr,
           item~werks,
           item~kwmeng,
           item~lprio,
           header~vdatu
      FROM vbap AS item
      INNER JOIN vbak AS header ON header~vbeln = item~vbeln
      WHERE item~matnr = @iv_matnr
        AND item~werks = @iv_werks
        AND item~abgru = @space
        AND header~lifsk = @space
      ORDER BY item~vbeln, item~posnr
      INTO TABLE @lt_item.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT lt_item INTO DATA(ls_item).
      APPEND VALUE #(
        demand_id = build_demand_id(
          iv_vbeln = ls_item-vbeln
          iv_posnr = ls_item-posnr )
        matnr     = ls_item-matnr
        werks     = ls_item-werks
        quantity  = ls_item-kwmeng
        req_date  = ls_item-vdatu
        priority  = COND #( WHEN ls_item-lprio IS INITIAL
                            THEN c_lowest_priority
                            ELSE ls_item-lprio ) ) TO rt_demand.
    ENDLOOP.

  ENDMETHOD.

  METHOD build_demand_id.

    rv_demand_id+0(10) = iv_vbeln.
    rv_demand_id+10(6) = iv_posnr.

  ENDMETHOD.

ENDCLASS.
