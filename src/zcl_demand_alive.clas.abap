CLASS zcl_demand_alive DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    "! <p class="shorttext synchronized">Leave out materials that are on their way out</p>
    "!
    "! A material flagged for deletion is one somebody has decided the plant is
    "! finished with. Allocating it earmarks stock that is meant to be used up
    "! or written off, and puts a reservation on a material that cannot be
    "! archived until somebody finds the reservation and removes it.
    "!
    "! Both flags count: the one on the material in this plant and the one on
    "! the material itself, because either of them says the same thing.
    "!
    "! @parameter io_demand | <p class="shorttext synchronized">Reader of the demand as the documents have it</p>
    METHODS constructor
      IMPORTING
        io_demand TYPE REF TO zif_demand_reader.

  PRIVATE SECTION.

    DATA mo_demand TYPE REF TO zif_demand_reader.

    METHODS is_flagged
      IMPORTING
        iv_matnr          TYPE mard-matnr
        iv_werks          TYPE mard-werks
      RETURNING
        VALUE(rv_flagged) TYPE abap_bool.

    METHODS flagged_in_plant
      IMPORTING
        iv_werks        TYPE mard-werks
      RETURNING
        VALUE(rt_matnr) TYPE zif_demand_reader=>ty_matnr_tab.

ENDCLASS.


CLASS zcl_demand_alive IMPLEMENTATION.

  METHOD constructor.
    mo_demand = io_demand.
  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.

    DATA(lt_flagged) = flagged_in_plant( iv_werks ).
    IF lt_flagged IS INITIAL.
      rt_matnr = mo_demand->materials_with_demand( iv_werks ).
      RETURN.
    ENDIF.

    LOOP AT mo_demand->materials_with_demand( iv_werks ) INTO DATA(lv_matnr).
      IF NOT line_exists( lt_flagged[ table_line = lv_matnr ] ).
        APPEND lv_matnr TO rt_matnr.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.

    " asked per material as well as per list, because a caller can name a
    " material outright -- the report takes one, and a material being deleted
    " is exactly the kind somebody types in to see what is holding it up. One
    " row read against the twenty a run reads anyway.
    IF is_flagged(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ) = abap_true.
      RETURN.
    ENDIF.

    rt_demand = mo_demand->read_open_demand(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

  ENDMETHOD.

  METHOD flagged_in_plant.

    " the plant's own flags, read once for the whole list. The material master
    " flag is asked for per material below, because a client wide deletion
    " flag on a material that still has demand in a plant is rare enough not
    " to be worth reading the whole of MARA for.
    SELECT matnr
      FROM marc
      WHERE werks = @iv_werks
        AND lvorm <> @space
      ORDER BY matnr
      INTO TABLE @rt_matnr.
    IF sy-subrc <> 0.
      CLEAR rt_matnr.
    ENDIF.

  ENDMETHOD.

  METHOD is_flagged.

    SELECT SINGLE lvorm
      FROM marc
      WHERE matnr = @iv_matnr
        AND werks = @iv_werks
      INTO @DATA(lv_plant_flag).
    IF sy-subrc = 0 AND lv_plant_flag <> space.
      rv_flagged = abap_true.
      RETURN.
    ENDIF.

    SELECT SINGLE lvorm
      FROM mara
      WHERE matnr = @iv_matnr
      INTO @DATA(lv_flag).
    IF sy-subrc = 0 AND lv_flag <> space.
      rv_flagged = abap_true.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
