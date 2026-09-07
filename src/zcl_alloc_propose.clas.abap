CLASS zcl_alloc_propose DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_line_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    "! <p class="shorttext synchronized">Proposing wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter ro_propose | <p class="shorttext synchronized">Ready to use</p>
    CLASS-METHODS create_default
      RETURNING
        VALUE(ro_propose) TYPE REF TO zcl_alloc_propose.

    "! <p class="shorttext synchronized">Wire up the proposing</p>
    "!
    "! @parameter io_supply    | <p class="shorttext synchronized">What a material has to give away, per plant</p>
    "! @parameter io_demand    | <p class="shorttext synchronized">What is waiting for it there, per plant</p>
    "! @parameter io_store     | <p class="shorttext synchronized">Where runs are recorded</p>
    "! @parameter io_authority | <p class="shorttext synchronized">Decides who may allocate in a plant</p>
    "! @parameter io_transfer  | <p class="shorttext synchronized">Where proposals are written down</p>
    "! @parameter io_lapse     | <p class="shorttext synchronized">Closes the ones whose shortage has gone</p>
    "! @parameter io_commit    | <p class="shorttext synchronized">What makes a proposal durable</p>
    METHODS constructor
      IMPORTING
        io_supply    TYPE REF TO zif_supply_reader
        io_demand    TYPE REF TO zif_demand_reader
        io_store     TYPE REF TO zif_allocation_store
        io_authority TYPE REF TO zif_allocation_authority
        io_transfer  TYPE REF TO zcl_alloc_transfer
        io_lapse     TYPE REF TO zcl_alloc_lapse
        io_commit    TYPE REF TO zif_unit_of_work.

    "! <p class="shorttext synchronized">Write down the transfers that would help</p>
    "!
    "! Feature 158 works the numbers out and shows them. What it cannot do is
    "! be acted on: a page recalculated every morning shows a proposal
    "! somebody has already raised as though it were new, and one they decided
    "! against as though it were a fresh idea. This turns the same numbers into
    "! a worklist with an answer against each line.
    "!
    "! A transfer already waiting for an answer is not proposed again, so this
    "! can be scheduled nightly and only says something when something has
    "! changed.
    "!
    "! The proposals whose shortage has gone are closed first, and they have
    "! to be: an open note blocks a new one for the same pair of plants, so a
    "! stale one would hide a shortage that came back with a different
    "! quantity and a different day. Leaving that to whoever schedules the
    "! programs in the right order is leaving it to chance.
    "!
    "! Nothing is posted. A transfer between plants is a document somebody
    "! raises; this is the note that says it is worth raising, and who said so.
    "!
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant that is short</p>
    "! @parameter iv_matnr       | <p class="shorttext synchronized">Material, every short one if empty</p>
    "! @parameter iv_test        | <p class="shorttext synchronized">Work it out and write nothing down</p>
    "! @parameter rt_line        | <p class="shorttext synchronized">Lines to display</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">Plant may not be allocated in, or it failed</p>
    METHODS run
      IMPORTING
        iv_werks       TYPE mard-werks
        iv_matnr       TYPE mard-matnr OPTIONAL
        iv_test        TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab
      RAISING
        zcx_allocation.

  PRIVATE SECTION.

    CONSTANTS c_width_matnr TYPE i VALUE 20.
    CONSTANTS c_width_werks TYPE i VALUE 8.
    CONSTANTS c_width_qty   TYPE i VALUE 14.

    "! Writing a proposal down is not allocating, but it is not reading
    "! either: somebody's morning changes because of it, and the plant that is
    "! short is the plant it is about.
    CONSTANTS c_activity_change TYPE activ_auth VALUE '02'.

    "! What the note on a proposal says when this made it rather than a person.
    CONSTANTS c_note TYPE zstock_alloc_trf-note VALUE 'proposed by the nightly check'.

    "! One material that is short, by how much, and the soonest day any of it
    "! was wanted: what makes one proposal more urgent than another.
    TYPES:
      BEGIN OF ty_short,
        matnr     TYPE mard-matnr,
        quantity  TYPE zif_allocation=>ty_quantity,
        needed_by TYPE d,
      END OF ty_short.
    TYPES ty_short_tab TYPE STANDARD TABLE OF ty_short WITH EMPTY KEY.

    TYPES ty_werks_tab TYPE STANDARD TABLE OF mard-werks WITH EMPTY KEY.

    DATA mo_supply    TYPE REF TO zif_supply_reader.
    DATA mo_demand    TYPE REF TO zif_demand_reader.
    DATA mo_store     TYPE REF TO zif_allocation_store.
    DATA mo_authority TYPE REF TO zif_allocation_authority.
    DATA mo_transfer  TYPE REF TO zcl_alloc_transfer.
    DATA mo_lapse     TYPE REF TO zcl_alloc_lapse.
    DATA mo_commit    TYPE REF TO zif_unit_of_work.

    "! The plants already asked about, and whether the user may see them.
    TYPES:
      BEGIN OF ty_allowed,
        werks   TYPE mard-werks,
        allowed TYPE abap_bool,
      END OF ty_allowed.
    TYPES ty_allowed_tab TYPE STANDARD TABLE OF ty_allowed WITH EMPTY KEY.

    DATA mt_allowed TYPE ty_allowed_tab.

    "! How many proposals this run has written down, so that the footer and
    "! the commit agree with what the lines say.
    DATA mv_written TYPE i.

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

    METHODS spare_at
      IMPORTING
        iv_matnr           TYPE mard-matnr
        iv_werks           TYPE mard-werks
      RETURNING
        VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity
      RAISING
        zcx_allocation.

    METHODS lines_for
      IMPORTING
        is_short       TYPE ty_short
        iv_werks       TYPE mard-werks
        iv_test        TYPE abap_bool
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab
      RAISING
        zcx_allocation.

    METHODS format_row
      IMPORTING
        iv_matnr       TYPE string
        iv_from        TYPE string
        iv_quantity    TYPE string
        iv_what        TYPE string
      RETURNING
        VALUE(rv_line) TYPE string.

ENDCLASS.


CLASS zcl_alloc_propose IMPLEMENTATION.

  METHOD create_default.

    DATA(lo_transfer) = NEW zcl_alloc_transfer( ).
    DATA(lo_store)    = NEW zcl_allocation_store( ).

    ro_propose = NEW zcl_alloc_propose(
      io_supply    = NEW zcl_supply_per_plant( )
      io_demand    = NEW zcl_demand_per_plant( )
      io_store     = lo_store
      io_authority = NEW zcl_authority_alloc( c_activity_change )
      io_transfer  = lo_transfer
      io_lapse     = NEW zcl_alloc_lapse(
        io_transfer = lo_transfer
        io_store    = lo_store )
      io_commit    = NEW zcl_unit_of_work( ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_supply    = io_supply.
    mo_demand    = io_demand.
    mo_store     = io_store.
    mo_authority = io_authority.
    mo_transfer  = io_transfer.
    mo_lapse     = io_lapse.
    mo_commit    = io_commit.

  ENDMETHOD.

  METHOD run.

    CLEAR mv_written.

    mo_authority->check_plant( iv_werks ).

    APPEND |Plant { iv_werks }, transfers worth raising| &&
           COND string( WHEN iv_test = abap_true
                        THEN ` (test run, nothing written down)`
                        ELSE `` ) TO rt_line.

    " the stale notes go first: one of them would otherwise block a new note
    " for the same pair of plants, and a shortage that came back with a
    " different quantity would go unproposed
    DATA(ls_lapsed) = mo_lapse->run(
      iv_werks = iv_werks
      iv_test  = iv_test ).

    IF ls_lapsed-closed > 0.
      APPEND || TO rt_line.
      APPEND |{ ls_lapsed-closed } proposal(s) | &&
             COND string( WHEN iv_test = abap_true
                          THEN `would be closed, `
                          ELSE `closed, ` ) &&
             `the shortage behind them has gone` TO rt_line.
      APPEND LINES OF ls_lapsed-line TO rt_line.
    ENDIF.

    DATA(lt_short) = short_materials(
      iv_werks = iv_werks
      iv_matnr = iv_matnr ).

    IF lt_short IS INITIAL.
      APPEND || TO rt_line.
      APPEND `Nothing was short in the last run` TO rt_line.
      IF ls_lapsed-closed > 0 AND iv_test = abap_false.
        mo_commit->commit( ).
      ENDIF.
      RETURN.
    ENDIF.

    LOOP AT lt_short INTO DATA(ls_short).
      APPEND LINES OF lines_for(
        is_short = ls_short
        iv_werks = iv_werks
        iv_test  = iv_test ) TO rt_line.
    ENDLOOP.

    " one commit for the run rather than one per proposal: a proposal is a
    " note, nothing downstream reads it while this is running, and a job that
    " dies half way leaves the notes it had already made rather than none
    IF mv_written > 0 OR ls_lapsed-closed > 0.
      mo_commit->commit( ).
    ENDIF.

    APPEND || TO rt_line.
    IF mv_written = 0.
      APPEND `Nothing new to propose` TO rt_line.
      RETURN.
    ENDIF.

    APPEND |{ mv_written } proposal(s) | &&
           COND string( WHEN iv_test = abap_true
                        THEN `would be written down`
                        ELSE `written down` ) TO rt_line.

  ENDMETHOD.

  METHOD short_materials.

    DATA ls_short TYPE ty_short.

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

        " the soonest of the material's short lines is the day the transfer
        " has to be there by. A line with no date is wanted now, which an
        " initial date already sorts as, so it wins whatever else there is.
        IF ls_recorded-req_date IS INITIAL
            OR ls_recorded-req_date < ls_short-needed_by.
          ls_short-needed_by = ls_recorded-req_date.
        ENDIF.

        MODIFY rt_short FROM ls_short
          TRANSPORTING quantity needed_by
          WHERE matnr = ls_short-matnr.
        CONTINUE.
      ENDIF.

      ls_short-matnr     = ls_recorded-matnr.
      ls_short-quantity  = ls_recorded-shortfall.
      ls_short-needed_by = ls_recorded-req_date.
      APPEND ls_short TO rt_short.

    ENDLOOP.

  ENDMETHOD.

  METHOD other_plants.

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

    " a plant the user may not see is left out rather than refused, for the
    " reason ZCL_ALLOC_ELSEWHERE gives. Here it also means a user cannot make
    " a note about a plant they are not allowed to know about.
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

  METHOD spare_at.

    DATA lv_have  TYPE zif_allocation=>ty_quantity.
    DATA lv_owed  TYPE zif_allocation=>ty_quantity.

    LOOP AT mo_supply->read_supply(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ) INTO DATA(ls_supply).
      lv_have = lv_have + ls_supply-quantity.
    ENDLOOP.

    LOOP AT mo_demand->read_open_demand(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ) INTO DATA(ls_demand).
      IF ls_demand-quantity > 0.
        lv_owed = lv_owed + ls_demand-quantity.
      ENDIF.
    ENDLOOP.

    " the same arithmetic as the page of feature 158, and deliberately not a
    " second opinion about it: a proposal that offered a quantity the page
    " does not show would be a proposal nobody could check
    rv_quantity = lv_have - lv_owed.
    IF rv_quantity < 0.
      rv_quantity = 0.
    ENDIF.

  ENDMETHOD.

  METHOD lines_for.

    DATA lv_quantity TYPE zif_allocation=>ty_quantity.
    DATA lt_row      TYPE ty_line_tab.

    LOOP AT other_plants(
        iv_matnr = is_short-matnr
        iv_werks = iv_werks ) INTO DATA(lv_werks).

      IF may_see( lv_werks ) = abap_false.
        CONTINUE.
      ENDIF.

      DATA(lv_spare) = spare_at(
        iv_matnr = is_short-matnr
        iv_werks = lv_werks ).

      IF lv_spare <= 0.
        CONTINUE.
      ENDIF.

      lv_quantity = lv_spare.
      IF lv_quantity > is_short-quantity.
        lv_quantity = is_short-quantity.
      ENDIF.

      " a transfer already waiting for an answer is said out loud and not
      " proposed again: a nightly job that made the same note every night
      " would be a worklist nobody could work through
      IF mo_transfer->is_open(
          iv_matnr      = is_short-matnr
          iv_to_werks   = iv_werks
          iv_from_werks = lv_werks ) = abap_true.
        APPEND format_row(
          iv_matnr    = |{ is_short-matnr }|
          iv_from     = |{ lv_werks }|
          iv_quantity = |{ lv_quantity }|
          iv_what     = `already proposed` ) TO lt_row.
        CONTINUE.
      ENDIF.

      IF iv_test = abap_false.
        mo_transfer->propose(
          iv_matnr      = is_short-matnr
          iv_to_werks   = iv_werks
          iv_from_werks = lv_werks
          iv_quantity   = lv_quantity
          iv_needed_by  = is_short-needed_by
          iv_note       = c_note ).
      ENDIF.

      mv_written = mv_written + 1.

      APPEND format_row(
        iv_matnr    = |{ is_short-matnr }|
        iv_from     = |{ lv_werks }|
        iv_quantity = |{ lv_quantity }|
        iv_what     = COND string( WHEN iv_test = abap_true
                                   THEN `would be proposed`
                                   ELSE `proposed` ) ) TO lt_row.

    ENDLOOP.

    IF lt_row IS INITIAL.
      RETURN.
    ENDIF.

    APPEND || TO rt_line.
    APPEND |{ is_short-matnr } is short { is_short-quantity }| TO rt_line.
    APPEND format_row(
      iv_matnr    = `Material`
      iv_from     = `From`
      iv_quantity = `Quantity`
      iv_what     = `` ) TO rt_line.
    APPEND LINES OF lt_row TO rt_line.

  ENDMETHOD.

  METHOD format_row.

    rv_line = |{ iv_matnr WIDTH = c_width_matnr }|
      && |{ iv_from WIDTH = c_width_werks }|
      && |{ iv_quantity WIDTH = c_width_qty ALIGN = RIGHT }|
      && |  { iv_what }|.

  ENDMETHOD.

ENDCLASS.
