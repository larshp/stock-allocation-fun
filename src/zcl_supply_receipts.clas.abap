CLASS zcl_supply_receipts DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_supply_reader.

    "! <p class="shorttext synchronized">Wire up the reader</p>
    "!
    "! @parameter io_converter | <p class="shorttext synchronized">Turns order units into base units</p>
    METHODS constructor
      IMPORTING
        io_converter TYPE REF TO zif_unit_converter.

  PRIVATE SECTION.

    "! One open item of a purchasing document that brings stock into the plant.
    "! Declared explicitly rather than inferred with INTO TABLE @DATA(), see
    "! ANOMALIES.md.
    TYPES:
      BEGIN OF ty_item,
        ebeln TYPE ekpo-ebeln,
        ebelp TYPE ekpo-ebelp,
        matnr TYPE ekpo-matnr,
        meins TYPE ekpo-meins,
      END OF ty_item.
    TYPES ty_item_tab TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.

    "! A schedule line of such an item: a quantity arriving on a date, and what
    "! of it has already been received.
    TYPES:
      BEGIN OF ty_schedule,
        ebeln TYPE eket-ebeln,
        ebelp TYPE eket-ebelp,
        etenr TYPE eket-etenr,
        eindt TYPE eket-eindt,
        menge TYPE eket-menge,
        wemng TYPE eket-wemng,
      END OF ty_schedule.
    TYPES ty_schedule_tab TYPE STANDARD TABLE OF ty_schedule WITH EMPTY KEY.

    DATA mo_converter TYPE REF TO zif_unit_converter.

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

ENDCLASS.


CLASS zcl_supply_receipts IMPLEMENTATION.

  METHOD constructor.
    mo_converter = io_converter.
  ENDMETHOD.

  METHOD zif_supply_reader~read_supply.

    " typed explicitly, see ANOMALIES.md
    DATA lv_open TYPE ekpo-menge.

    DATA(lt_item)     = read_items(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).
    DATA(lt_schedule) = read_schedules(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    LOOP AT lt_item INTO DATA(ls_item).

      DATA(lt_line) = schedules_of(
        is_item     = ls_item
        it_schedule = lt_schedule ).

      LOOP AT lt_line INTO DATA(ls_line).

        " what has arrived is in MARD already and is read as stock on hand.
        " Counting it here as well would allocate it twice.
        lv_open = ls_line-menge - ls_line-wemng.
        IF lv_open <= 0.
          CONTINUE.
        ENDIF.

        " the order is in the purchase order unit, the stock is in base units
        APPEND VALUE #(
          avail_date = ls_line-eindt
          quantity   = mo_converter->to_base(
            iv_matnr    = ls_item-matnr
            iv_quantity = CONV #( lv_open )
            iv_uom      = ls_item-meins ) ) TO rt_supply.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD read_items.

    " EKPO-WERKS is the receiving plant: this is the plant the stock arrives
    " in. A stock transport order is read from both ends: as demand in the
    " supplying plant, as a receipt here, which is what it is.
    "
    " A returns item sends stock back to the vendor, so it takes stock out of
    " the plant rather than bringing any in, and has no place in supply.
    SELECT item~ebeln,
           item~ebelp,
           item~matnr,
           item~meins
      FROM ekpo AS item
      INNER JOIN ekko AS header ON header~ebeln = item~ebeln
      WHERE item~matnr = @iv_matnr
        AND item~werks = @iv_werks
        AND item~loekz = @space
        AND item~elikz = @space
        AND item~retpo = @space
        AND header~loekz = @space
      ORDER BY item~ebeln, item~ebelp
      INTO TABLE @rt_item.
    IF sy-subrc <> 0.
      CLEAR rt_item.
    ENDIF.

  ENDMETHOD.

  METHOD read_schedules.

    " EKET carries no material or plant, so it is joined to EKPO to stay
    " selective
    SELECT sched~ebeln,
           sched~ebelp,
           sched~etenr,
           sched~eindt,
           sched~menge,
           sched~wemng
      FROM eket AS sched
      INNER JOIN ekpo AS item ON item~ebeln = sched~ebeln
                             AND item~ebelp = sched~ebelp
      WHERE item~matnr = @iv_matnr
        AND item~werks = @iv_werks
        AND item~loekz = @space
        AND item~elikz = @space
        AND item~retpo = @space
      ORDER BY sched~ebeln, sched~ebelp, sched~etenr
      INTO TABLE @rt_schedule.
    IF sy-subrc <> 0.
      CLEAR rt_schedule.
    ENDIF.

  ENDMETHOD.

  METHOD schedules_of.

    " an item with no schedule line has nothing that says when it arrives, and
    " supply without a date would have to be taken as available now, which
    " promises stock that nobody has committed to a day. It is left out, the
    " same direction of error the demand readers take when they keep an
    " undated requirement.
    LOOP AT it_schedule INTO DATA(ls_schedule)
        WHERE ebeln = is_item-ebeln
          AND ebelp = is_item-ebelp.
      IF ls_schedule-eindt IS NOT INITIAL.
        APPEND ls_schedule TO rt_schedule.
      ENDIF.
    ENDLOOP.

    SORT rt_schedule BY eindt ASCENDING etenr ASCENDING.

  ENDMETHOD.

ENDCLASS.
