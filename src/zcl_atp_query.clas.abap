CLASS zcl_atp_query DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_atp_query.

    "! <p class="shorttext synchronized">Query wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter iv_lgort   | <p class="shorttext synchronized">Location to promise from, all if empty</p>
    "! @parameter iv_planned | <p class="shorttext synchronized">Planned orders count as supply too</p>
    "! @parameter ro_query   | <p class="shorttext synchronized">Ready to use query</p>
    CLASS-METHODS create_default
      IMPORTING
        iv_lgort        TYPE mard-lgort OPTIONAL
        iv_planned      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(ro_query) TYPE REF TO zif_atp_query.

    "! <p class="shorttext synchronized">Wire up the query</p>
    "!
    "! @parameter io_supply    | <p class="shorttext synchronized">What the plant has to give away</p>
    "! @parameter io_authority | <p class="shorttext synchronized">Decides who may ask about a plant</p>
    METHODS constructor
      IMPORTING
        io_supply    TYPE REF TO zif_supply_reader
        io_authority TYPE REF TO zif_allocation_authority.

  PRIVATE SECTION.

    "! Asking what a plant could promise is reading its stock situation, not
    "! changing it.
    CONSTANTS c_activity_display TYPE activ_auth VALUE '03'.

    DATA mo_supply    TYPE REF TO zif_supply_reader.
    DATA mo_authority TYPE REF TO zif_allocation_authority.

    METHODS timeline
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
      io_authority = NEW zcl_authority_plant( c_activity_display ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_supply    = io_supply.
    mo_authority = io_authority.

  ENDMETHOD.

  METHOD zif_atp_query~promise.

    " typed explicitly, see ANOMALIES.md
    DATA lv_total TYPE zif_allocation=>ty_quantity.

    " a promise is an answer about a plant's stock, so it is only for somebody
    " who may see that plant
    mo_authority->check_plant( iv_werks ).

    IF iv_quantity <= 0.
      RETURN.
    ENDIF.

    LOOP AT timeline(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ) INTO DATA(ls_supply).

      " supply that lands after the day the customer named is no use to them,
      " which is the rule the allocation engine follows line by line
      IF iv_by_date IS NOT INITIAL
          AND ls_supply-avail_date > iv_by_date.
        EXIT.
      ENDIF.

      lv_total = lv_total + ls_supply-quantity.

      " the day the promise is complete is the day the last of it arrives, and
      " stock on the shelf carries no date because it is there already
      rs_promise-date = ls_supply-avail_date.

      IF lv_total >= iv_quantity.
        rs_promise-quantity = iv_quantity.
        rs_promise-complete = abap_true.
        RETURN.
      ENDIF.

    ENDLOOP.

    " nothing at all is no promise and no date: saying "none, on the third"
    " would be a date for goods that are not being offered
    IF lv_total <= 0.
      CLEAR rs_promise.
      RETURN.
    ENDIF.

    rs_promise-quantity = lv_total.

  ENDMETHOD.

  METHOD timeline.

    " everything arriving on one day is one entry, earliest first, the same
    " shape the engine distributes. Quantities that are not positive are not
    " supply and would otherwise bring a date into the answer.
    DATA(lt_read) = mo_supply->read_supply(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    LOOP AT lt_read INTO DATA(ls_supply).

      IF ls_supply-quantity <= 0.
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
