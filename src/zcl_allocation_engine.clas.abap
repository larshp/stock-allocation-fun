CLASS zcl_allocation_engine DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    "! <p class="shorttext synchronized">Wire up the engine</p>
    "!
    "! @parameter io_supply_reader | <p class="shorttext synchronized">Source of what can be allocated</p>
    "! @parameter io_demand_reader | <p class="shorttext synchronized">Source of the open demand</p>
    "! @parameter io_strategy      | <p class="shorttext synchronized">Rule for distributing the stock</p>
    METHODS constructor
      IMPORTING
        io_supply_reader TYPE REF TO zif_supply_reader
        io_demand_reader TYPE REF TO zif_demand_reader
        io_strategy      TYPE REF TO zif_allocation_strategy.

    "! <p class="shorttext synchronized">Allocate stock to everything currently waiting for it</p>
    "!
    "! @parameter iv_matnr      | <p class="shorttext synchronized">Material number</p>
    "! @parameter iv_werks      | <p class="shorttext synchronized">Plant</p>
    "! @parameter rt_allocation  | <p class="shorttext synchronized">Confirmed quantity per demand line</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">Open demand or supply could not be read</p>
    METHODS allocate_open_demand
      IMPORTING
        iv_matnr             TYPE mard-matnr
        iv_werks             TYPE mard-werks
      RETURNING
        VALUE(rt_allocation) TYPE zif_allocation=>ty_allocation_tab
      RAISING
        zcx_allocation.

    "! <p class="shorttext synchronized">Allocate the supply of one material to the given demand</p>
    "!
    "! The supply of the material is walked in the order it becomes available:
    "! what is on the shelf first, then every receipt on the day it arrives.
    "! Each of those days is offered to the demand that can wait for it, by the
    "! strategy, and what nobody took stays in the pool for the next day. All
    "! demand lines passed in are expected to be for IV_MATNR in IV_WERKS. Use
    "! this to simulate an allocation, ALLOCATE_OPEN_DEMAND answers the same
    "! question for the demand that is really on the books.
    "!
    "! @parameter iv_matnr      | <p class="shorttext synchronized">Material number</p>
    "! @parameter iv_werks      | <p class="shorttext synchronized">Plant</p>
    "! @parameter it_demand     | <p class="shorttext synchronized">Demand competing for the stock</p>
    "! @parameter rt_allocation | <p class="shorttext synchronized">Confirmed quantity per demand line</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">Supply could not be read</p>
    METHODS allocate
      IMPORTING
        iv_matnr             TYPE mard-matnr
        iv_werks             TYPE mard-werks
        it_demand            TYPE zif_allocation=>ty_demand_tab
      RETURNING
        VALUE(rt_allocation) TYPE zif_allocation=>ty_allocation_tab
      RAISING
        zcx_allocation.

  PRIVATE SECTION.

    TYPES ty_demand_id_tab TYPE STANDARD TABLE OF zif_allocation=>ty_demand_id WITH EMPTY KEY.

    "! Why a strategy left a line short, as the strategy itself explained it.
    TYPES:
      BEGIN OF ty_reason,
        demand_id TYPE zif_allocation=>ty_demand_id,
        reason    TYPE zif_allocation=>ty_reason,
      END OF ty_reason.
    TYPES ty_reason_tab TYPE STANDARD TABLE OF ty_reason WITH EMPTY KEY.

    "! What one day of supply confirmed for one demand line.
    TYPES:
      BEGIN OF ty_confirmed,
        demand_id  TYPE zif_allocation=>ty_demand_id,
        avail_date TYPE d,
        quantity   TYPE zif_allocation=>ty_quantity,
      END OF ty_confirmed.
    TYPES ty_confirmed_tab TYPE STANDARD TABLE OF ty_confirmed WITH EMPTY KEY.

    DATA mo_supply_reader TYPE REF TO zif_supply_reader.
    DATA mo_demand_reader TYPE REF TO zif_demand_reader.
    DATA mo_strategy      TYPE REF TO zif_allocation_strategy.

    METHODS pooled_by_date
      IMPORTING
        it_supply        TYPE zif_supply_reader=>ty_supply_tab
      RETURNING
        VALUE(rt_supply) TYPE zif_supply_reader=>ty_supply_tab.

    METHODS servable_from
      IMPORTING
        iv_date          TYPE d
        it_demand        TYPE zif_allocation=>ty_demand_tab
      RETURNING
        VALUE(rt_demand) TYPE zif_allocation=>ty_demand_tab.

    METHODS confirmed_for
      IMPORTING
        iv_demand_id       TYPE zif_allocation=>ty_demand_id
        it_confirmed       TYPE ty_confirmed_tab
      RETURNING
        VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity.

    METHODS available_from
      IMPORTING
        iv_demand_id   TYPE zif_allocation=>ty_demand_id
        it_confirmed   TYPE ty_confirmed_tab
      RETURNING
        VALUE(rv_date) TYPE d.

    METHODS answer
      IMPORTING
        it_demand            TYPE zif_allocation=>ty_demand_tab
        it_served            TYPE ty_demand_id_tab
        it_confirmed         TYPE ty_confirmed_tab
        it_offered           TYPE ty_demand_id_tab
        it_reason            TYPE ty_reason_tab
        iv_had_supply        TYPE abap_bool
      RETURNING
        VALUE(rt_allocation) TYPE zif_allocation=>ty_allocation_tab.

    METHODS reason_for
      IMPORTING
        iv_demand_id     TYPE zif_allocation=>ty_demand_id
        it_offered       TYPE ty_demand_id_tab
        it_reason        TYPE ty_reason_tab
        iv_had_supply    TYPE abap_bool
      RETURNING
        VALUE(rv_reason) TYPE zif_allocation=>ty_reason.

ENDCLASS.


CLASS zcl_allocation_engine IMPLEMENTATION.

  METHOD constructor.

    mo_supply_reader = io_supply_reader.
    mo_demand_reader = io_demand_reader.
    mo_strategy      = io_strategy.

  ENDMETHOD.

  METHOD allocate_open_demand.

    DATA(lt_demand) = mo_demand_reader->read_open_demand(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    rt_allocation = allocate(
      iv_matnr  = iv_matnr
      iv_werks  = iv_werks
      it_demand = lt_demand ).

  ENDMETHOD.

  METHOD allocate.

    " what each line still has to be served, reduced as the days are walked
    DATA lt_open      TYPE zif_allocation=>ty_demand_tab.
    " the order the strategy first answered a line in, which is the order the
    " result is given back in
    DATA lt_served    TYPE ty_demand_id_tab.
    DATA lt_confirmed TYPE ty_confirmed_tab.
    DATA lv_pool      TYPE zif_allocation=>ty_quantity.
    " the lines a day of supply was ever offered to, and what a strategy said
    " about the ones it could not fill
    DATA lt_offered   TYPE ty_demand_id_tab.
    DATA lt_reason    TYPE ty_reason_tab.

    DATA(lt_supply) = pooled_by_date( mo_supply_reader->read_supply(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ) ).

    lt_open = it_demand.

    LOOP AT lt_supply INTO DATA(ls_supply).

      " what nobody took on an earlier day is still there on this one
      lv_pool = lv_pool + ls_supply-quantity.

      DATA(lt_bucket) = servable_from(
        iv_date   = ls_supply-avail_date
        it_demand = lt_open ).
      IF lv_pool <= 0 OR lt_bucket IS INITIAL.
        CONTINUE.
      ENDIF.

      LOOP AT lt_bucket INTO DATA(ls_bucket).
        IF NOT line_exists( lt_offered[ table_line = ls_bucket-demand_id ] ).
          APPEND ls_bucket-demand_id TO lt_offered.
        ENDIF.
      ENDLOOP.

      DATA(lt_answer) = mo_strategy->allocate(
        iv_available = lv_pool
        it_demand    = lt_bucket ).

      LOOP AT lt_answer INTO DATA(ls_answer).

        IF NOT line_exists( lt_served[ table_line = ls_answer-demand_id ] ).
          APPEND ls_answer-demand_id TO lt_served.
        ENDIF.

        " a rule that held a line back says so itself, and the last day it said
        " it is the answer: a line the cap stopped in January and the stock
        " stopped in March was stopped by the stock in the end.
        IF ls_answer-reason IS NOT INITIAL.
          DELETE lt_reason WHERE demand_id = ls_answer-demand_id.
          APPEND VALUE #(
            demand_id = ls_answer-demand_id
            reason    = ls_answer-reason ) TO lt_reason.
        ENDIF.

        IF ls_answer-confirmed <= 0.
          CONTINUE.
        ENDIF.

        APPEND VALUE #(
          demand_id  = ls_answer-demand_id
          avail_date = ls_supply-avail_date
          quantity   = ls_answer-confirmed ) TO lt_confirmed.

        lv_pool = lv_pool - ls_answer-confirmed.

        " a line served in part is back tomorrow for the rest of it
        LOOP AT lt_open ASSIGNING FIELD-SYMBOL(<ls_open>)
            WHERE demand_id = ls_answer-demand_id.
          <ls_open>-quantity = <ls_open>-quantity - ls_answer-confirmed.
        ENDLOOP.

      ENDLOOP.

    ENDLOOP.

    rt_allocation = answer(
      it_demand     = it_demand
      it_served     = lt_served
      it_confirmed  = lt_confirmed
      it_offered    = lt_offered
      it_reason     = lt_reason
      iv_had_supply = xsdbool( lt_supply IS NOT INITIAL ) ).

  ENDMETHOD.

  METHOD pooled_by_date.

    " everything arriving on one day is one pool: two receipts on the same
    " date offered one after the other would let a strategy split what it
    " would have handed out whole
    LOOP AT it_supply INTO DATA(ls_supply).

      IF ls_supply-quantity <= 0.
        CONTINUE.
      ENDIF.

      IF line_exists( rt_supply[ avail_date = ls_supply-avail_date ] ).
        LOOP AT rt_supply ASSIGNING FIELD-SYMBOL(<ls_pooled>)
            WHERE avail_date = ls_supply-avail_date.
          <ls_pooled>-quantity = <ls_pooled>-quantity + ls_supply-quantity.
        ENDLOOP.
      ELSE.
        APPEND ls_supply TO rt_supply.
      ENDIF.

    ENDLOOP.

    " earliest first: stock on the shelf carries no date and comes first
    SORT rt_supply BY avail_date ASCENDING.

  ENDMETHOD.

  METHOD servable_from.

    " a receipt cannot serve a line that needs the stock before it arrives:
    " confirming it would promise a date that cannot be kept. Stock that is
    " already there carries no date and can serve anything, including a line
    " that is already overdue.
    "
    " What the line needs is READY_BY, the day the goods have to be in the
    " plant, which is earlier than the day the customer wants them by however
    " long shipping takes. A line that says nothing about it wants them on the
    " day it is wanted, which is what a plant that ships the same day has.
    LOOP AT it_demand INTO DATA(ls_demand).

      DATA(lv_needed) = ls_demand-ready_by.
      IF lv_needed IS INITIAL.
        lv_needed = ls_demand-req_date.
      ENDIF.

      IF ls_demand-quantity > 0 AND lv_needed >= iv_date.
        APPEND ls_demand TO rt_demand.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD reason_for.

    " what a rule of the plant's own making did to the line is the better
    " answer, because it is the one somebody can decide to change
    READ TABLE it_reason INTO DATA(ls_reason)
      WITH KEY demand_id = iv_demand_id.
    IF sy-subrc = 0.
      rv_reason = ls_reason-reason.
      RETURN.
    ENDIF.

    " a line no day of supply was ever offered to was passed over by the rule
    " that a receipt cannot serve a requirement wanted before it lands. There
    " is stock coming; it comes too late for this line.
    IF iv_had_supply = abap_true
        AND NOT line_exists( it_offered[ table_line = iv_demand_id ] ).
      rv_reason = zif_allocation=>c_reason-supply_late.
      RETURN.
    ENDIF.

    " otherwise the pool simply did not stretch this far
    rv_reason = zif_allocation=>c_reason-no_stock.

  ENDMETHOD.

  METHOD confirmed_for.

    LOOP AT it_confirmed INTO DATA(ls_confirmed)
        WHERE demand_id = iv_demand_id.
      rv_quantity = rv_quantity + ls_confirmed-quantity.
    ENDLOOP.

  ENDMETHOD.

  METHOD available_from.

    " the line is there in full on the day the last of its supply arrives, so
    " the latest of the days that contributed is the answer. A line served
    " entirely off the shelf keeps the initial date, which says "already".
    LOOP AT it_confirmed INTO DATA(ls_confirmed)
        WHERE demand_id = iv_demand_id.
      IF ls_confirmed-avail_date > rv_date.
        rv_date = ls_confirmed-avail_date.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD answer.

    DATA lt_served TYPE ty_demand_id_tab.

    lt_served = it_served.

    " every demand line is answered exactly once, including one no day of
    " supply could ever reach
    LOOP AT it_demand INTO DATA(ls_demand).
      IF NOT line_exists( lt_served[ table_line = ls_demand-demand_id ] ).
        APPEND ls_demand-demand_id TO lt_served.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_served INTO DATA(lv_demand_id).

      DATA(ls_line) = it_demand[ demand_id = lv_demand_id ].

      " what was asked for is what the demand says, not what was left of it on
      " the day it was finally served
      DATA(lv_confirmed) = confirmed_for(
        iv_demand_id = lv_demand_id
        it_confirmed = it_confirmed ).

      APPEND VALUE #(
        demand_id  = lv_demand_id
        req_date   = ls_line-req_date
        customer   = ls_line-customer
        avail_date = available_from(
          iv_demand_id = lv_demand_id
          it_confirmed = it_confirmed )
        requested  = ls_line-quantity
        confirmed  = lv_confirmed
        shortfall  = COND #( WHEN ls_line-quantity > lv_confirmed
                             THEN ls_line-quantity - lv_confirmed
                             ELSE 0 )
        reason     = COND #( WHEN ls_line-quantity > lv_confirmed
                             THEN reason_for(
                               iv_demand_id  = lv_demand_id
                               it_offered    = it_offered
                               it_reason     = it_reason
                               iv_had_supply = iv_had_supply ) ) ) TO rt_allocation.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
