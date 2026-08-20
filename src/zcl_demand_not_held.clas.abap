CLASS zcl_demand_not_held DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    "! <p class="shorttext synchronized">Leave out materials the plant has put on hold</p>
    "!
    "! Somebody finds a quality problem, or a customer's whole order is about
    "! to be cancelled, or the last pallet is being counted again: whatever the
    "! reason, the answer is "do not give this away tonight". Without somewhere
    "! to say that, the only ways to stop a nightly run touching one material
    "! are to block every order for it or to turn the job off.
    "!
    "! `ZSTOCK_ALLOC_HLD` is that somewhere: a material, a plant, a reason and
    "! optionally a day the hold lifts by itself.
    "!
    "! @parameter io_demand | <p class="shorttext synchronized">Reader of the demand as the documents have it</p>
    "! @parameter iv_today  | <p class="shorttext synchronized">Day to measure a hold against, today if empty</p>
    METHODS constructor
      IMPORTING
        io_demand TYPE REF TO zif_demand_reader
        iv_today  TYPE d OPTIONAL.

  PRIVATE SECTION.

    DATA mo_demand TYPE REF TO zif_demand_reader.
    DATA mv_today  TYPE d.

    "! The plant's holds, read the first time anything asks and kept for the
    "! rest of the run. A plant wide run asks once per material, and the
    "! answer is the same every time: one read for five thousand materials
    "! rather than five thousand reads, which is what feature 29 said about
    "! the material master.
    DATA mt_held   TYPE zif_demand_reader=>ty_matnr_tab.
    DATA mv_read   TYPE abap_bool.
    DATA mv_plant  TYPE mard-werks.

    METHODS held_in_plant
      IMPORTING
        iv_werks        TYPE mard-werks
      RETURNING
        VALUE(rt_matnr) TYPE zif_demand_reader=>ty_matnr_tab.

ENDCLASS.


CLASS zcl_demand_not_held IMPLEMENTATION.

  METHOD constructor.

    mo_demand = io_demand.

    " the day is handed in so a test can say what today is
    mv_today = iv_today.
    IF mv_today IS INITIAL.
      mv_today = sy-datum.
    ENDIF.

  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.

    DATA(lt_held) = held_in_plant( iv_werks ).
    IF lt_held IS INITIAL.
      rt_matnr = mo_demand->materials_with_demand( iv_werks ).
      RETURN.
    ENDIF.

    LOOP AT mo_demand->materials_with_demand( iv_werks ) INTO DATA(lv_matnr).
      IF NOT line_exists( lt_held[ table_line = lv_matnr ] ).
        APPEND lv_matnr TO rt_matnr.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.

    " asked per material as well, because a hold that a run honours and a
    " report ignores is a hold nobody can rely on
    DATA(lt_held) = held_in_plant( iv_werks ).

    IF line_exists( lt_held[ table_line = iv_matnr ] ).
      RETURN.
    ENDIF.

    rt_demand = mo_demand->read_open_demand(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

  ENDMETHOD.

  METHOD held_in_plant.

    " one instance serves one plant in practice, and answers for another are
    " read again rather than kept: a reader asked about two plants is a reader
    " somebody wired unusually, and it must still be right
    IF mv_read = abap_true AND mv_plant = iv_werks.
      rt_matnr = mt_held.
      RETURN.
    ENDIF.

    mt_held = zcl_alloc_hold=>materials(
      iv_werks = iv_werks
      iv_today = mv_today ).

    mv_plant = iv_werks.
    mv_read  = abap_true.

    rt_matnr = mt_held.

  ENDMETHOD.

ENDCLASS.
