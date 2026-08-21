CLASS zcl_alloc_plant_list DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_line_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    "! <p class="shorttext synchronized">List wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter ro_list | <p class="shorttext synchronized">Ready to use list</p>
    CLASS-METHODS create_default
      RETURNING
        VALUE(ro_list) TYPE REF TO zcl_alloc_plant_list.

    "! <p class="shorttext synchronized">Wire up the list</p>
    "!
    "! @parameter io_store     | <p class="shorttext synchronized">Where runs are recorded</p>
    "! @parameter io_authority | <p class="shorttext synchronized">Decides who may see a plant</p>
    METHODS constructor
      IMPORTING
        io_store     TYPE REF TO zif_allocation_store
        io_authority TYPE REF TO zif_allocation_authority.

    "! <p class="shorttext synchronized">How every plant stands, on one page</p>
    "!
    "! Every report so far takes a plant, because every job takes a plant.
    "! Somebody responsible for more than one of them -- a supply manager, the
    "! person on call at seven in the morning -- has no way of asking the
    "! question they actually have, which is "where is it worst today, and did
    "! everywhere run".
    "!
    "! One line per plant: how many materials the last run of each decided
    "! about, how many lines are short, how much is short, and whether a run
    "! has touched the plant today at all.
    "!
    "! @parameter rt_line | <p class="shorttext synchronized">Lines to display</p>
    METHODS run
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab.

  PRIVATE SECTION.

    CONSTANTS c_width_werks TYPE i VALUE 8.
    CONSTANTS c_width_count TYPE i VALUE 12.
    CONSTANTS c_width_qty   TYPE i VALUE 16.

    "! Reading what the plants decided, changing nothing.
    CONSTANTS c_activity_display TYPE activ_auth VALUE '03'.

    "! What one plant came to.
    TYPES:
      BEGIN OF ty_plant,
        werks     TYPE mard-werks,
        materials TYPE i,
        short     TYPE i,
        quantity  TYPE zif_allocation=>ty_quantity,
        ran_today TYPE abap_bool,
      END OF ty_plant.

    DATA mo_store     TYPE REF TO zif_allocation_store.
    DATA mo_authority TYPE REF TO zif_allocation_authority.

    METHODS stands_of
      IMPORTING
        iv_werks        TYPE mard-werks
      RETURNING
        VALUE(rs_plant) TYPE ty_plant.

    METHODS format_row
      IMPORTING
        iv_werks       TYPE string
        iv_materials   TYPE string
        iv_short       TYPE string
        iv_quantity    TYPE string
        iv_today       TYPE string
      RETURNING
        VALUE(rv_line) TYPE string.

ENDCLASS.


CLASS zcl_alloc_plant_list IMPLEMENTATION.

  METHOD create_default.

    ro_list = NEW zcl_alloc_plant_list(
      io_store     = NEW zcl_allocation_store( )
      io_authority = NEW zcl_authority_alloc( c_activity_display ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_store     = io_store.
    mo_authority = io_authority.

  ENDMETHOD.

  METHOD run.

    DATA lv_shown TYPE i.

    APPEND `How each plant stands, from the last run of each material` TO rt_line.

    SELECT werks
      FROM t001w
      ORDER BY werks
      INTO TABLE @DATA(lt_plant).
    IF sy-subrc <> 0.
      APPEND `There are no plants at all` TO rt_line.
      RETURN.
    ENDIF.

    APPEND format_row(
      iv_werks     = `Plant`
      iv_materials = `Materials`
      iv_short     = `Short lines`
      iv_quantity  = `Short`
      iv_today     = `Ran today` ) TO rt_line.

    LOOP AT lt_plant INTO DATA(ls_plant).

      " a plant the user may not see is left out rather than refused, as in
      " feature 115: a page that stops at the first plant somebody is not
      " responsible for cannot be read by anybody
      TRY.
          mo_authority->check_plant( ls_plant-werks ).
        CATCH zcx_allocation.
          CONTINUE.
      ENDTRY.

      DATA(ls_stands) = stands_of( ls_plant-werks ).
      lv_shown = lv_shown + 1.

      APPEND format_row(
        iv_werks     = |{ ls_stands-werks }|
        iv_materials = |{ ls_stands-materials }|
        iv_short     = |{ ls_stands-short }|
        iv_quantity  = |{ ls_stands-quantity }|
        iv_today     = COND string( WHEN ls_stands-ran_today = abap_true
                                    THEN `yes`
                                    ELSE `no` ) ) TO rt_line.

    ENDLOOP.

    APPEND || TO rt_line.

    IF lv_shown = 0.
      APPEND `No plant here is one you may look at` TO rt_line.
      RETURN.
    ENDIF.

    APPEND |{ lv_shown } plant(s)| TO rt_line.

  ENDMETHOD.

  METHOD stands_of.

    DATA lv_matnr TYPE mard-matnr.

    rs_plant-werks = iv_werks.

    LOOP AT mo_store->latest_per_material( iv_werks ) INTO DATA(ls_recorded).

      " the lines of one material come together, so counting the materials is
      " counting the changes of material
      IF ls_recorded-matnr <> lv_matnr.
        lv_matnr             = ls_recorded-matnr.
        rs_plant-materials = rs_plant-materials + 1.
      ENDIF.

      IF ls_recorded-shortfall <= 0.
        CONTINUE.
      ENDIF.

      rs_plant-short    = rs_plant-short + 1.
      rs_plant-quantity = rs_plant-quantity + ls_recorded-shortfall.

    ENDLOOP.

    " "did everywhere run" is the other half of the question, and it is the
    " same read the coverage check of feature 101 does
    rs_plant-ran_today = xsdbool( zcl_alloc_coverage=>allocated_since( iv_werks ) IS NOT INITIAL ).

  ENDMETHOD.

  METHOD format_row.

    rv_line = |{ iv_werks WIDTH = c_width_werks }|
           && |{ iv_materials WIDTH = c_width_count ALIGN = RIGHT }|
           && |{ iv_short WIDTH = c_width_count ALIGN = RIGHT }|
           && |{ iv_quantity WIDTH = c_width_qty ALIGN = RIGHT }|
           && |  { iv_today }|.

  ENDMETHOD.

ENDCLASS.
