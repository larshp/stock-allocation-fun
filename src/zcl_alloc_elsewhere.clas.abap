CLASS zcl_alloc_elsewhere DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_line_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    "! <p class="shorttext synchronized">List wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter ro_list | <p class="shorttext synchronized">Ready to use list</p>
    CLASS-METHODS create_default
      RETURNING
        VALUE(ro_list) TYPE REF TO zcl_alloc_elsewhere.

    "! <p class="shorttext synchronized">Wire up the list</p>
    "!
    "! @parameter io_supply    | <p class="shorttext synchronized">What a material has to give away, per plant</p>
    "! @parameter io_store     | <p class="shorttext synchronized">Where runs are recorded</p>
    "! @parameter io_authority | <p class="shorttext synchronized">Decides who may see a plant</p>
    METHODS constructor
      IMPORTING
        io_supply    TYPE REF TO zif_supply_reader
        io_store     TYPE REF TO zif_allocation_store
        io_authority TYPE REF TO zif_allocation_authority.

    "! <p class="shorttext synchronized">Which other plants have what this one is short of</p>
    "!
    "! The substitute list of feature 108 answers "would the customer take
    "! something else". This answers the other question a planner asks on a
    "! short morning: is the material sitting in another plant. It is the same
    "! material, so there is nothing to agree with the customer -- only a
    "! transfer to raise, which is somebody's decision and not this program's.
    "!
    "! Every plant's stock is read the way that plant reads its own: its
    "! storage locations, its view of its own plan. A number worked out any
    "! other way is stock the other plant would not have given away either.
    "!
    "! A plant the user may not see is left out rather than refused: this is a
    "! list about the plant that is short, and a user allowed to see that one
    "! is not thereby allowed to see the rest of the company.
    "!
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant that is short</p>
    "! @parameter iv_matnr       | <p class="shorttext synchronized">Material, every short one if empty</p>
    "! @parameter rt_line        | <p class="shorttext synchronized">Lines to display</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">Plant may not be seen, or reading failed</p>
    METHODS run
      IMPORTING
        iv_werks       TYPE mard-werks
        iv_matnr       TYPE mard-matnr OPTIONAL
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab
      RAISING
        zcx_allocation.

  PRIVATE SECTION.

    CONSTANTS c_width_werks TYPE i VALUE 10.
    CONSTANTS c_width_qty   TYPE i VALUE 14.

    "! Reading what is short and what other plants have, changing neither.
    CONSTANTS c_activity_display TYPE activ_auth VALUE '03'.

    "! One material that is short, and by how much.
    TYPES:
      BEGIN OF ty_short,
        matnr    TYPE mard-matnr,
        quantity TYPE zif_allocation=>ty_quantity,
      END OF ty_short.
    TYPES ty_short_tab TYPE STANDARD TABLE OF ty_short WITH EMPTY KEY.

    TYPES ty_werks_tab TYPE STANDARD TABLE OF mard-werks WITH EMPTY KEY.

    DATA mo_supply    TYPE REF TO zif_supply_reader.
    DATA mo_store     TYPE REF TO zif_allocation_store.
    DATA mo_authority TYPE REF TO zif_allocation_authority.

    "! The plants already asked about, and whether the user may see them: a
    "! material short in forty materials of the same plants would otherwise be
    "! forty authority checks per plant.
    TYPES:
      BEGIN OF ty_allowed,
        werks   TYPE mard-werks,
        allowed TYPE abap_bool,
      END OF ty_allowed.
    TYPES ty_allowed_tab TYPE STANDARD TABLE OF ty_allowed WITH EMPTY KEY.

    DATA mt_allowed TYPE ty_allowed_tab.

    METHODS short_materials
      IMPORTING
        iv_werks        TYPE mard-werks
        iv_matnr        TYPE mard-matnr
      RETURNING
        VALUE(rt_short) TYPE ty_short_tab.

    METHODS other_plants
      IMPORTING
        iv_matnr        TYPE mard-matnr
        iv_werks        TYPE mard-werks
      RETURNING
        VALUE(rt_werks) TYPE ty_werks_tab.

    METHODS may_see
      IMPORTING
        iv_werks       TYPE mard-werks
      RETURNING
        VALUE(rv_seen) TYPE abap_bool.

    METHODS lines_for
      IMPORTING
        is_short       TYPE ty_short
        iv_werks       TYPE mard-werks
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab
      RAISING
        zcx_allocation.

    METHODS format_row
      IMPORTING
        iv_werks       TYPE string
        iv_now         TYPE string
        iv_later       TYPE string
        iv_covers      TYPE string
      RETURNING
        VALUE(rv_line) TYPE string.

ENDCLASS.


CLASS zcl_alloc_elsewhere IMPLEMENTATION.

  METHOD create_default.

    ro_list = NEW zcl_alloc_elsewhere(
      io_supply    = NEW zcl_supply_per_plant( )
      io_store     = NEW zcl_allocation_store( )
      io_authority = NEW zcl_authority_alloc( c_activity_display ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_supply    = io_supply.
    mo_store     = io_store.
    mo_authority = io_authority.

  ENDMETHOD.

  METHOD run.

    mo_authority->check_plant( iv_werks ).

    APPEND |Plant { iv_werks }, where else the stock is| TO rt_line.

    DATA(lt_short) = short_materials(
      iv_werks = iv_werks
      iv_matnr = iv_matnr ).

    IF lt_short IS INITIAL.
      APPEND `Nothing was short in the last run` TO rt_line.
      RETURN.
    ENDIF.

    LOOP AT lt_short INTO DATA(ls_short).
      APPEND LINES OF lines_for(
        is_short = ls_short
        iv_werks = iv_werks ) TO rt_line.
    ENDLOOP.

  ENDMETHOD.

  METHOD short_materials.

    DATA ls_short TYPE ty_short.

    " what the last run of each material could not serve, added up per
    " material: which line is short matters to the customer, and where the
    " stock is is a question about the material
    LOOP AT mo_store->latest_per_material(
        iv_werks = iv_werks
        iv_matnr = iv_matnr ) INTO DATA(ls_recorded).

      IF ls_recorded-shortfall <= 0.
        CONTINUE.
      ENDIF.

      READ TABLE rt_short INTO ls_short
        WITH KEY matnr = ls_recorded-matnr.
      IF sy-subrc = 0.
        ls_short-quantity = ls_short-quantity + ls_recorded-shortfall.
        MODIFY rt_short FROM ls_short
          TRANSPORTING quantity
          WHERE matnr = ls_short-matnr.
        CONTINUE.
      ENDIF.

      ls_short-matnr    = ls_recorded-matnr.
      ls_short-quantity = ls_recorded-shortfall.
      APPEND ls_short TO rt_short.

    ENDLOOP.

  ENDMETHOD.

  METHOD other_plants.

    " a plant that has the material extended to it is a plant that could hold
    " it. One flagged for deletion there is on its way out and is not somewhere
    " to move goods to or from.
    SELECT werks
      FROM marc
      WHERE matnr = @iv_matnr
        AND werks <> @iv_werks
        AND lvorm = @space
      ORDER BY werks
      INTO TABLE @rt_werks.
    IF sy-subrc <> 0.
      CLEAR rt_werks.
    ENDIF.

  ENDMETHOD.

  METHOD may_see.

    IF line_exists( mt_allowed[ werks = iv_werks ] ).
      rv_seen = mt_allowed[ werks = iv_werks ]-allowed.
      RETURN.
    ENDIF.

    " the authority object answers by raising, so asking whether a user may
    " see a plant is asking it and catching the no. Nothing is read for a
    " plant that answers no, which is the point.
    TRY.
        mo_authority->check_plant( iv_werks ).
        rv_seen = abap_true.
      CATCH zcx_allocation.
        rv_seen = abap_false.
    ENDTRY.

    APPEND VALUE #(
      werks   = iv_werks
      allowed = rv_seen ) TO mt_allowed.

  ENDMETHOD.

  METHOD lines_for.

    DATA lv_now    TYPE zif_allocation=>ty_quantity.
    DATA lv_later  TYPE zif_allocation=>ty_quantity.
    DATA lv_covers TYPE zif_allocation=>ty_quantity.
    DATA lt_row    TYPE ty_line_tab.

    LOOP AT other_plants(
        iv_matnr = is_short-matnr
        iv_werks = iv_werks ) INTO DATA(lv_werks).

      IF may_see( lv_werks ) = abap_false.
        CONTINUE.
      ENDIF.

      CLEAR lv_now.
      CLEAR lv_later.

      LOOP AT mo_supply->read_supply(
          iv_matnr = is_short-matnr
          iv_werks = lv_werks ) INTO DATA(ls_supply).

        IF ls_supply-avail_date IS INITIAL.
          lv_now = lv_now + ls_supply-quantity.
        ELSE.
          lv_later = lv_later + ls_supply-quantity.
        ENDIF.

      ENDLOOP.

      " a plant with nothing to give away is not somewhere to look, and a row
      " saying so per plant of the company is a page nobody reads
      IF lv_now + lv_later <= 0.
        CONTINUE.
      ENDIF.

      lv_covers = lv_now + lv_later.
      IF lv_covers > is_short-quantity.
        lv_covers = is_short-quantity.
      ENDIF.

      APPEND format_row(
        iv_werks  = |{ lv_werks }|
        iv_now    = |{ lv_now }|
        iv_later  = |{ lv_later }|
        iv_covers = |{ lv_covers }| ) TO lt_row.

    ENDLOOP.

    " the heading comes after the rows are known, so that a material nobody
    " else has says nothing rather than heading an empty block
    IF lt_row IS INITIAL.
      RETURN.
    ENDIF.

    APPEND || TO rt_line.
    APPEND |{ is_short-matnr } is short { is_short-quantity }| TO rt_line.
    APPEND format_row(
      iv_werks  = `Plant`
      iv_now    = `On the shelf`
      iv_later  = `Coming`
      iv_covers = `Covers` ) TO rt_line.
    APPEND LINES OF lt_row TO rt_line.

  ENDMETHOD.

  METHOD format_row.

    rv_line = |{ iv_werks WIDTH = c_width_werks }|
      && |{ iv_now WIDTH = c_width_qty ALIGN = RIGHT }|
      && |{ iv_later WIDTH = c_width_qty ALIGN = RIGHT }|
      && |{ iv_covers WIDTH = c_width_qty ALIGN = RIGHT }|.

  ENDMETHOD.

ENDCLASS.
