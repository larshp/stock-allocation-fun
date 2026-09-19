CLASS zcl_supply_production DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_supply_reader.

    "! <p class="shorttext synchronized">Wire up the reader</p>
    "!
    "! @parameter io_converter | <p class="shorttext synchronized">Turns order units into base units</p>
    METHODS constructor
      IMPORTING
        io_converter TYPE REF TO zif_unit_converter.

  PRIVATE SECTION.

    "! System statuses that say an order will not deliver anything more:
    "! technically complete, closed, and flagged for deletion. They are the
    "! numbers behind the mnemonics maintained in TJ02, and there is no field on
    "! the order that carries them.
    CONSTANTS c_status_teco TYPE jest-stat VALUE 'I0045'.
    CONSTANTS c_status_clsd TYPE jest-stat VALUE 'I0046'.
    CONSTANTS c_status_dlfl TYPE jest-stat VALUE 'I0076'.

    "! One item of a production order that is still to deliver into the plant,
    "! with the dates that could say when. Declared explicitly rather than
    "! inferred with INTO TABLE @DATA(), see ANOMALIES.md.
    TYPES:
      BEGIN OF ty_item,
        aufnr TYPE afpo-aufnr,
        posnr TYPE afpo-posnr,
        meins TYPE afpo-meins,
        psmng TYPE afpo-psmng,
        wemng TYPE afpo-wemng,
        ltrmp TYPE afpo-ltrmp,
        gltrs TYPE afko-gltrs,
        gltrp TYPE afko-gltrp,
        objnr TYPE aufk-objnr,
      END OF ty_item.
    TYPES ty_item_tab TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.

    TYPES ty_objnr_tab TYPE STANDARD TABLE OF aufk-objnr WITH EMPTY KEY.

    DATA mo_converter TYPE REF TO zif_unit_converter.

    METHODS read_items
      IMPORTING
        iv_matnr       TYPE mard-matnr
        iv_werks       TYPE mard-werks
      RETURNING
        VALUE(rt_item) TYPE ty_item_tab.

    METHODS read_stopped_orders
      IMPORTING
        iv_matnr        TYPE mard-matnr
        iv_werks        TYPE mard-werks
      RETURNING
        VALUE(rt_objnr) TYPE ty_objnr_tab.

    METHODS finish_date_of
      IMPORTING
        is_item        TYPE ty_item
      RETURNING
        VALUE(rv_date) TYPE d.

ENDCLASS.


CLASS zcl_supply_production IMPLEMENTATION.

  METHOD constructor.
    mo_converter = io_converter.
  ENDMETHOD.

  METHOD zif_supply_reader~read_supply.

    " typed explicitly, see ANOMALIES.md
    DATA lv_open TYPE afpo-psmng.

    DATA(lt_item)    = read_items(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).
    DATA(lt_stopped) = read_stopped_orders(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    LOOP AT lt_item INTO DATA(ls_item).

      " an order that is technically complete, closed or flagged for deletion
      " will not deliver the rest of its quantity, whatever is still open on it
      IF line_exists( lt_stopped[ table_line = ls_item-objnr ] ).
        CONTINUE.
      ENDIF.

      " what has been delivered to stock is in MARD already and is read as
      " stock on hand. Counting it here as well would allocate it twice.
      lv_open = ls_item-psmng - ls_item-wemng.
      IF lv_open <= 0.
        CONTINUE.
      ENDIF.

      DATA(lv_date) = finish_date_of( ls_item ).
      IF lv_date IS INITIAL.
        CONTINUE.
      ENDIF.

      " the order item carries its own unit, the stock is in base units
      APPEND VALUE #(
        avail_date = lv_date
        quantity   = mo_converter->to_base(
          iv_matnr    = iv_matnr
          iv_quantity = CONV #( lv_open )
          iv_uom      = ls_item-meins ) ) TO rt_supply.

    ENDLOOP.

  ENDMETHOD.

  METHOD read_items.

    " AFPO-DWERK is the receiving plant: this is the plant the order delivers
    " into, which is not always the plant it is produced in.
    "
    " An order that has not been released yet is still a receipt. MRP plans
    " against it, the material is expected on the day it says, and leaving it
    " out would hold stock back from demand that the order is there to cover.
    " What takes an order out of supply is the deletion indicator on the order
    " master, the delivery completed indicator on the item, and the statuses
    " read below.
    SELECT item~aufnr,
           item~posnr,
           item~meins,
           item~psmng,
           item~wemng,
           item~ltrmp,
           header~gltrs,
           header~gltrp,
           master~objnr
      FROM afpo AS item
      INNER JOIN afko AS header ON header~aufnr = item~aufnr
      INNER JOIN aufk AS master ON master~aufnr = item~aufnr
      WHERE item~matnr = @iv_matnr
        AND item~dwerk = @iv_werks
        AND item~elikz = @space
        AND master~loekz = @space
      ORDER BY item~aufnr, item~posnr
      INTO TABLE @rt_item.
    IF sy-subrc <> 0.
      CLEAR rt_item.
    ENDIF.

  ENDMETHOD.

  METHOD read_stopped_orders.

    " JEST carries no material or plant, so it is joined through the order
    " master to the order items to stay selective. An inactive row is a status
    " the order used to have and no longer has.
    SELECT status~objnr
      FROM jest AS status
      INNER JOIN aufk AS master ON master~objnr = status~objnr
      INNER JOIN afpo AS item ON item~aufnr = master~aufnr
      WHERE item~matnr = @iv_matnr
        AND item~dwerk = @iv_werks
        AND status~inact = @space
        AND ( status~stat = @c_status_teco
           OR status~stat = @c_status_clsd
           OR status~stat = @c_status_dlfl )
      ORDER BY status~objnr
      INTO TABLE @rt_objnr.
    IF sy-subrc <> 0.
      CLEAR rt_objnr.
    ENDIF.

  ENDMETHOD.

  METHOD finish_date_of.

    " the closest thing to a promise wins: the item's own delivery date is what
    " the order says about this material, the scheduled finish is what
    " scheduling worked out for the order, and the basic finish is what
    " somebody asked for when the order was created.
    "
    " An order with none of the three says nothing about when it delivers, and
    " placing it on the timeline would mean calling it available now. It is
    " left out, the same way a purchasing item without a schedule line is.
    rv_date = is_item-ltrmp.
    IF rv_date IS INITIAL.
      rv_date = is_item-gltrs.
    ENDIF.
    IF rv_date IS INITIAL.
      rv_date = is_item-gltrp.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
