CLASS zcl_sto_demand_reader DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    "! A stock transport order has no delivery priority of its own, so where
    "! internal transfers rank against customer orders is a decision, not
    "! something to read out of the document. The middle of the range by
    "! default: ahead of an order with no priority set, behind an urgent one.
    CONSTANTS c_default_priority TYPE zif_allocation=>ty_priority VALUE '50'.

    "! Marks a demand id as coming from a purchasing document, so it cannot
    "! collide with a sales order line carrying the same numbers.
    CONSTANTS c_source_marker TYPE c LENGTH 1 VALUE 'P'.

    "! <p class="shorttext synchronized">Wire up the reader</p>
    "!
    "! @parameter io_converter | <p class="shorttext synchronized">Turns order units into base units</p>
    "! @parameter iv_priority  | <p class="shorttext synchronized">Where transfers rank against orders</p>
    METHODS constructor
      IMPORTING
        io_converter TYPE REF TO zif_unit_converter
        iv_priority  TYPE zif_allocation=>ty_priority DEFAULT c_default_priority.

  PRIVATE SECTION.

    "! One open item of a stock transport order that takes stock out of the
    "! supplying plant. Declared explicitly rather than inferred with
    "! INTO TABLE @DATA(), see ANOMALIES.md.
    TYPES:
      BEGIN OF ty_item,
        ebeln TYPE ekpo-ebeln,
        ebelp TYPE ekpo-ebelp,
        matnr TYPE ekpo-matnr,
        menge TYPE ekpo-menge,
        meins TYPE ekpo-meins,
      END OF ty_item.
    TYPES ty_item_tab TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.

    "! A schedule line of such an item, with what it still has to send.
    TYPES:
      BEGIN OF ty_schedule,
        ebeln TYPE eket-ebeln,
        ebelp TYPE eket-ebelp,
        etenr TYPE eket-etenr,
        eindt TYPE eket-eindt,
        menge TYPE eket-menge,
        wamng TYPE eket-wamng,
      END OF ty_schedule.
    TYPES ty_schedule_tab TYPE STANDARD TABLE OF ty_schedule WITH EMPTY KEY.

    DATA mo_converter TYPE REF TO zif_unit_converter.
    DATA mv_priority  TYPE zif_allocation=>ty_priority.

    METHODS read_items
      IMPORTING
        iv_matnr       TYPE mard-matnr
        iv_werks       TYPE mard-werks
      RETURNING
        VALUE(rt_item) TYPE ty_item_tab.

    METHODS read_schedules
      IMPORTING
        iv_matnr           TYPE mard-matnr
      RETURNING
        VALUE(rt_schedule) TYPE ty_schedule_tab.

    METHODS schedules_of
      IMPORTING
        is_item            TYPE ty_item
        it_schedule        TYPE ty_schedule_tab
      RETURNING
        VALUE(rt_schedule) TYPE ty_schedule_tab.

    METHODS build_demand_id
      IMPORTING
        iv_ebeln            TYPE ekpo-ebeln
        iv_ebelp            TYPE ekpo-ebelp
        iv_etenr            TYPE eket-etenr
      RETURNING
        VALUE(rv_demand_id) TYPE zif_allocation=>ty_demand_id.

ENDCLASS.


CLASS zcl_sto_demand_reader IMPLEMENTATION.

  METHOD constructor.

    mo_converter = io_converter.
    mv_priority  = iv_priority.

  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.

    " typed explicitly, see ANOMALIES.md
    DATA lv_open TYPE ekpo-menge.

    DATA(lt_item)     = read_items(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).
    DATA(lt_schedule) = read_schedules( iv_matnr ).

    LOOP AT lt_item INTO DATA(ls_item).

      DATA(lt_line) = schedules_of(
        is_item     = ls_item
        it_schedule = lt_schedule ).

      LOOP AT lt_line INTO DATA(ls_line).

        " a schedule line that has been issued in full, or over-issued, has
        " nothing left to send
        lv_open = ls_line-menge - ls_line-wamng.
        IF lv_open <= 0.
          CONTINUE.
        ENDIF.

        " the order is in the purchase order unit, the stock is in base units
        DATA(lv_quantity) = mo_converter->to_base(
          iv_matnr    = ls_item-matnr
          iv_quantity = CONV #( lv_open )
          iv_uom      = ls_item-meins ).

        APPEND VALUE #(
          demand_id = build_demand_id(
            iv_ebeln = ls_line-ebeln
            iv_ebelp = ls_line-ebelp
            iv_etenr = ls_line-etenr )
          matnr     = ls_item-matnr
          werks     = iv_werks
          quantity  = lv_quantity
          req_date  = ls_line-eindt
          priority  = mv_priority ) TO rt_demand.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.

    " duplicates are removed here rather than with SELECT DISTINCT, which the
    " transpiler drops from the statement, see ANOMALIES.md
    SELECT item~matnr AS matnr
      FROM ekpo AS item
      INNER JOIN ekko AS header ON header~ebeln = item~ebeln
      WHERE header~reswk = @iv_werks
        AND header~loekz = @space
        AND item~loekz = @space
        AND item~elikz = @space
      ORDER BY item~matnr
      INTO TABLE @rt_matnr.
    IF sy-subrc <> 0.
      CLEAR rt_matnr.
      RETURN.
    ENDIF.

    DELETE ADJACENT DUPLICATES FROM rt_matnr.

  ENDMETHOD.

  METHOD read_items.

    " EKKO-RESWK is the supplying plant: this is the plant the stock leaves,
    " which is the plant whose stock the transfer competes for. EKPO-WERKS is
    " the receiving plant and is deliberately not what is filtered on.
    SELECT item~ebeln,
           item~ebelp,
           item~matnr,
           item~menge,
           item~meins
      FROM ekpo AS item
      INNER JOIN ekko AS header ON header~ebeln = item~ebeln
      WHERE item~matnr = @iv_matnr
        AND header~reswk = @iv_werks
        AND header~loekz = @space
        AND item~loekz = @space
        AND item~elikz = @space
      ORDER BY item~ebeln, item~ebelp
      INTO TABLE @rt_item.
    IF sy-subrc <> 0.
      CLEAR rt_item.
    ENDIF.

  ENDMETHOD.

  METHOD read_schedules.

    " EKET carries no material or plant, so it is joined to EKPO to stay
    " selective. Which of these lines belong to a transfer out of the plant is
    " decided against the item list, which is filtered on the supplying plant.
    SELECT sched~ebeln,
           sched~ebelp,
           sched~etenr,
           sched~eindt,
           sched~menge,
           sched~wamng
      FROM eket AS sched
      INNER JOIN ekpo AS item ON item~ebeln = sched~ebeln
                             AND item~ebelp = sched~ebelp
      WHERE item~matnr = @iv_matnr
        AND item~loekz = @space
        AND item~elikz = @space
      ORDER BY sched~ebeln, sched~ebelp, sched~etenr
      INTO TABLE @rt_schedule.
    IF sy-subrc <> 0.
      CLEAR rt_schedule.
    ENDIF.

  ENDMETHOD.

  METHOD schedules_of.

    LOOP AT it_schedule INTO DATA(ls_schedule)
        WHERE ebeln = is_item-ebeln
          AND ebelp = is_item-ebelp.
      APPEND ls_schedule TO rt_schedule.
    ENDLOOP.

    " an item without schedule lines has no committed date, but it has been
    " ordered: taking it as nothing would silently lose real demand, and no
    " date already means as soon as possible to the horizon filter
    IF rt_schedule IS INITIAL.
      APPEND VALUE #(
        ebeln = is_item-ebeln
        ebelp = is_item-ebelp
        etenr = '0000'
        menge = is_item-menge
        wamng = 0 ) TO rt_schedule.
      RETURN.
    ENDIF.

    SORT rt_schedule BY eindt ASCENDING etenr ASCENDING.

  ENDMETHOD.

  METHOD build_demand_id.

    rv_demand_id+0(1)   = c_source_marker.
    rv_demand_id+1(10)  = iv_ebeln.
    rv_demand_id+11(5)  = iv_ebelp.
    rv_demand_id+16(4)  = iv_etenr.

  ENDMETHOD.

ENDCLASS.
