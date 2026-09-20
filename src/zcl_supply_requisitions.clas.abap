CLASS zcl_supply_requisitions DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_supply_reader.

    "! <p class="shorttext synchronized">Wire up the reader</p>
    "!
    "! @parameter io_converter | <p class="shorttext synchronized">Turns order units into base units</p>
    METHODS constructor
      IMPORTING
        io_converter TYPE REF TO zif_unit_converter.

  PRIVATE SECTION.

    "! One requisition item that is still to bring stock into the plant.
    "! Declared explicitly rather than inferred with INTO TABLE @DATA(), see
    "! ANOMALIES.md.
    TYPES:
      BEGIN OF ty_item,
        banfn TYPE eban-banfn,
        bnfpo TYPE eban-bnfpo,
        menge TYPE eban-menge,
        bsmng TYPE eban-bsmng,
        meins TYPE eban-meins,
        lfdat TYPE eban-lfdat,
      END OF ty_item.
    TYPES ty_item_tab TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.

    DATA mo_converter TYPE REF TO zif_unit_converter.

    METHODS read_items
      IMPORTING
        iv_matnr       TYPE mard-matnr
        iv_werks       TYPE mard-werks
      RETURNING
        VALUE(rt_item) TYPE ty_item_tab.

ENDCLASS.


CLASS zcl_supply_requisitions IMPLEMENTATION.

  METHOD constructor.
    mo_converter = io_converter.
  ENDMETHOD.

  METHOD zif_supply_reader~read_supply.

    " typed explicitly, see ANOMALIES.md
    DATA lv_open TYPE eban-menge.

    LOOP AT read_items(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ) INTO DATA(ls_item).

      " what has been ordered against the requisition is a purchase order now,
      " and feature 34 reads it there. Counting both would promise the same
      " goods twice over.
      lv_open = ls_item-menge - ls_item-bsmng.
      IF lv_open <= 0.
        CONTINUE.
      ENDIF.

      " a requisition with no delivery date says nothing about when it brings
      " anything in, the rule every other source follows
      IF ls_item-lfdat IS INITIAL.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        avail_date = ls_item-lfdat
        quantity   = mo_converter->to_base(
          iv_matnr    = iv_matnr
          iv_quantity = CONV #( lv_open )
          iv_uom      = ls_item-meins ) ) TO rt_supply.

    ENDLOOP.

  ENDMETHOD.

  METHOD read_items.

    " EBAN-EBELN says the item has been turned into a purchase order, which is
    " read as a receipt in its own right. A deleted or closed item brings
    " nothing in either.
    SELECT banfn,
           bnfpo,
           menge,
           bsmng,
           meins,
           lfdat
      FROM eban
      WHERE matnr = @iv_matnr
        AND werks = @iv_werks
        AND loekz = @space
        AND ebakz = @space
        AND ebeln = @space
      ORDER BY banfn, bnfpo
      INTO TABLE @rt_item.
    IF sy-subrc <> 0.
      CLEAR rt_item.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
