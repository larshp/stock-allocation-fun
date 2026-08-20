CLASS zcl_supply_planned DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_supply_reader.

    "! PLAF-PLSCN: the operative plan. Anything else is a long term planning
    "! scenario, which is somebody asking what would happen, not what will.
    CONSTANTS c_operative_plan TYPE plaf-plscn VALUE '000'.

    "! <p class="shorttext synchronized">Wire up the reader</p>
    "!
    "! @parameter io_converter | <p class="shorttext synchronized">Turns order units into base units</p>
    "! @parameter iv_firm_only | <p class="shorttext synchronized">Only firmed orders count, the safe answer</p>
    METHODS constructor
      IMPORTING
        io_converter TYPE REF TO zif_unit_converter
        iv_firm_only TYPE abap_bool DEFAULT abap_true.

  PRIVATE SECTION.

    "! One planned order that is still to deliver into the plant. Declared
    "! explicitly rather than inferred with INTO TABLE @DATA(), see
    "! ANOMALIES.md.
    TYPES:
      BEGIN OF ty_order,
        plnum TYPE plaf-plnum,
        gsmng TYPE plaf-gsmng,
        meins TYPE plaf-meins,
        pedtr TYPE plaf-pedtr,
        auffx TYPE plaf-auffx,
      END OF ty_order.
    TYPES ty_order_tab TYPE STANDARD TABLE OF ty_order WITH EMPTY KEY.

    DATA mo_converter TYPE REF TO zif_unit_converter.
    DATA mv_firm_only TYPE abap_bool.

    METHODS read_orders
      IMPORTING
        iv_matnr        TYPE mard-matnr
        iv_werks        TYPE mard-werks
      RETURNING
        VALUE(rt_order) TYPE ty_order_tab.

ENDCLASS.


CLASS zcl_supply_planned IMPLEMENTATION.

  METHOD constructor.

    mo_converter = io_converter.
    mv_firm_only = iv_firm_only.

  ENDMETHOD.

  METHOD zif_supply_reader~read_supply.

    DATA(lt_order) = read_orders(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    LOOP AT lt_order INTO DATA(ls_order).

      " a planned order that MRP has not been told to keep is a proposal, and
      " the next planning run can move it, resize it or delete it. Confirming
      " a customer against one is confirming against something no human has
      " agreed to. Firming is exactly the statement that somebody has.
      IF mv_firm_only = abap_true AND ls_order-auffx IS INITIAL.
        CONTINUE.
      ENDIF.

      IF ls_order-gsmng <= 0.
        CONTINUE.
      ENDIF.

      " an order with no finish date says nothing about when it delivers, the
      " same as a purchasing item without a schedule line
      IF ls_order-pedtr IS INITIAL.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        avail_date = ls_order-pedtr
        quantity   = mo_converter->to_base(
          iv_matnr    = iv_matnr
          iv_quantity = CONV #( ls_order-gsmng )
          iv_uom      = ls_order-meins ) ) TO rt_supply.

    ENDLOOP.

  ENDMETHOD.

  METHOD read_orders.

    " PLAF-UMSKZ says the order has been converted: what it proposed is now a
    " production order or a purchase requisition and is read there. Counting
    " both would give the same goods away twice.
    "
    " PLAF-PLSCN keeps long term planning out. A simulative order lives in the
    " same table as the operative one and describes a future nobody has
    " committed to.
    SELECT plnum,
           gsmng,
           meins,
           pedtr,
           auffx
      FROM plaf
      WHERE matnr = @iv_matnr
        AND plwrk = @iv_werks
        AND plscn = @c_operative_plan
        AND umskz = @space
      ORDER BY plnum
      INTO TABLE @rt_order.
    IF sy-subrc <> 0.
      CLEAR rt_order.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
