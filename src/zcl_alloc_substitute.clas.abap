CLASS zcl_alloc_substitute DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_line_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    "! A substitute with no factor on it is one of ours for one of theirs.
    CONSTANTS c_one_for_one TYPE zif_allocation=>ty_quantity VALUE 1.

    "! <p class="shorttext synchronized">List wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter iv_werks | <p class="shorttext synchronized">Plant</p>
    "! @parameter ro_list  | <p class="shorttext synchronized">Ready to use list</p>
    CLASS-METHODS create_for_plant
      IMPORTING
        iv_werks       TYPE mard-werks
      RETURNING
        VALUE(ro_list) TYPE REF TO zcl_alloc_substitute.

    "! <p class="shorttext synchronized">Wire up the list</p>
    "!
    "! @parameter io_supply    | <p class="shorttext synchronized">What a material has to give away</p>
    "! @parameter io_store     | <p class="shorttext synchronized">Where runs are recorded</p>
    "! @parameter io_authority | <p class="shorttext synchronized">Decides who may see a plant</p>
    METHODS constructor
      IMPORTING
        io_supply    TYPE REF TO zif_supply_reader
        io_store     TYPE REF TO zif_allocation_store
        io_authority TYPE REF TO zif_allocation_authority.

    "! <p class="shorttext synchronized">What could be covered with something else</p>
    "!
    "! The allocation deals in one material at a time, and it is right to: a
    "! reservation is against a material, and stock of another one is not the
    "! stock this line was sold. What a planner does on a short morning is
    "! nevertheless to ask whether the customer would take the other size, and
    "! that question is answered today by looking up half a dozen materials in
    "! MMBE one at a time.
    "!
    "! This is that lookup, done once: every material short in the last run,
    "! with the materials the plant has said could stand in for it and what
    "! they have. It allocates nothing and reserves nothing -- taking the
    "! decision is a person's job, and carrying it out is a change to the
    "! order, not to the allocation.
    "!
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
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

    "! One substitute. Declared explicitly rather than inferred with
    "! INTO TABLE @DATA(), see ANOMALIES.md.
    TYPES:
      BEGIN OF ty_substitute,
        substitute TYPE zstock_alloc_sub-substitute,
        factor     TYPE zif_allocation=>ty_quantity,
        note       TYPE zstock_alloc_sub-note,
      END OF ty_substitute.
    TYPES ty_substitute_tab TYPE STANDARD TABLE OF ty_substitute WITH EMPTY KEY.

    "! <p class="shorttext synchronized">What the plant says can stand in for a material</p>
    "!
    "! Public because the promise of feature 145 asks the same question of the
    "! same table: what a plant has said can stand in for what is one
    "! arrangement, and two readers of it would drift.
    "!
    "! @parameter iv_werks     | <p class="shorttext synchronized">Plant</p>
    "! @parameter iv_matnr     | <p class="shorttext synchronized">Material that is short</p>
    "! @parameter rt_substitute | <p class="shorttext synchronized">What could stand in for it</p>
    CLASS-METHODS substitutes_for
      IMPORTING
        iv_werks             TYPE mard-werks
        iv_matnr             TYPE mard-matnr
      RETURNING
        VALUE(rt_substitute) TYPE ty_substitute_tab.

  PRIVATE SECTION.

    CONSTANTS c_width_matnr TYPE i VALUE 20.
    CONSTANTS c_width_qty   TYPE i VALUE 14.

    "! Reading what is short and what else there is, changing neither.
    CONSTANTS c_activity_display TYPE activ_auth VALUE '03'.

    "! One material that is short, and by how much.
    TYPES:
      BEGIN OF ty_short,
        matnr    TYPE mard-matnr,
        quantity TYPE zif_allocation=>ty_quantity,
      END OF ty_short.
    TYPES ty_short_tab TYPE STANDARD TABLE OF ty_short WITH EMPTY KEY.

    DATA mo_supply    TYPE REF TO zif_supply_reader.
    DATA mo_store     TYPE REF TO zif_allocation_store.
    DATA mo_authority TYPE REF TO zif_allocation_authority.

    METHODS short_materials
      IMPORTING
        iv_werks        TYPE mard-werks
        iv_matnr        TYPE mard-matnr
      RETURNING
        VALUE(rt_short) TYPE ty_short_tab.

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
        iv_substitute  TYPE string
        iv_now         TYPE string
        iv_later       TYPE string
        iv_covers      TYPE string
        iv_note        TYPE string
      RETURNING
        VALUE(rv_line) TYPE string.

ENDCLASS.


CLASS zcl_alloc_substitute IMPLEMENTATION.

  METHOD create_for_plant.

    DATA(ls_settings) = CAST zif_alloc_config( NEW zcl_alloc_config( ) )->for_plant( iv_werks ).

    " what a substitute has to give away is read exactly as the run reads what
    " anything has: the same locations, the same deductions, the same view of
    " the plan. A planner offered stock the run would not have allocated is
    " being offered stock that is not there.
    ro_list = NEW zcl_alloc_substitute(
      io_supply    = zcl_allocation_service=>create_default_supply(
        iv_lgort   = ls_settings-lgort
        iv_planned = ls_settings-planned )
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

    APPEND |Plant { iv_werks }, what could stand in for what is short| TO rt_line.

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
    " material: which line is short matters to the customer, and what could
    " stand in is a question about the material
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

  METHOD substitutes_for.

    SELECT substitute,
           factor,
           note
      FROM zstock_alloc_sub
      WHERE werks = @iv_werks
        AND matnr = @iv_matnr
      ORDER BY substitute
      INTO TABLE @rt_substitute.
    IF sy-subrc <> 0.
      CLEAR rt_substitute.
    ENDIF.

  ENDMETHOD.

  METHOD lines_for.

    DATA lv_now    TYPE zif_allocation=>ty_quantity.
    DATA lv_later  TYPE zif_allocation=>ty_quantity.
    DATA lv_covers TYPE zif_allocation=>ty_quantity.

    DATA(lt_substitute) = substitutes_for(
      iv_werks = iv_werks
      iv_matnr = is_short-matnr ).

    IF lt_substitute IS INITIAL.
      RETURN.
    ENDIF.

    APPEND || TO rt_line.
    APPEND |{ is_short-matnr } is short { is_short-quantity }| TO rt_line.
    APPEND format_row(
      iv_substitute = `Could take`
      iv_now        = `On the shelf`
      iv_later      = `Coming`
      iv_covers     = `Covers`
      iv_note       = `Note` ) TO rt_line.

    LOOP AT lt_substitute INTO DATA(ls_substitute).

      CLEAR lv_now.
      CLEAR lv_later.

      LOOP AT mo_supply->read_supply(
          iv_matnr = ls_substitute-substitute
          iv_werks = iv_werks ) INTO DATA(ls_supply).

        IF ls_supply-avail_date IS INITIAL.
          lv_now = lv_now + ls_supply-quantity.
        ELSE.
          lv_later = lv_later + ls_supply-quantity.
        ENDIF.

      ENDLOOP.

      " how much of the short material the substitute would cover, which is
      " not the same number when two of one make one of the other
      DATA(lv_factor) = ls_substitute-factor.
      IF lv_factor <= 0.
        lv_factor = c_one_for_one.
      ENDIF.

      lv_covers = ( lv_now + lv_later ) / lv_factor.
      IF lv_covers > is_short-quantity.
        lv_covers = is_short-quantity.
      ENDIF.

      APPEND format_row(
        iv_substitute = |{ ls_substitute-substitute }|
        iv_now        = |{ lv_now }|
        iv_later      = |{ lv_later }|
        iv_covers     = |{ lv_covers }|
        iv_note       = |{ ls_substitute-note }| ) TO rt_line.

    ENDLOOP.

  ENDMETHOD.

  METHOD format_row.

    rv_line = |{ iv_substitute WIDTH = c_width_matnr }|
           && |{ iv_now WIDTH = c_width_qty ALIGN = RIGHT }|
           && |{ iv_later WIDTH = c_width_qty ALIGN = RIGHT }|
           && |{ iv_covers WIDTH = c_width_qty ALIGN = RIGHT }|
           && |  { iv_note }|.

  ENDMETHOD.

ENDCLASS.
