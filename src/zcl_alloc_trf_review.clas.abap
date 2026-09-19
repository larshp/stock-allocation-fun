CLASS zcl_alloc_trf_review DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_line_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    "! <p class="shorttext synchronized">Review wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter ro_review | <p class="shorttext synchronized">Ready to use</p>
    CLASS-METHODS create_default
      RETURNING
        VALUE(ro_review) TYPE REF TO zcl_alloc_trf_review.

    "! <p class="shorttext synchronized">Wire up the review</p>
    "!
    "! @parameter io_transfer  | <p class="shorttext synchronized">Where proposals are written down</p>
    "! @parameter io_lapse     | <p class="shorttext synchronized">Knows which shortages have gone</p>
    "! @parameter io_authority | <p class="shorttext synchronized">Decides who may see a plant</p>
    METHODS constructor
      IMPORTING
        io_transfer  TYPE REF TO zcl_alloc_transfer
        io_lapse     TYPE REF TO zcl_alloc_lapse
        io_authority TYPE REF TO zif_allocation_authority.

    "! <p class="shorttext synchronized">What the transfers came to</p>
    "!
    "! The solution has proposed transfers since feature 160 and never looked
    "! back at whether any of it helped. This is the bookend: of the notes
    "! written in a period, how many were raised, how many somebody decided
    "! against, how many the shortage outlived and how many nobody has
    "! answered -- and of the raised ones, how many materials are no longer
    "! short.
    "!
    "! That last number is the one the page exists for. It is the closest
    "! thing there is to "is the proposing any good", and until feature 173
    "! recorded what was actually raised it could not be asked at all.
    "!
    "! It is a review, not a proof. A material that is no longer short may owe
    "! that to the transfer, to an order being cancelled or to a lorry from a
    "! supplier, and nothing in the recorded runs says which. What the page
    "! offers is the count worth arguing about, which is better than the
    "! nothing there was before.
    "!
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant that was short</p>
    "! @parameter iv_since       | <p class="shorttext synchronized">Earliest day to look back to, all if empty</p>
    "! @parameter rt_line        | <p class="shorttext synchronized">Lines to display</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">Plant may not be seen</p>
    METHODS run
      IMPORTING
        iv_werks       TYPE mard-werks
        iv_since       TYPE d OPTIONAL
      RETURNING
        VALUE(rt_line) TYPE ty_line_tab
      RAISING
        zcx_allocation.

  PRIVATE SECTION.

    CONSTANTS c_width_answer TYPE i VALUE 20.
    CONSTANTS c_width_count  TYPE i VALUE 8.
    CONSTANTS c_width_qty    TYPE i VALUE 16.

    "! Reading what was decided, deciding nothing.
    CONSTANTS c_activity_display TYPE activ_auth VALUE '03'.

    "! One answer's worth of proposals, added up.
    TYPES:
      BEGIN OF ty_tally,
        notes  TYPE i,
        asked  TYPE zif_allocation=>ty_quantity,
        raised TYPE zif_allocation=>ty_quantity,
      END OF ty_tally.

    DATA mo_transfer  TYPE REF TO zcl_alloc_transfer.
    DATA mo_lapse     TYPE REF TO zcl_alloc_lapse.
    DATA mo_authority TYPE REF TO zif_allocation_authority.

    METHODS tally_of
      IMPORTING
        it_proposal     TYPE zcl_alloc_transfer=>ty_proposal_tab
        iv_status       TYPE zstock_alloc_trf-status
      RETURNING
        VALUE(rs_tally) TYPE ty_tally.

    METHODS tally_line
      IMPORTING
        iv_answer      TYPE string
        is_tally       TYPE ty_tally
        iv_with_raised TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rv_line) TYPE string.

    METHODS format_row
      IMPORTING
        iv_answer      TYPE string
        iv_notes       TYPE string
        iv_asked       TYPE string
        iv_raised      TYPE string
      RETURNING
        VALUE(rv_line) TYPE string.

ENDCLASS.


CLASS zcl_alloc_trf_review IMPLEMENTATION.

  METHOD create_default.

    DATA(lo_transfer) = NEW zcl_alloc_transfer( ).

    ro_review = NEW zcl_alloc_trf_review(
      io_transfer  = lo_transfer
      io_lapse     = NEW zcl_alloc_lapse(
        io_transfer = lo_transfer
        io_store    = NEW zcl_allocation_store( ) )
      io_authority = NEW zcl_authority_alloc( c_activity_display ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_transfer  = io_transfer.
    mo_lapse     = io_lapse.
    mo_authority = io_authority.

  ENDMETHOD.

  METHOD run.

    DATA lt_served TYPE zcl_alloc_other_plants=>ty_matnr_tab.
    DATA lv_helped TYPE i.

    mo_authority->check_plant( iv_werks ).

    APPEND |Plant { iv_werks }, what the transfers came to| &&
           COND string( WHEN iv_since IS NOT INITIAL
                        THEN |, since { iv_since DATE = ISO }|
                        ELSE `` ) TO rt_line.

    DATA(lt_proposal) = mo_transfer->history_for(
      iv_werks = iv_werks
      iv_since = iv_since ).

    IF lt_proposal IS INITIAL.
      APPEND `Nobody has proposed a transfer for this plant` TO rt_line.
      RETURN.
    ENDIF.

    APPEND || TO rt_line.
    APPEND format_row(
      iv_answer = `Answer`
      iv_notes  = `Notes`
      iv_asked  = `Asked for`
      iv_raised = `Raised` ) TO rt_line.

    APPEND tally_line(
      iv_answer      = `Raised`
      is_tally       = tally_of( it_proposal = lt_proposal
                                 iv_status   = zcl_alloc_transfer=>c_status-done )
      iv_with_raised = abap_true ) TO rt_line.
    APPEND tally_line(
      iv_answer = `Decided against`
      is_tally  = tally_of( it_proposal = lt_proposal
                            iv_status   = zcl_alloc_transfer=>c_status-dropped ) ) TO rt_line.
    APPEND tally_line(
      iv_answer = `Shortage went away`
      is_tally  = tally_of( it_proposal = lt_proposal
                            iv_status   = zcl_alloc_transfer=>c_status-lapsed ) ) TO rt_line.
    APPEND tally_line(
      iv_answer = `Waiting for an answer`
      is_tally  = tally_of( it_proposal = lt_proposal
                            iv_status   = zcl_alloc_transfer=>c_status-open ) ) TO rt_line.

    " a material is counted once however many transfers were raised for it:
    " the question is whether the material is still short, and two notes about
    " one material are one answer to it
    LOOP AT lt_proposal INTO DATA(ls_proposal)
        WHERE status = zcl_alloc_transfer=>c_status-done.

      IF line_exists( lt_served[ table_line = ls_proposal-matnr ] ).
        CONTINUE.
      ENDIF.
      APPEND ls_proposal-matnr TO lt_served.

      IF mo_lapse->still_short( iv_werks = iv_werks
                                iv_matnr = ls_proposal-matnr ) = abap_false.
        lv_helped = lv_helped + 1.
      ENDIF.

    ENDLOOP.

    APPEND || TO rt_line.

    IF lt_served IS INITIAL.
      APPEND |{ lines( lt_proposal ) } proposal(s), none of them raised| TO rt_line.
      RETURN.
    ENDIF.

    APPEND |{ lines( lt_proposal ) } proposal(s); of the { lines( lt_served ) } | &&
           |material(s) a transfer was raised for, { lv_helped } | &&
           |no longer short| TO rt_line.

  ENDMETHOD.

  METHOD tally_of.

    LOOP AT it_proposal INTO DATA(ls_proposal)
        WHERE status = iv_status.
      rs_tally-notes  = rs_tally-notes + 1.
      rs_tally-asked  = rs_tally-asked + ls_proposal-quantity.
      rs_tally-raised = rs_tally-raised + ls_proposal-raised_qty.
    ENDLOOP.

  ENDMETHOD.

  METHOD tally_line.

    " an answer nothing happened under is a row of noughts, and a page of
    " noughts is a page the eye stops reading: the same choice features 121
    " and 166 made about the columns of the overview
    rv_line = format_row(
      iv_answer = iv_answer
      iv_notes  = COND string( WHEN is_tally-notes > 0
                               THEN |{ is_tally-notes }| )
      iv_asked  = COND string( WHEN is_tally-notes > 0
                               THEN |{ is_tally-asked }| )
      iv_raised = COND string( WHEN iv_with_raised = abap_true AND is_tally-notes > 0
                               THEN |{ is_tally-raised }| ) ).

  ENDMETHOD.

  METHOD format_row.

    rv_line = |{ iv_answer WIDTH = c_width_answer }|
      && |{ iv_notes WIDTH = c_width_count ALIGN = RIGHT }|
      && |{ iv_asked WIDTH = c_width_qty ALIGN = RIGHT }|
      && |{ iv_raised WIDTH = c_width_qty ALIGN = RIGHT }|.

  ENDMETHOD.

ENDCLASS.
