CLASS zcl_alloc_firm DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_alloc_floor.

    "! No firm zone at all, which is what a plant gets until it asks for one.
    CONSTANTS c_no_firm TYPE i VALUE 0.

    "! <p class="shorttext synchronized">What ships this week is not taken back</p>
    "!
    "! A re-cut is the right thing to do to the stock and a hard thing to do
    "! to a customer, which is why feature 75 exists: somebody reads the
    "! differences in the morning and telephones the people who lost
    "! something. What that list cannot help with is the line that was picked
    "! yesterday and is loading tomorrow. Taking stock away from it does not
    "! move any goods -- they are on the ramp -- it only makes the paperwork
    "! disagree with the lorry.
    "!
    "! So a plant can say how far ahead its answers are firm. A line due
    "! within that many days keeps what the last recorded run confirmed for
    "! it, before the distribution rules see the stock at all, and the re-cut
    "! then does its work on what is left. Everything further out is still
    "! re-cut every night, which is the whole point of running again.
    "!
    "! @parameter iv_days  | <p class="shorttext synchronized">Days ahead that are firm, 0 for none</p>
    "! @parameter io_store | <p class="shorttext synchronized">Where runs are recorded, the real one if none</p>
    METHODS constructor
      IMPORTING
        iv_days  TYPE i DEFAULT c_no_firm
        io_store TYPE REF TO zif_allocation_store OPTIONAL.

  PRIVATE SECTION.

    DATA mv_days  TYPE i.
    DATA mo_store TYPE REF TO zif_allocation_store.

    "! What the last run of every material in the plant decided, read the
    "! first time anything is allocated in it: one round trip per material
    "! would be five thousand of them for a plant wide run. Same reasoning as
    "! ZCL_ALLOC_QUOTA, and it has the same happy side effect -- the snapshot
    "! is from before this run wrote anything, so what is firm is what the
    "! last run said and not what this one has just decided about the
    "! materials it got to first.
    DATA mt_recorded TYPE zif_allocation_store=>ty_recorded_tab.
    DATA mv_werks    TYPE mard-werks.
    DATA mv_read     TYPE abap_bool.

    METHODS recorded_in
      IMPORTING
        iv_werks           TYPE mard-werks
      RETURNING
        VALUE(rt_recorded) TYPE zif_allocation_store=>ty_recorded_tab.

ENDCLASS.


CLASS zcl_alloc_firm IMPLEMENTATION.

  METHOD constructor.

    mv_days  = iv_days.
    mo_store = io_store.
    IF mo_store IS NOT BOUND.
      mo_store = NEW zcl_allocation_store( ).
    ENDIF.

  ENDMETHOD.

  METHOD zif_alloc_floor~floors_for.

    DATA lv_until TYPE d.
    DATA ls_floor TYPE zif_alloc_floor=>ty_floor.

    IF mv_days <= c_no_firm.
      RETURN.
    ENDIF.

    READ TABLE it_demand INTO DATA(ls_first) INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    lv_until = sy-datum + mv_days.

    DATA(lt_recorded) = recorded_in( ls_first-werks ).

    LOOP AT it_demand INTO DATA(ls_demand).

      " the requested date the run is working with, not the one the last run
      " recorded: a line moved out of the firm zone since last night is no
      " longer loading tomorrow, and a line moved into it is
      IF ls_demand-req_date > lv_until.
        CONTINUE.
      ENDIF.

      READ TABLE lt_recorded INTO DATA(ls_recorded)
        WITH KEY matnr     = ls_first-matnr
                 demand_id = ls_demand-demand_id.
      IF sy-subrc <> 0 OR ls_recorded-confirmed <= 0.
        CONTINUE.
      ENDIF.

      ls_floor-demand_id = ls_demand-demand_id.
      ls_floor-quantity  = ls_recorded-confirmed.
      APPEND ls_floor TO rt_floor.

    ENDLOOP.

  ENDMETHOD.

  METHOD recorded_in.

    IF mv_read = abap_true AND mv_werks = iv_werks.
      rt_recorded = mt_recorded.
      RETURN.
    ENDIF.

    mt_recorded = mo_store->latest_per_material( iv_werks ).
    mv_werks    = iv_werks.
    mv_read     = abap_true.

    rt_recorded = mt_recorded.

  ENDMETHOD.

ENDCLASS.
