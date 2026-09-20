CLASS zcl_alloc_spare DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    "! What one plant could let go of, and the numbers it follows from.
    "!
    "! ON_HAND is what is on the shelf there and COMING what is still to
    "! arrive: both could be transferred, and they are not the same offer, so
    "! they stay apart. WANTED is what that plant has still to serve. SPARE is
    "! what is left of the first two after the third, never below nought.
    "!
    "! PROMISED is what other plants have open notes against this one for, and
    "! FREE is SPARE less that: what somebody could still ask it for today
    "! without two plants being told to take the same pallet. The two are
    "! reported apart because they answer different questions -- "has the
    "! stock gone" is about SPARE, and "may I ask for it" is about FREE.
    TYPES:
      BEGIN OF ty_spare,
        on_hand  TYPE zif_allocation=>ty_quantity,
        coming   TYPE zif_allocation=>ty_quantity,
        wanted   TYPE zif_allocation=>ty_quantity,
        spare    TYPE zif_allocation=>ty_quantity,
        promised TYPE zif_allocation=>ty_quantity,
        free     TYPE zif_allocation=>ty_quantity,
      END OF ty_spare.

    "! <p class="shorttext synchronized">Wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter ro_spare | <p class="shorttext synchronized">Ready to use</p>
    CLASS-METHODS create_default
      RETURNING
        VALUE(ro_spare) TYPE REF TO zcl_alloc_spare.

    "! <p class="shorttext synchronized">Wire up the arithmetic</p>
    "!
    "! @parameter io_supply   | <p class="shorttext synchronized">What a material has to give away, per plant</p>
    "! @parameter io_demand   | <p class="shorttext synchronized">What is waiting for it there, per plant</p>
    "! @parameter io_transfer | <p class="shorttext synchronized">What it has already been asked for</p>
    METHODS constructor
      IMPORTING
        io_supply   TYPE REF TO zif_supply_reader
        io_demand   TYPE REF TO zif_demand_reader
        io_transfer TYPE REF TO zcl_alloc_transfer.

    "! <p class="shorttext synchronized">What another plant could let go of</p>
    "!
    "! Three things ask this now: the page that says where else the stock is,
    "! the nightly proposing that turns the same numbers into notes, and the
    "! worklist that has to say whether a note somebody wrote last week can
    "! still be acted on. A copy of the arithmetic in each of them is what
    "! features 148, 149 and 165 were about, so it lives here.
    "!
    "! What a plant has is not what it can spare. A plant sitting on a hundred
    "! with a hundred waiting for them has nothing to send, and an answer that
    "! offered them would send a planner to ask for stock that is already
    "! somebody else's.
    "!
    "! The plant's stock and demand are read the way that plant reads its own:
    "! its storage locations, its view of its own plan, its horizon. A number
    "! worked out any other way is stock the other plant would not have given
    "! away either.
    "!
    "! A plant that owes more than it has spares nothing rather than a negative
    "! amount: what it is short of itself is its own problem and is not part of
    "! this answer.
    "!
    "! What other plants have already been told to take is not on offer twice.
    "! Two plants that both raise a transfer against the same pallet end with
    "! one of them finding out at the loading bay, so the open notes against
    "! this plant come off in FREE.
    "!
    "! @parameter iv_matnr       | <p class="shorttext synchronized">Material</p>
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant asked about</p>
    "! @parameter rs_spare       | <p class="shorttext synchronized">What it has, owes and can spare</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">Stock or demand could not be read</p>
    METHODS at_plant
      IMPORTING
        iv_matnr        TYPE mard-matnr
        iv_werks        TYPE mard-werks
      RETURNING
        VALUE(rs_spare) TYPE ty_spare
      RAISING
        zcx_allocation.

  PRIVATE SECTION.

    DATA mo_supply   TYPE REF TO zif_supply_reader.
    DATA mo_demand   TYPE REF TO zif_demand_reader.
    DATA mo_transfer TYPE REF TO zcl_alloc_transfer.

ENDCLASS.


CLASS zcl_alloc_spare IMPLEMENTATION.

  METHOD create_default.

    ro_spare = NEW zcl_alloc_spare(
      io_supply   = NEW zcl_supply_per_plant( )
      io_demand   = NEW zcl_demand_per_plant( )
      io_transfer = NEW zcl_alloc_transfer( ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_supply   = io_supply.
    mo_demand   = io_demand.
    mo_transfer = io_transfer.

  ENDMETHOD.

  METHOD at_plant.

    " stock on the shelf has no availability date, which is what feature 34
    " settled: it has been there since before any requirement was raised
    LOOP AT mo_supply->read_supply(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ) INTO DATA(ls_supply).

      IF ls_supply-avail_date IS INITIAL.
        rs_spare-on_hand = rs_spare-on_hand + ls_supply-quantity.
      ELSE.
        rs_spare-coming = rs_spare-coming + ls_supply-quantity.
      ENDIF.

    ENDLOOP.

    " net of what has already been delivered and of what that plant's own
    " earlier runs set aside, and only as far ahead as it looks: a plant is not
    " holding stock back for a line it is not going to serve this month either
    LOOP AT mo_demand->read_open_demand(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ) INTO DATA(ls_demand).
      IF ls_demand-quantity > 0.
        rs_spare-wanted = rs_spare-wanted + ls_demand-quantity.
      ENDIF.
    ENDLOOP.

    rs_spare-spare = rs_spare-on_hand + rs_spare-coming - rs_spare-wanted.
    IF rs_spare-spare < 0.
      rs_spare-spare = 0.
    ENDIF.

    rs_spare-promised = mo_transfer->promised_by(
      iv_matnr      = iv_matnr
      iv_from_werks = iv_werks ).

    rs_spare-free = rs_spare-spare - rs_spare-promised.
    IF rs_spare-free < 0.
      rs_spare-free = 0.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
