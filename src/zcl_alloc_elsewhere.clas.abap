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
    "! @parameter io_spare     | <p class="shorttext synchronized">What another plant could let go of</p>
    "! @parameter io_store     | <p class="shorttext synchronized">Where runs are recorded</p>
    "! @parameter io_authority | <p class="shorttext synchronized">Decides who may see a plant</p>
    "! @parameter io_transfer  | <p class="shorttext synchronized">Where proposals are written down</p>
    METHODS constructor
      IMPORTING
        io_spare     TYPE REF TO zcl_alloc_spare
        io_store     TYPE REF TO zif_allocation_store
        io_authority TYPE REF TO zif_allocation_authority
        io_transfer  TYPE REF TO zcl_alloc_transfer.

    "! <p class="shorttext synchronized">Which other plants have what this one is short of</p>
    "!
    "! The substitute list of feature 108 answers "would the customer take
    "! something else". This answers the other question a planner asks on a
    "! short morning: is the material sitting in another plant. It is the same
    "! material, so there is nothing to agree with the customer -- only a
    "! transfer to raise, which is somebody's decision and not this program's.
    "!
    "! Every plant's stock and demand are read the way that plant reads its
    "! own: its storage locations, its view of its own plan, its horizon. A
    "! number worked out any other way is stock the other plant would not have
    "! given away either.
    "!
    "! What a plant has is not what it can spare, which is what
    "! `ZCL_ALLOC_SPARE` works out. Both numbers are shown, because the shelf
    "! is where a conversation between two planners starts and the spare is
    "! where it ends.
    "!
    "! A row somebody has already made a note about says so, so that a page
    "! read after `ZSTOCK_ALLOC_TRF` has run does not read as a list of things
    "! nobody has thought about yet.
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

    CONSTANTS c_width_werks TYPE i VALUE 8.
    CONSTANTS c_width_qty   TYPE i VALUE 13.

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

    DATA mo_spare     TYPE REF TO zcl_alloc_spare.
    DATA mo_store     TYPE REF TO zif_allocation_store.
    DATA mo_authority TYPE REF TO zif_allocation_authority.
    DATA mo_transfer  TYPE REF TO zcl_alloc_transfer.

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
        iv_wanted      TYPE string
        iv_spare       TYPE string
        iv_covers      TYPE string
        iv_note        TYPE string
      RETURNING
        VALUE(rv_line) TYPE string.

ENDCLASS.


CLASS zcl_alloc_elsewhere IMPLEMENTATION.

  METHOD create_default.

    ro_list = NEW zcl_alloc_elsewhere(
      io_spare     = zcl_alloc_spare=>create_default( )
      io_store     = NEW zcl_allocation_store( )
      io_authority = NEW zcl_authority_alloc( c_activity_display )
      io_transfer  = NEW zcl_alloc_transfer( ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_spare     = io_spare.
    mo_store     = io_store.
    mo_authority = io_authority.
    mo_transfer  = io_transfer.

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

    DATA lv_covers TYPE zif_allocation=>ty_quantity.
    DATA lt_row    TYPE ty_line_tab.

    LOOP AT other_plants(
        iv_matnr = is_short-matnr
        iv_werks = iv_werks ) INTO DATA(lv_werks).

      IF may_see( lv_werks ) = abap_false.
        CONTINUE.
      ENDIF.

      DATA(ls_spare) = mo_spare->at_plant(
        iv_matnr = is_short-matnr
        iv_werks = lv_werks ).

      " a plant with nothing to give away is not somewhere to look, and a row
      " saying so per plant of the company is a page nobody reads
      IF ls_spare-on_hand + ls_spare-coming <= 0.
        CONTINUE.
      ENDIF.

      lv_covers = ls_spare-spare.
      IF lv_covers > is_short-quantity.
        lv_covers = is_short-quantity.
      ENDIF.

      APPEND format_row(
        iv_werks  = |{ lv_werks }|
        iv_now    = |{ ls_spare-on_hand }|
        iv_later  = |{ ls_spare-coming }|
        iv_wanted = |{ ls_spare-wanted }|
        iv_spare  = |{ ls_spare-spare }|
        iv_covers = |{ lv_covers }|
        iv_note   = COND string(
          WHEN mo_transfer->is_open( iv_matnr      = is_short-matnr
                                     iv_to_werks   = iv_werks
                                     iv_from_werks = lv_werks ) = abap_true
          THEN `already proposed`
          ELSE `` ) ) TO lt_row.

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
      iv_wanted = `Wanted there`
      iv_spare  = `Spare`
      iv_covers = `Covers`
      iv_note   = `` ) TO rt_line.
    APPEND LINES OF lt_row TO rt_line.

  ENDMETHOD.

  METHOD format_row.

    rv_line = |{ iv_werks WIDTH = c_width_werks }|
      && |{ iv_now WIDTH = c_width_qty ALIGN = RIGHT }|
      && |{ iv_later WIDTH = c_width_qty ALIGN = RIGHT }|
      && |{ iv_wanted WIDTH = c_width_qty ALIGN = RIGHT }|
      && |{ iv_spare WIDTH = c_width_qty ALIGN = RIGHT }|
      && |{ iv_covers WIDTH = c_width_qty ALIGN = RIGHT }|
      && |  { iv_note }|.

  ENDMETHOD.

ENDCLASS.
