CLASS zcl_so_demand_reader DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    "! `VBAK-CMGST`: the credit check has blocked the document. The other
    "! values -- not carried out, released, partly released -- all leave an
    "! order that can be delivered.
    CONSTANTS c_credit_blocked TYPE vbak-cmgst VALUE 'B'.
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
        kztlf  TYPE vbap-kztlf,
        kunnr  TYPE vbak-kunnr,
        vdatu  TYPE vbak-vdatu,
        autlf  TYPE vbak-autlf,
      END OF ty_item.
    TYPES ty_item_tab TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.

    "! A schedule line of such an item: a quantity wanted on a date.
    TYPES:
      BEGIN OF ty_schedule,
        vbeln TYPE vbep-vbeln,
        posnr TYPE vbep-posnr,
        etenr TYPE vbep-etenr,
        edatu TYPE vbep-edatu,
        wmeng TYPE vbep-wmeng,
        lifsp TYPE vbep-lifsp,
      END OF ty_schedule.
    TYPES ty_schedule_tab TYPE STANDARD TABLE OF ty_schedule WITH EMPTY KEY.

    "! What one delivery item has already taken off a sales order item, in the
    "! base unit of measure.
    TYPES:
      BEGIN OF ty_delivered,
        vbeln    TYPE vbap-vbeln,
        posnr    TYPE vbap-posnr,
        quantity TYPE zif_allocation=>ty_quantity,
      END OF ty_delivered.
    TYPES ty_delivered_tab TYPE STANDARD TABLE OF ty_delivered WITH EMPTY KEY.

    "! Sales order items without a delivery priority sort last rather than
    "! first, which is what LPRIO = '00' would otherwise do.
    CONSTANTS c_lowest_priority TYPE zif_allocation=>ty_priority VALUE '99'.

    "! Reference document category of a delivery item created from a sales
    "! order, LIPS-VGTYP.
    CONSTANTS c_reference_is_order TYPE lips-vgtyp VALUE 'C'.

    "! VBAP-KZTLF: the customer takes this item in one delivery or not at all.
    "! Every other value allows the item to ship in parts.
    CONSTANTS c_complete_delivery TYPE vbap-kztlf VALUE 'C'.

    "! VBAK-AUTLF: the customer takes the whole order in one delivery. It is a
    "! stronger rule than the one on the item, because it ties the lines of the
    "! order to each other rather than each line to itself.
    CONSTANTS c_complete_order TYPE vbak-autlf VALUE 'X'.

    METHODS build_demand_id
      IMPORTING
        iv_vbeln            TYPE vbap-vbeln
        iv_posnr            TYPE vbap-posnr
        iv_etenr            TYPE vbep-etenr
      RETURNING
        VALUE(rv_demand_id) TYPE zif_allocation=>ty_demand_id.

    METHODS read_items
      IMPORTING
        iv_matnr       TYPE mard-matnr
        iv_werks       TYPE mard-werks
      RETURNING
        VALUE(rt_item) TYPE ty_item_tab.

    METHODS read_schedules
      IMPORTING
        iv_matnr           TYPE mard-matnr
        iv_werks           TYPE mard-werks
      RETURNING
        VALUE(rt_schedule) TYPE ty_schedule_tab.

    METHODS schedules_of
      IMPORTING
        is_item            TYPE ty_item
        it_schedule        TYPE ty_schedule_tab
      RETURNING
        VALUE(rt_schedule) TYPE ty_schedule_tab.

    METHODS read_deliveries
      IMPORTING
        iv_matnr            TYPE mard-matnr
        iv_werks            TYPE mard-werks
      RETURNING
        VALUE(rt_delivered) TYPE ty_delivered_tab.

    METHODS delivered
      IMPORTING
        it_delivered       TYPE ty_delivered_tab
        iv_vbeln           TYPE vbap-vbeln
        iv_posnr           TYPE vbap-posnr
      RETURNING
        VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity.

ENDCLASS.


CLASS zcl_so_demand_reader IMPLEMENTATION.

  METHOD constructor.
    mo_converter = io_converter.
  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.

    " typed explicitly, see ANOMALIES.md
    DATA lv_open      TYPE zif_allocation=>ty_quantity.
    DATA lv_delivered TYPE zif_allocation=>ty_quantity.

    DATA(lt_item)      = read_items(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).
    DATA(lt_schedule)  = read_schedules(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).
    DATA(lt_delivered) = read_deliveries(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    LOOP AT lt_item INTO DATA(ls_item).

      lv_delivered = delivered(
        it_delivered = lt_delivered
        iv_vbeln     = ls_item-vbeln
        iv_posnr     = ls_item-posnr ).

      DATA(lt_line) = schedules_of(
        is_item     = ls_item
        it_schedule = lt_schedule ).

      LOOP AT lt_line INTO DATA(ls_line).

        " the order is in sales units, the stock is in base units. Comparing
        " them without converting would allocate a carton against a piece.
        lv_open = mo_converter->to_base(
          iv_matnr    = ls_item-matnr
          iv_quantity = CONV #( ls_line-wmeng )
          iv_uom      = ls_item-vrkme ).

        " and one of those sales units is this many base units, which is what
        " a confirmation has to be a whole number of where the plant asks for
        " it. The converter buffers the material master, so this is free.
        DATA(lv_unit) = mo_converter->to_base(
          iv_matnr    = ls_item-matnr
          iv_quantity = 1
          iv_uom      = ls_item-vrkme ).

        IF lv_open <= 0.
          CONTINUE.
        ENDIF.

        " what has been delivered is counted against the earliest schedule
        " lines, which is the order the goods actually leave in
        IF lv_delivered > 0.
          IF lv_delivered >= lv_open.
            lv_delivered = lv_delivered - lv_open.
            CONTINUE.
          ENDIF.
          lv_open = lv_open - lv_delivered.
          CLEAR lv_delivered.
        ENDIF.

        APPEND VALUE #(
          demand_id  = build_demand_id(
            iv_vbeln = ls_line-vbeln
            iv_posnr = ls_line-posnr
            iv_etenr = ls_line-etenr )
          matnr      = ls_item-matnr
          werks      = ls_item-werks
          quantity   = lv_open
          req_date   = ls_line-edatu
          priority   = COND #( WHEN ls_item-lprio IS INITIAL
                               THEN c_lowest_priority
                               ELSE ls_item-lprio )
          complete   = xsdbool( ls_item-kztlf = c_complete_delivery )
          customer   = ls_item-kunnr
          unit_size  = lv_unit
          " an order the customer takes in one delivery makes every line of it
          " wait for the others, so the document number is what the lines of
          " the group have in common
          ship_group = COND #( WHEN ls_item-autlf = c_complete_order
                               THEN ls_line-vbeln
                               ELSE space ) ) TO rt_demand.

      ENDLOOP.

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
        AND item~lifsp = @space
        AND item~sobkz = @space
        AND header~lifsk = @space
        AND header~cmgst <> @c_credit_blocked
      ORDER BY item~matnr
      INTO TABLE @rt_matnr.
    IF sy-subrc <> 0.
      CLEAR rt_matnr.
      RETURN.
    ENDIF.

    DELETE ADJACENT DUPLICATES FROM rt_matnr.

  ENDMETHOD.

  METHOD read_items.

    " an order the credit check has blocked cannot be delivered either, and
    " stock earmarked for one is stock not offered to an order that can ship.
    " Nothing is lost by leaving it out: the block is released by somebody in
    " finance rather than by this run, and the next run after that picks the
    " order up like any other.
    "
    " a delivery block can sit on the header, on the item or on a single
    " schedule line, and wherever it sits it says the goods are not to leave.
    " Two of the three are answered here; the third is answered per line, in
    " SCHEDULES_OF.
    "
    " An item with a special stock indicator is served from a stock segment of
    " its own -- sales order stock, project stock -- which is in MSKA or MSPR
    " and not in the MARD this run gives away. It has its own goods to wait
    " for, and letting it compete here would take anonymous stock away from the
    " items that have nothing else.
    SELECT item~vbeln,
           item~posnr,
           item~matnr,
           item~werks,
           item~kwmeng,
           item~vrkme,
           item~lprio,
           item~kztlf,
           header~kunnr,
           header~vdatu,
           header~autlf
      FROM vbap AS item
      INNER JOIN vbak AS header ON header~vbeln = item~vbeln
      WHERE item~matnr = @iv_matnr
        AND item~werks = @iv_werks
        AND item~abgru = @space
        AND item~lifsp = @space
        AND item~sobkz = @space
        AND header~lifsk = @space
        AND header~cmgst <> @c_credit_blocked
      ORDER BY item~vbeln, item~posnr
      INTO TABLE @rt_item.
    IF sy-subrc <> 0.
      CLEAR rt_item.
    ENDIF.

  ENDMETHOD.

  METHOD read_schedules.

    " VBEP carries no material, so it is joined to VBAP to stay selective
    " a blocked schedule line is read like any other and dropped afterwards:
    " whether an item has schedule lines at all decides how it is read, and
    " that question has to be answered before the blocked ones are taken out
    SELECT sched~vbeln,
           sched~posnr,
           sched~etenr,
           sched~edatu,
           sched~wmeng,
           sched~lifsp
      FROM vbep AS sched
      INNER JOIN vbap AS item ON item~vbeln = sched~vbeln
                             AND item~posnr = sched~posnr
      WHERE item~matnr = @iv_matnr
        AND item~werks = @iv_werks
        AND item~abgru = @space
      ORDER BY sched~vbeln, sched~posnr, sched~etenr
      INTO TABLE @rt_schedule.
    IF sy-subrc <> 0.
      CLEAR rt_schedule.
    ENDIF.

  ENDMETHOD.

  METHOD schedules_of.

    DATA lt_line TYPE ty_schedule_tab.

    LOOP AT it_schedule INTO DATA(ls_schedule)
        WHERE vbeln = is_item-vbeln
          AND posnr = is_item-posnr.
      APPEND ls_schedule TO lt_line.
    ENDLOOP.

    " an item with no schedule line of its own is one requirement for the whole
    " order quantity, on the date the order asks for. Ignoring it would lose
    " real demand, and a schedule line is only where a date gets more precise.
    IF lt_line IS INITIAL.
      APPEND VALUE #(
        vbeln = is_item-vbeln
        posnr = is_item-posnr
        etenr = '0000'
        edatu = is_item-vdatu
        wmeng = is_item-kwmeng ) TO rt_schedule.
      RETURN.
    ENDIF.

    " a blocked schedule line is not going to ship, so it takes no stock. The
    " item keeps whatever else it has: a block on one date says nothing about
    " the others. An item whose every line is blocked falls out here rather
    " than through the branch above, which would have handed it the whole
    " order quantity back.
    LOOP AT lt_line INTO ls_schedule.
      IF ls_schedule-lifsp IS INITIAL.
        APPEND ls_schedule TO rt_schedule.
      ENDIF.
    ENDLOOP.

    " earliest first, which is both the order the goods leave in and the order
    " the delivered quantity has to be counted against
    SORT rt_schedule BY edatu ASCENDING etenr ASCENDING.

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
        vbeln    = ls_row-vgbel
        posnr    = ls_row-vgpos
        quantity = ls_row-lgmng ) TO rt_delivered.
    ENDLOOP.

  ENDMETHOD.

  METHOD delivered.

    " an order item can be delivered in several goes, so the deliveries of one
    " item add up. A cancelled delivery item is gone from LIPS, not negative,
    " and a quantity that is not positive takes nothing off.
    LOOP AT it_delivered INTO DATA(ls_delivered)
        WHERE vbeln = iv_vbeln
          AND posnr = iv_posnr.
      IF ls_delivered-quantity > 0.
        rv_quantity = rv_quantity + ls_delivered-quantity.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD build_demand_id.

    rv_demand_id+0(10)  = iv_vbeln.
    rv_demand_id+10(6)  = iv_posnr.
    rv_demand_id+16(4)  = iv_etenr.

  ENDMETHOD.

ENDCLASS.
