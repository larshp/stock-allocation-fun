CLASS zcl_alloc_owned_by DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_dispo_tab TYPE STANDARD TABLE OF marc-dispo WITH EMPTY KEY.

    "! <p class="shorttext synchronized">Materials of a plant that certain MRP controllers own</p>
    "!
    "! Asked by everything that offers to show or do one planner's work: the
    "! run, the display and the shortage list all mean the same thing by it, so
    "! they all ask the same question here rather than each writing the SELECT
    "! they happen to need.
    "!
    "! A material flagged for deletion in the plant is left out. It is on its
    "! way out and is not worth a planner's morning or a reservation.
    "!
    "! @parameter iv_werks | <p class="shorttext synchronized">Plant</p>
    "! @parameter it_dispo | <p class="shorttext synchronized">MRP controllers, none is no answer</p>
    "! @parameter rt_matnr | <p class="shorttext synchronized">Material numbers, in material order</p>
    CLASS-METHODS materials
      IMPORTING
        iv_werks        TYPE mard-werks
        it_dispo        TYPE ty_dispo_tab
      RETURNING
        VALUE(rt_matnr) TYPE zif_demand_reader=>ty_matnr_tab.

    "! <p class="shorttext synchronized">Whether one material is owned by certain MRP controllers</p>
    "!
    "! For a caller that has a list of materials already and only has to sift
    "! it. An empty list of controllers is no restriction, which is the answer
    "! everything else in this solution gives to an empty list.
    "!
    "! @parameter iv_matnr | <p class="shorttext synchronized">Material number</p>
    "! @parameter it_owned | <p class="shorttext synchronized">What MATERIALS answered</p>
    "! @parameter it_dispo | <p class="shorttext synchronized">MRP controllers, none is no restriction</p>
    "! @parameter rv_owned | <p class="shorttext synchronized">True if the material is covered</p>
    CLASS-METHODS is_owned
      IMPORTING
        iv_matnr        TYPE mard-matnr
        it_owned        TYPE zif_demand_reader=>ty_matnr_tab
        it_dispo        TYPE ty_dispo_tab
      RETURNING
        VALUE(rv_owned) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_owned_by IMPLEMENTATION.

  METHOD materials.

    DATA lt_range TYPE RANGE OF marc-dispo.

    IF it_dispo IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_dispo INTO DATA(lv_dispo).
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = lv_dispo ) TO lt_range.
    ENDLOOP.

    " the plant's material master is read once for the whole list rather than
    " once per material, which is what feature 29 said about MARA
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

  METHOD is_owned.

    IF it_dispo IS INITIAL.
      rv_owned = abap_true.
      RETURN.
    ENDIF.

    rv_owned = xsdbool( line_exists( it_owned[ table_line = iv_matnr ] ) ).

  ENDMETHOD.

ENDCLASS.
