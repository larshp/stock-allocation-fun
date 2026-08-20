CLASS zcl_alloc_shortage_list DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_line_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    "! <p class="shorttext synchronized">Worklist wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter ro_list | <p class="shorttext synchronized">Ready to use worklist</p>
    CLASS-METHODS create_default
      RETURNING
        VALUE(ro_list) TYPE REF TO zcl_alloc_shortage_list.

    "! <p class="shorttext synchronized">Wire up the worklist</p>
    "!
    "! @parameter io_store     | <p class="shorttext synchronized">Where runs are recorded</p>
    "! @parameter io_authority | <p class="shorttext synchronized">Decides who may see a plant</p>
    METHODS constructor
      IMPORTING
        io_store     TYPE REF TO zif_allocation_store
        io_authority TYPE REF TO zif_allocation_authority.

    "! <p class="shorttext synchronized">Everything in a plant that did not get what it asked for</p>
    "!
    "! The display report answers "what happened to this material". This
    "! answers the other question a planner has in the morning: what is short
    "! across the whole plant, worst first, and what to do about each of them.
    "! It reads the last recorded run per material and changes nothing.
    "!
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
    "! @parameter iv_until       | <p class="shorttext synchronized">Only lines wanted by this day, all if empty</p>
    "! @parameter iv_top         | <p class="shorttext synchronized">Most lines to show, all if zero</p>
    "! @parameter iv_dispo       | <p class="shorttext synchronized">MRP controller, every one if empty</p>
    "! @parameter rt_line        | <p class="shorttext synchronized">Lines to display</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">Plant may not be displayed</p>
    METHODS run
      IMPORTING
        iv_werks       TYPE mard-werks
        iv_until       TYPE d OPTIONAL
        iv_top         TYPE i DEFAULT 0
        iv_dispo       TYPE marc-dispo OPTIONAL
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab
      RAISING
        zcx_allocation.

  PRIVATE SECTION.

    CONSTANTS c_width_date TYPE i VALUE 12.
    CONSTANTS c_width_matnr TYPE i VALUE 20.
    CONSTANTS c_width_id   TYPE i VALUE 26.
    CONSTANTS c_width_qty  TYPE i VALUE 14.
    CONSTANTS c_width_why  TYPE i VALUE 22.

    "! Reading what a run decided, not deciding anything.
    CONSTANTS c_activity_display TYPE activ_auth VALUE '03'.

    DATA mo_store     TYPE REF TO zif_allocation_store.
    DATA mo_authority TYPE REF TO zif_allocation_authority.

    METHODS short_lines
      IMPORTING
        it_recorded        TYPE zif_allocation_store=>ty_recorded_tab
        iv_until           TYPE d
        iv_werks           TYPE mard-werks
        iv_dispo           TYPE marc-dispo
      RETURNING
        VALUE(rt_recorded) TYPE zif_allocation_store=>ty_recorded_tab.

    METHODS format_row
      IMPORTING
        iv_date        TYPE string
        iv_matnr       TYPE string
        iv_id          TYPE string
        iv_short       TYPE string
        iv_reason      TYPE string
      RETURNING
        VALUE(rv_line) TYPE string.

    METHODS date_text
      IMPORTING
        iv_date        TYPE d
      RETURNING
        VALUE(rv_text) TYPE string.

ENDCLASS.


CLASS zcl_alloc_shortage_list IMPLEMENTATION.

  METHOD create_default.

    ro_list = NEW zcl_alloc_shortage_list(
      io_store     = NEW zcl_allocation_store( )
      io_authority = NEW zcl_authority_plant( c_activity_display ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_store     = io_store.
    mo_authority = io_authority.

  ENDMETHOD.

  METHOD run.

    DATA lv_short TYPE zif_allocation=>ty_quantity.
    DATA lv_shown TYPE i.

    mo_authority->check_plant( iv_werks ).

    DATA(lt_short) = short_lines(
      it_recorded = mo_store->latest_per_material( iv_werks )
      iv_until    = iv_until
      iv_werks    = iv_werks
      iv_dispo    = iv_dispo ).

    APPEND |Plant { iv_werks }, what is short| TO rt_line.

    IF lt_short IS INITIAL.
      APPEND `Nothing is short` TO rt_line.
      RETURN.
    ENDIF.

    APPEND format_row(
      iv_date   = `Wanted`
      iv_matnr  = `Material`
      iv_id     = `Demand`
      iv_short  = `Short`
      iv_reason = `Why` ) TO rt_line.

    LOOP AT lt_short INTO DATA(ls_short).

      " a worklist longer than anybody will work through is a list nobody
      " reads. What is cut off is counted in the footer rather than dropped
      " quietly.
      IF iv_top > 0 AND lv_shown >= iv_top.
        EXIT.
      ENDIF.
      lv_shown = lv_shown + 1.
      lv_short = lv_short + ls_short-shortfall.

      APPEND format_row(
        iv_date   = date_text( ls_short-req_date )
        iv_matnr  = |{ ls_short-matnr }|
        iv_id     = |{ ls_short-demand_id }|
        iv_short  = |{ ls_short-shortfall }|
        iv_reason = zcl_alloc_reason_text=>text( ls_short-reason ) ) TO rt_line.

    ENDLOOP.

    APPEND || TO rt_line.
    APPEND |{ lv_shown } of { lines( lt_short ) } short lines shown, | &&
           |{ lv_short } short in what is shown| TO rt_line.

  ENDMETHOD.

  METHOD short_lines.

    DATA lt_dispo TYPE zcl_alloc_owned_by=>ty_dispo_tab.

    " a planner asking for their own materials means the ones they look after
    IF iv_dispo IS NOT INITIAL.
      APPEND iv_dispo TO lt_dispo.
    ENDIF.

    DATA(lt_owned) = zcl_alloc_owned_by=>materials(
      iv_werks = iv_werks
      it_dispo = lt_dispo ).

    LOOP AT it_recorded INTO DATA(ls_recorded).

      IF zcl_alloc_owned_by=>is_owned(
          iv_matnr = ls_recorded-matnr
          it_owned = lt_owned
          it_dispo = lt_dispo ) = abap_false.
        CONTINUE.
      ENDIF.

      IF ls_recorded-shortfall <= 0.
        CONTINUE.
      ENDIF.

      " a line wanted after the day the planner is looking at is somebody
      " else's problem this morning
      IF iv_until IS NOT INITIAL
          AND ls_recorded-req_date IS NOT INITIAL
          AND ls_recorded-req_date > iv_until.
        CONTINUE.
      ENDIF.

      APPEND ls_recorded TO rt_recorded.

    ENDLOOP.

    " the day it is wanted decides the order, because that is what makes one
    " shortage more urgent than another. A line with no date is wanted now and
    " sorts first, which is what the initial date does anyway. Within a day the
    " biggest hole comes first, and the material keeps the order steady.
    SORT rt_recorded BY req_date ASCENDING
                        shortfall DESCENDING
                        matnr ASCENDING
                        demand_id ASCENDING.

  ENDMETHOD.

  METHOD format_row.

    rv_line = |{ iv_date WIDTH = c_width_date }|
           && |{ iv_matnr WIDTH = c_width_matnr }|
           && |{ iv_id WIDTH = c_width_id }|
           && |{ iv_short WIDTH = c_width_qty ALIGN = RIGHT }|
           && |  { iv_reason WIDTH = c_width_why }|.

  ENDMETHOD.

  METHOD date_text.

    IF iv_date IS INITIAL.
      rv_text = `now`.
      RETURN.
    ENDIF.

    rv_text = |{ iv_date+0(4) }-{ iv_date+4(2) }-{ iv_date+6(2) }|.

  ENDMETHOD.

ENDCLASS.
