CLASS zcl_demand_of_controller DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    TYPES ty_dispo_tab TYPE STANDARD TABLE OF marc-dispo WITH EMPTY KEY.

    "! <p class="shorttext synchronized">Cover only the materials of certain MRP controllers</p>
    "!
    "! A plant with fifty thousand materials is one nightly job that either
    "! finishes or does not. Split by MRP controller it is several, which can
    "! run beside each other, be repeated on their own when one of them fails,
    "! and be handed to the planner who owns them. An empty list is every
    "! controller, which is what a plant that has never split its run gets.
    "!
    "! @parameter io_demand | <p class="shorttext synchronized">Reader that says which materials are waiting</p>
    "! @parameter it_dispo  | <p class="shorttext synchronized">MRP controllers to cover, all if empty</p>
    METHODS constructor
      IMPORTING
        io_demand TYPE REF TO zif_demand_reader
        it_dispo  TYPE ty_dispo_tab OPTIONAL.

  PRIVATE SECTION.

    TYPES ty_dispo_range TYPE RANGE OF marc-dispo.

    DATA mo_demand TYPE REF TO zif_demand_reader.
    DATA mt_dispo  TYPE ty_dispo_tab.

    METHODS materials_of_controllers
      IMPORTING
        iv_werks        TYPE mard-werks
      RETURNING
        VALUE(rt_matnr) TYPE zif_demand_reader=>ty_matnr_tab.

ENDCLASS.


CLASS zcl_demand_of_controller IMPLEMENTATION.

  METHOD constructor.

    mo_demand = io_demand.
    mt_dispo  = it_dispo.

  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.

    rt_matnr = mo_demand->materials_with_demand( iv_werks ).

    " no list is no restriction rather than nothing allowed, the same answer
    " ZCL_STOCK_IN_LOCATIONS gives an empty list of storage locations
    IF mt_dispo IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lt_owned) = materials_of_controllers( iv_werks ).
    DATA(lt_kept)  = VALUE zif_demand_reader=>ty_matnr_tab( ).

    LOOP AT rt_matnr INTO DATA(lv_matnr).
      IF line_exists( lt_owned[ table_line = lv_matnr ] ).
        APPEND lv_matnr TO lt_kept.
      ENDIF.
    ENDLOOP.

    rt_matnr = lt_kept.

  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.

    " the demand of a material is the demand of a material: which planner looks
    " after it says whether the run covers it, not what it is owed. A caller
    " naming a material outright gets its demand whoever owns it.
    rt_demand = mo_demand->read_open_demand(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

  ENDMETHOD.

  METHOD materials_of_controllers.

    DATA lt_range TYPE ty_dispo_range.

    LOOP AT mt_dispo INTO DATA(lv_dispo).
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = lv_dispo ) TO lt_range.
    ENDLOOP.

    " the material master of the plant is read once for the whole list rather
    " than once per material, which is what feature 29 said about MARA and is
    " the same argument here
    SELECT matnr
      FROM marc
      WHERE werks = @iv_werks
        AND dispo IN @lt_range
        AND lvorm = @space
      ORDER BY matnr
      INTO TABLE @rt_matnr.
    IF sy-subrc <> 0.
      CLEAR rt_matnr.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
