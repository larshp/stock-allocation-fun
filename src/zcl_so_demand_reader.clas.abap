CLASS zcl_so_demand_reader DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    "! <p class="shorttext synchronized">Wire up the reader</p>
    "!
    "! @parameter io_converter | <p class="shorttext synchronized">Turns sales units into base units</p>
    METHODS constructor
      IMPORTING
        io_converter TYPE REF TO zif_unit_converter.

  PRIVATE SECTION.

    DATA mo_converter TYPE REF TO zif_unit_converter.

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
        vrkme  TYPE vbap-vrkme,
        lprio  TYPE vbap-lprio,
        vdatu  TYPE vbak-vdatu,
      END OF ty_item.
    TYPES ty_item_tab TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.

    "! What one delivery item has already taken off a sales order item, in the
    "! base unit of measure.
    TYPES:
      BEGIN OF ty_delivered,
        demand_id TYPE zif_allocation=>ty_demand_id,
        quantity  TYPE zif_allocation=>ty_quantity,
      END OF ty_delivered.
    TYPES ty_delivered_tab TYPE STANDARD TABLE OF ty_delivered WITH EMPTY KEY.

    "! Sales order items without a delivery priority sort last rather than
    "! first, which is what LPRIO = '00' would otherwise do.
    CONSTANTS c_lowest_priority TYPE zif_allocation=>ty_priority VALUE '99'.

    "! Reference document category of a delivery item created from a sales
    "! order, LIPS-VGTYP.
    CONSTANTS c_reference_is_order TYPE lips-vgtyp VALUE 'C'.

    METHODS build_demand_id
      IMPORTING
        iv_vbeln            TYPE vbap-vbeln
        iv_posnr            TYPE vbap-posnr
      RETURNING
        VALUE(rv_demand_id) TYPE zif_allocation=>ty_demand_id.

    METHODS read_deliveries
      IMPORTING
        iv_matnr            TYPE mard-matnr
        iv_werks            TYPE mard-werks
      RETURNING
        VALUE(rt_delivered) TYPE ty_delivered_tab.

    METHODS delivered
      IMPORTING
        it_delivered       TYPE ty_delivered_tab
        iv_demand_id       TYPE zif_allocation=>ty_demand_id
      RETURNING
        VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity.

ENDCLASS.


CLASS zcl_so_demand_reader IMPLEMENTATION.

  METHOD constructor.
    mo_converter = io_converter.
  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.

    DATA lt_item TYPE ty_item_tab.
    " typed explicitly, see ANOMALIES.md
    DATA lv_open TYPE zif_allocation=>ty_quantity.

    SELECT item~vbeln,
           item~posnr,
           item~matnr,
           item~werks,
           item~kwmeng,
           item~vrkme,
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

    DATA(lt_delivered) = read_deliveries(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    LOOP AT lt_item INTO DATA(ls_item).

      DATA(lv_demand_id) = build_demand_id(
        iv_vbeln = ls_item-vbeln
        iv_posnr = ls_item-posnr ).

      " the order is in sales units, the stock is in base units. Comparing them
      " without converting would allocate a carton against a piece.
      DATA(lv_quantity) = mo_converter->to_base(
        iv_matnr    = ls_item-matnr
        iv_quantity = CONV #( ls_item-kwmeng )
        iv_uom      = ls_item-vrkme ).

      " KWMENG is the whole order quantity, including the part that has left
      " the plant already. What is still open is what has not been delivered.
      lv_open = lv_quantity - delivered(
        it_delivered = lt_delivered
        iv_demand_id = lv_demand_id ).

      IF lv_open <= 0.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        demand_id = lv_demand_id
        matnr     = ls_item-matnr
        werks     = ls_item-werks
        quantity  = lv_open
        req_date  = ls_item-vdatu
        priority  = COND #( WHEN ls_item-lprio IS INITIAL
                            THEN c_lowest_priority
                            ELSE ls_item-lprio ) ) TO rt_demand.
    ENDLOOP.

  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.

    " a material with demand on several orders comes back once per item. The
    " duplicates are removed here rather than with SELECT DISTINCT, which the
    " transpiler drops from the statement, see ANOMALIES.md.
    SELECT item~matnr AS matnr
      FROM vbap AS item
      INNER JOIN vbak AS header ON header~vbeln = item~vbeln
      WHERE item~werks = @iv_werks
        AND item~abgru = @space
        AND header~lifsk = @space
      ORDER BY item~matnr
      INTO TABLE @rt_matnr.
    IF sy-subrc <> 0.
      CLEAR rt_matnr.
      RETURN.
    ENDIF.

    DELETE ADJACENT DUPLICATES FROM rt_matnr.

  ENDMETHOD.

  METHOD build_demand_id.

    rv_demand_id+0(10) = iv_vbeln.
    rv_demand_id+10(6) = iv_posnr.

  ENDMETHOD.

  METHOD read_deliveries.

    TYPES:
      BEGIN OF ty_row,
        vgbel TYPE lips-vgbel,
        vgpos TYPE lips-vgpos,
        lgmng TYPE lips-lgmng,
      END OF ty_row.
    DATA lt_row TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    " LGMNG is the delivered quantity in the base unit of measure, which is the
    " unit everything here works in, so this side needs no conversion.
    SELECT vgbel,
           vgpos,
           lgmng
      FROM lips
      WHERE matnr = @iv_matnr
        AND werks = @iv_werks
        AND vgtyp = @c_reference_is_order
      ORDER BY vgbel, vgpos
      INTO TABLE @lt_row.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT lt_row INTO DATA(ls_row).
      APPEND VALUE #(
        demand_id = build_demand_id(
          iv_vbeln = CONV #( ls_row-vgbel )
          iv_posnr = CONV #( ls_row-vgpos ) )
        quantity  = ls_row-lgmng ) TO rt_delivered.
    ENDLOOP.

  ENDMETHOD.

  METHOD delivered.

    " an order item can be delivered in several goes, so the deliveries of one
    " item add up. A cancelled delivery item is gone from LIPS, not negative,
    " and a quantity that is not positive takes nothing off.
    LOOP AT it_delivered INTO DATA(ls_delivered) WHERE demand_id = iv_demand_id.
      IF ls_delivered-quantity > 0.
        rv_quantity = rv_quantity + ls_delivered-quantity.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
