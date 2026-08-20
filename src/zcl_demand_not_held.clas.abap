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

    "! An empty date field, which SQL will not compare against SPACE.
    CONSTANTS c_no_date TYPE d VALUE '00000000'.

    DATA mo_demand TYPE REF TO zif_demand_reader.
    DATA mv_today  TYPE d.

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

    " a hold with a date on it lifts by itself on that day, which is what
    " somebody putting one on for a stock count wants; a hold without one
    " stays until somebody takes it off, which is what a quality problem
    " wants. The row is left in the table either way, so there is a record of
    " what was held and why.
    SELECT matnr
      FROM zstock_alloc_hld
      WHERE werks = @iv_werks
        AND ( until_date = @c_no_date
           OR until_date >= @mv_today )
      ORDER BY matnr
      INTO TABLE @rt_matnr.
    IF sy-subrc <> 0.
      CLEAR rt_matnr.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
