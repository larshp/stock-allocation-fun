CLASS zcl_demand_reader_net DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    "! <p class="shorttext synchronized">Wrap a demand reader with what it has already been given</p>
    "!
    "! @parameter io_demand | <p class="shorttext synchronized">Reader of the open demand</p>
    METHODS constructor
      IMPORTING
        io_demand TYPE REF TO zif_demand_reader.

  PRIVATE SECTION.

    "! A run whose reservation number is still initial never earmarked
    "! anything, so it does not count as covered.
    CONSTANTS c_no_reservation TYPE zstock_alloc_res-reservation VALUE '0000000000'.

    TYPES:
      BEGIN OF ty_allocated,
        demand_id   TYPE zstock_alloc_res-demand_id,
        reservation TYPE zstock_alloc_res-reservation,
        confirmed   TYPE zstock_alloc_res-confirmed,
      END OF ty_allocated.
    TYPES ty_allocated_tab TYPE STANDARD TABLE OF ty_allocated WITH EMPTY KEY.

    TYPES ty_reservation_tab TYPE STANDARD TABLE OF resb-rsnum WITH EMPTY KEY.

    DATA mo_demand TYPE REF TO zif_demand_reader.

    METHODS already_allocated
      IMPORTING
        iv_matnr            TYPE mard-matnr
        iv_werks            TYPE mard-werks
      RETURNING
        VALUE(rt_allocated) TYPE ty_allocated_tab.

    METHODS live_reservations
      IMPORTING
        iv_matnr              TYPE mard-matnr
        iv_werks              TYPE mard-werks
      RETURNING
        VALUE(rt_reservation) TYPE ty_reservation_tab.

    METHODS covered
      IMPORTING
        it_allocated       TYPE ty_allocated_tab
        iv_demand_id       TYPE zif_allocation=>ty_demand_id
      RETURNING
        VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity.

ENDCLASS.


CLASS zcl_demand_reader_net IMPLEMENTATION.

  METHOD constructor.
    mo_demand = io_demand.
  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.
    rt_matnr = mo_demand->materials_with_demand( iv_werks ).
  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.

    " typed explicitly, see ANOMALIES.md
    DATA lv_open TYPE zif_allocation=>ty_quantity.

    DATA(lt_demand) = mo_demand->read_open_demand(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    DATA(lt_allocated) = already_allocated(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    " a line that has already been served in full has nothing left to ask for
    " and drops out; one served in part asks for the remainder
    LOOP AT lt_demand INTO DATA(ls_demand).

      lv_open = ls_demand-quantity - covered(
        it_allocated = lt_allocated
        iv_demand_id = ls_demand-demand_id ).

      IF lv_open > 0.
        ls_demand-quantity = lv_open.
        APPEND ls_demand TO rt_demand.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD already_allocated.

    DATA lt_recorded TYPE ty_allocated_tab.

    SELECT demand_id,
           reservation,
           confirmed
      FROM zstock_alloc_res
      WHERE matnr = @iv_matnr
        AND werks = @iv_werks
        AND reservation <> @c_no_reservation
      ORDER BY demand_id
      INTO TABLE @lt_recorded.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " a recorded run only counts while its reservation is still there. If
    " somebody deleted it, the stock became free again and so did the demand:
    " counting it as served would starve the line forever.
    DATA(lt_live) = live_reservations(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    LOOP AT lt_recorded INTO DATA(ls_recorded).
      IF line_exists( lt_live[ table_line = ls_recorded-reservation ] ).
        APPEND ls_recorded TO rt_allocated.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD live_reservations.

    SELECT rsnum
      FROM resb
      WHERE matnr = @iv_matnr
        AND werks = @iv_werks
        AND xloek = @space
      ORDER BY rsnum
      INTO TABLE @rt_reservation.
    IF sy-subrc <> 0.
      CLEAR rt_reservation.
      RETURN.
    ENDIF.

    DELETE ADJACENT DUPLICATES FROM rt_reservation.

  ENDMETHOD.

  METHOD covered.

    LOOP AT it_allocated INTO DATA(ls_allocated) WHERE demand_id = iv_demand_id.
      IF ls_allocated-confirmed > 0.
        rv_quantity = rv_quantity + ls_allocated-confirmed.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
