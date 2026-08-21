CLASS zcl_atp_query DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_atp_query.

    "! <p class="shorttext synchronized">Query wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter iv_lgort     | <p class="shorttext synchronized">Location to promise from, all if empty</p>
    "! @parameter iv_planned   | <p class="shorttext synchronized">Planned orders count as supply too</p>
    "! @parameter iv_ship_days | <p class="shorttext synchronized">Days between the goods being ready and gone</p>
    "! @parameter iv_cautious  | <p class="shorttext synchronized">Count demand nobody has confirmed yet</p>
    "! @parameter ro_query     | <p class="shorttext synchronized">Ready to use query</p>
    CLASS-METHODS create_default
      IMPORTING
        iv_lgort        TYPE mard-lgort OPTIONAL
        iv_planned      TYPE abap_bool DEFAULT abap_false
        iv_ship_days    TYPE i DEFAULT 0
        iv_cautious     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(ro_query) TYPE REF TO zif_atp_query.

    "! <p class="shorttext synchronized">Query, wired up for a plant</p>
    "!
    "! Everything but the question comes from the plant's own settings, read
    "! here rather than by the caller: an answer worked out by different rules
    "! than the run uses is answering a different question in the same words,
    "! and a factory that cannot read them itself is one that will be called
    "! wrongly. Feature 92 is what that looks like when it happens.
    "!
    "! @parameter iv_werks | <p class="shorttext synchronized">Plant</p>
    "! @parameter ro_query | <p class="shorttext synchronized">Ready to use, as the plant would</p>
    CLASS-METHODS create_for_plant
      IMPORTING
        iv_werks        TYPE mard-werks
      RETURNING
        VALUE(ro_query) TYPE REF TO zif_atp_query.

    "! <p class="shorttext synchronized">Wire up the query</p>
    "!
    "! @parameter io_supply    | <p class="shorttext synchronized">What the plant has to give away</p>
    "! @parameter io_authority | <p class="shorttext synchronized">Decides who may ask about a plant</p>
    "! @parameter iv_ship_days | <p class="shorttext synchronized">Days between the goods being ready and gone</p>
    "! @parameter io_demand    | <p class="shorttext synchronized">Demand to count, none if not given</p>
    METHODS constructor
      IMPORTING
        io_supply    TYPE REF TO zif_supply_reader
        io_authority TYPE REF TO zif_allocation_authority
        iv_ship_days TYPE i DEFAULT 0
        io_demand    TYPE REF TO zif_demand_reader OPTIONAL.

  PRIVATE SECTION.

    "! Asking what a plant could promise is reading its stock situation, not
    "! changing it.
    CONSTANTS c_activity_display TYPE activ_auth VALUE '03'.

    DATA mo_supply    TYPE REF TO zif_supply_reader.
    DATA mo_authority TYPE REF TO zif_allocation_authority.
    DATA mo_demand    TYPE REF TO zif_demand_reader.
    DATA mv_ship_days TYPE i.

    METHODS timeline
      IMPORTING
        iv_matnr         TYPE mard-matnr
        iv_werks         TYPE mard-werks
      RETURNING
        VALUE(rt_supply) TYPE zif_supply_reader=>ty_supply_tab
      RAISING
        zcx_allocation.

    "! What the stock came to after one event of the timeline.
    TYPES:
      BEGIN OF ty_balance,
        avail_date TYPE d,
        balance    TYPE zif_allocation=>ty_quantity,
      END OF ty_balance.
    TYPES ty_balance_tab TYPE STANDARD TABLE OF ty_balance WITH EMPTY KEY.

    METHODS day_it_holds
      IMPORTING
        it_balance     TYPE ty_balance_tab
        iv_quantity    TYPE zif_allocation=>ty_quantity
      RETURNING
        VALUE(rv_date) TYPE d.

    "! What the demand nobody has confirmed yet takes off the timeline, as
    "! negative supply on the day it is needed.
    METHODS demand_as_supply
      IMPORTING
        iv_matnr         TYPE mard-matnr
        iv_werks         TYPE mard-werks
      RETURNING
        VALUE(rt_supply) TYPE zif_supply_reader=>ty_supply_tab
      RAISING
        zcx_allocation.

ENDCLASS.


CLASS zcl_atp_query IMPLEMENTATION.

  METHOD create_default.

    ro_query = NEW zcl_atp_query(
      io_supply    = zcl_allocation_service=>create_default_supply(
        iv_lgort   = iv_lgort
        iv_planned = iv_planned )
      io_authority = NEW zcl_authority_alloc( c_activity_display )
      iv_ship_days = iv_ship_days
      io_demand    = COND #( WHEN iv_cautious = abap_true
                             THEN zcl_allocation_service=>create_default_open_demand(
                               iv_ship_days = iv_ship_days ) ) ).

  ENDMETHOD.

  METHOD create_for_plant.

    DATA(ls_settings) = CAST zif_alloc_config( NEW zcl_alloc_config( ) )->for_plant( iv_werks ).

    ro_query = create_default(
      iv_lgort     = ls_settings-lgort
      iv_planned   = ls_settings-planned
      iv_ship_days = ls_settings-ship_days
      iv_cautious  = ls_settings-cautious_atp ).

  ENDMETHOD.

  METHOD constructor.

    mo_supply    = io_supply.
    mo_authority = io_authority.
    mo_demand    = io_demand.

    " a negative shipping time would mean the goods leave before they are
    " picked, so it is read as none rather than obeyed
    mv_ship_days = iv_ship_days.
    IF mv_ship_days < 0.
      CLEAR mv_ship_days.
    ENDIF.

  ENDMETHOD.

  METHOD zif_atp_query~promise.

    " typed explicitly, see ANOMALIES.md
    DATA lv_balance TYPE zif_allocation=>ty_quantity.
    DATA lv_lowest  TYPE zif_allocation=>ty_quantity.
    DATA lt_balance TYPE ty_balance_tab.

    " a promise is an answer about a plant's stock, so it is only for somebody
    " who may see that plant
    mo_authority->check_plant( iv_werks ).

    IF iv_quantity <= 0.
      RETURN.
    ENDIF.

    " the day named is the day the customer wants the goods, and the plant
    " needs them on the shelf before that. Counting supply that lands on the
    " day itself would promise something that cannot be shipped in time, which
    " is the rule the run follows since feature 68.
    DATA(lv_ready_by) = iv_by_date.
    IF lv_ready_by IS NOT INITIAL.
      lv_ready_by = lv_ready_by - mv_ship_days.
    ENDIF.

    " what the stock comes to after every event up to that day: receipts add
    " to it, and demand nobody has confirmed yet takes away, where the plant
    " has asked for that
    LOOP AT timeline(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ) INTO DATA(ls_event).

      IF lv_ready_by IS NOT INITIAL
          AND ls_event-avail_date > lv_ready_by.
        EXIT.
      ENDIF.

      lv_balance = lv_balance + ls_event-quantity.

      APPEND VALUE #(
        avail_date = ls_event-avail_date
        balance    = lv_balance ) TO lt_balance.

    ENDLOOP.

    IF lt_balance IS INITIAL.
      RETURN.
    ENDIF.

    " what can be promised is what is left at the end of the window, never
    " more than was asked for. Anything more would be promising stock that
    " something later in the window is already going to take.
    lv_lowest = lt_balance[ lines( lt_balance ) ]-balance.
    IF lv_lowest <= 0.
      RETURN.
    ENDIF.

    rs_promise-quantity = lv_lowest.
    IF rs_promise-quantity > iv_quantity.
      rs_promise-quantity = iv_quantity.
    ENDIF.

    rs_promise-complete = xsdbool( rs_promise-quantity >= iv_quantity ).
    rs_promise-date     = day_it_holds(
      it_balance  = lt_balance
      iv_quantity = rs_promise-quantity ).

  ENDMETHOD.

  METHOD day_it_holds.

    " the earliest day from which the balance never drops below the quantity
    " again: promising it any earlier would be promising stock that something
    " in between takes. A line served off the shelf reaches it at the first
    " entry, which carries no date, and that is what "now" means.
    DATA(lv_index) = lines( it_balance ).

    WHILE lv_index > 0.

      IF it_balance[ lv_index ]-balance < iv_quantity.
        EXIT.
      ENDIF.

      rv_date  = it_balance[ lv_index ]-avail_date.
      lv_index = lv_index - 1.

    ENDWHILE.

  ENDMETHOD.

  METHOD demand_as_supply.

    IF mo_demand IS NOT BOUND.
      RETURN.
    ENDIF.

    " a promise that ignores the orders already on the books offers the same
    " stock to everybody who asks until a run decides otherwise. A plant that
    " would rather promise less than promise twice counts them here, on the
    " day the goods have to be there.
    LOOP AT mo_demand->read_open_demand(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ) INTO DATA(ls_demand).

      IF ls_demand-quantity <= 0.
        CONTINUE.
      ENDIF.

      DATA(lv_needed) = ls_demand-ready_by.
      IF lv_needed IS INITIAL.
        lv_needed = ls_demand-req_date.
      ENDIF.

      APPEND VALUE #(
        avail_date = lv_needed
        quantity   = 0 - ls_demand-quantity ) TO rt_supply.

    ENDLOOP.

  ENDMETHOD.

  METHOD timeline.

    " everything happening on one day is one entry, earliest first, the same
    " shape the engine distributes. What is read is the stock coming in and,
    " where the plant asks to be careful, the demand going out.
    DATA(lt_read) = mo_supply->read_supply(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    APPEND LINES OF demand_as_supply(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ) TO lt_read.

    LOOP AT lt_read INTO DATA(ls_supply).

      IF ls_supply-quantity = 0.
        CONTINUE.
      ENDIF.

      READ TABLE rt_supply ASSIGNING FIELD-SYMBOL(<ls_pooled>)
        WITH KEY avail_date = ls_supply-avail_date.
      IF sy-subrc = 0.
        <ls_pooled>-quantity = <ls_pooled>-quantity + ls_supply-quantity.
        CONTINUE.
      ENDIF.

      APPEND ls_supply TO rt_supply.

    ENDLOOP.

    SORT rt_supply BY avail_date ASCENDING.

  ENDMETHOD.

ENDCLASS.
