CLASS zcl_alloc_lapse DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_line_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    "! What a closing did. CLOSED counts the proposals that were closed, or
    "! would have been in a test run; LINE says which they were, so a caller
    "! can put them on its own page.
    TYPES:
      BEGIN OF ty_outcome,
        closed TYPE i,
        line   TYPE ty_line_tab,
      END OF ty_outcome.

    "! <p class="shorttext synchronized">Wire up the closing</p>
    "!
    "! @parameter io_transfer | <p class="shorttext synchronized">Where proposals are written down</p>
    "! @parameter io_store    | <p class="shorttext synchronized">Where runs are recorded</p>
    METHODS constructor
      IMPORTING
        io_transfer TYPE REF TO zcl_alloc_transfer
        io_store    TYPE REF TO zif_allocation_store.

    "! <p class="shorttext synchronized">Close every proposal whose shortage has gone</p>
    "!
    "! Two callers ask this: a planner tidying the worklist by hand, and the
    "! nightly proposing before it writes anything new. They have to agree
    "! about what "gone" means, and a copy of the rule in each of them is what
    "! features 148 and 149 were about, so the rule lives here.
    "!
    "! Nothing is committed. The caller decides what one unit of work is.
    "!
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant that is short</p>
    "! @parameter iv_test        | <p class="shorttext synchronized">Say what would be closed, close nothing</p>
    "! @parameter rs_outcome     | <p class="shorttext synchronized">What was closed, and which</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">A proposal could not be closed</p>
    METHODS run
      IMPORTING
        iv_werks          TYPE mard-werks
        iv_test           TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_outcome) TYPE ty_outcome
      RAISING
        zcx_allocation.

    "! <p class="shorttext synchronized">Whether a material is still short in this plant</p>
    "!
    "! Public because the worklist marks the stale rows as well as closing
    "! them, and a page that called one material stale while the closing
    "! called it live would be two answers to one question.
    "!
    "! @parameter iv_werks | <p class="shorttext synchronized">Plant</p>
    "! @parameter iv_matnr | <p class="shorttext synchronized">Material</p>
    "! @parameter rv_short | <p class="shorttext synchronized">True while something is still waiting</p>
    METHODS still_short
      IMPORTING
        iv_werks        TYPE mard-werks
        iv_matnr        TYPE mard-matnr
      RETURNING
        VALUE(rv_short) TYPE abap_bool.

  PRIVATE SECTION.

    DATA mo_transfer TYPE REF TO zcl_alloc_transfer.
    DATA mo_store    TYPE REF TO zif_allocation_store.

ENDCLASS.


CLASS zcl_alloc_lapse IMPLEMENTATION.

  METHOD constructor.

    mo_transfer = io_transfer.
    mo_store    = io_store.

  ENDMETHOD.

  METHOD run.

    LOOP AT mo_transfer->open_for( iv_werks ) INTO DATA(ls_open).

      IF still_short(
          iv_werks = iv_werks
          iv_matnr = ls_open-matnr ) = abap_true.
        CONTINUE.
      ENDIF.

      IF iv_test = abap_false.
        mo_transfer->lapse( ls_open-proposal ).
      ENDIF.

      rs_outcome-closed = rs_outcome-closed + 1.

      APPEND |{ ls_open-proposal } { ls_open-matnr } from { ls_open-from_werks }|
        TO rs_outcome-line.

    ENDLOOP.

  ENDMETHOD.

  METHOD still_short.

    " the last run of the material is what stands, so that is what says
    " whether the note is still worth acting on. A material the newest run
    " has nothing to say about is one nothing is waiting for, which is a
    " shortage that has gone as surely as one that was served.
    LOOP AT mo_store->latest_per_material(
        iv_werks = iv_werks
        iv_matnr = iv_matnr ) INTO DATA(ls_recorded).
      IF ls_recorded-shortfall > 0.
        rv_short = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
