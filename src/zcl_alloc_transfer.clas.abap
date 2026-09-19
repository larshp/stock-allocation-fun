CLASS zcl_alloc_transfer DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    "! One proposed transfer, as anybody reading the worklist sees it.
    TYPES:
      BEGIN OF ty_proposal,
        proposal   TYPE zstock_alloc_trf-proposal,
        matnr      TYPE zstock_alloc_trf-matnr,
        to_werks   TYPE zstock_alloc_trf-to_werks,
        from_werks TYPE zstock_alloc_trf-from_werks,
        quantity   TYPE zif_allocation=>ty_quantity,
        raised_qty TYPE zif_allocation=>ty_quantity,
        needed_by  TYPE zstock_alloc_trf-needed_by,
        status     TYPE zstock_alloc_trf-status,
        note       TYPE zstock_alloc_trf-note,
        created_by TYPE zstock_alloc_trf-created_by,
        created_at TYPE zstock_alloc_trf-created_at,
      END OF ty_proposal.
    TYPES ty_proposal_tab TYPE STANDARD TABLE OF ty_proposal WITH EMPTY KEY.

    "! What has become of a proposal. A proposal is a question put to a
    "! person, so it has three answers: not yet, yes and no. Nothing here
    "! posts a transfer -- moving stock between plants is a document somebody
    "! raises, and this is the note that says it is worth raising.
    "!
    "! LAPSED is not a fourth answer but the question going away: the shortage
    "! it was written against is gone. It is kept apart from DROPPED because
    "! "we decided against this" and "this stopped being a question" are
    "! different things to find in the table a year later, and the second one
    "! says nothing about what anybody thought of the idea.
    CONSTANTS:
      BEGIN OF c_status,
        open    TYPE zstock_alloc_trf-status VALUE 'O',
        done    TYPE zstock_alloc_trf-status VALUE 'D',
        dropped TYPE zstock_alloc_trf-status VALUE 'X',
        lapsed  TYPE zstock_alloc_trf-status VALUE 'L',
      END OF c_status.

    "! <p class="shorttext synchronized">Wire up the worklist</p>
    "!
    "! @parameter io_run_id | <p class="shorttext synchronized">How proposals are numbered</p>
    METHODS constructor
      IMPORTING
        io_run_id TYPE REF TO zif_run_id_supplier OPTIONAL.

    "! <p class="shorttext synchronized">Write down that a transfer would help</p>
    "!
    "! Feature 158 works out that another plant can spare what this one is
    "! short of. What was missing is anywhere to put that: the page was worked
    "! out again every morning, so a proposal somebody had already dealt with
    "! came back looking new, and one they had decided against came back
    "! looking like a fresh idea.
    "!
    "! Nothing is committed here. The caller decides what one unit of work is,
    "! as it does everywhere else in this solution.
    "!
    "! @parameter iv_matnr       | <p class="shorttext synchronized">Material</p>
    "! @parameter iv_to_werks    | <p class="shorttext synchronized">Plant that is short</p>
    "! @parameter iv_from_werks  | <p class="shorttext synchronized">Plant that can spare it</p>
    "! @parameter iv_quantity    | <p class="shorttext synchronized">Quantity in the base unit</p>
    "! @parameter iv_needed_by   | <p class="shorttext synchronized">Day the shortage is for, empty for now</p>
    "! @parameter iv_note        | <p class="shorttext synchronized">What somebody should know</p>
    "! @parameter rv_proposal    | <p class="shorttext synchronized">The proposal written down</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">It could not be written down</p>
    METHODS propose
      IMPORTING
        iv_matnr           TYPE mard-matnr
        iv_to_werks        TYPE mard-werks
        iv_from_werks      TYPE mard-werks
        iv_quantity        TYPE zif_allocation=>ty_quantity
        iv_needed_by       TYPE zstock_alloc_trf-needed_by OPTIONAL
        iv_note            TYPE zstock_alloc_trf-note OPTIONAL
      RETURNING
        VALUE(rv_proposal) TYPE zstock_alloc_trf-proposal
      RAISING
        zcx_allocation.

    "! <p class="shorttext synchronized">Proposals nobody has answered yet</p>
    "!
    "! For the plant that is short, because that is who is waiting for the
    "! answer. Soonest wanted first, which is what makes one shortage more
    "! urgent than another; a proposal with no day is wanted now and sorts
    "! first, which is also what an initial date does. Within a day the
    "! newest is first, because a proposal made this morning is the one
    "! somebody is talking about.
    "!
    "! @parameter iv_werks    | <p class="shorttext synchronized">Plant that is short</p>
    "! @parameter iv_matnr    | <p class="shorttext synchronized">Material, every one if empty</p>
    "! @parameter rt_proposal | <p class="shorttext synchronized">Open proposals</p>
    METHODS open_for
      IMPORTING
        iv_werks           TYPE mard-werks
        iv_matnr           TYPE mard-matnr OPTIONAL
      RETURNING
        VALUE(rt_proposal) TYPE ty_proposal_tab.

    "! <p class="shorttext synchronized">Every proposal of a plant, answered or not</p>
    "!
    "! `OPEN_FOR` is the worklist: what somebody still has to decide. This is
    "! the record: what was decided, when, and what came of it. Nothing acts
    "! on it -- it is there to be looked back at, which is why `ZSTOCK_ALLOC_TRF`
    "! is not reorganised.
    "!
    "! Newest first, because a review starts at the most recent thing that
    "! happened and works backwards.
    "!
    "! @parameter iv_werks    | <p class="shorttext synchronized">Plant that was short</p>
    "! @parameter iv_since    | <p class="shorttext synchronized">Earliest day to look back to, all if empty</p>
    "! @parameter rt_proposal | <p class="shorttext synchronized">Proposals of every status</p>
    METHODS history_for
      IMPORTING
        iv_werks           TYPE mard-werks
        iv_since           TYPE d OPTIONAL
      RETURNING
        VALUE(rt_proposal) TYPE ty_proposal_tab.

    "! <p class="shorttext synchronized">Answer a proposal</p>
    "!
    "! Yes or no, and who said so. A proposal that has already been answered
    "! is not answered again: the first answer is the one that was acted on,
    "! and overwriting it would lose who decided what and when.
    "!
    "! A transfer raised for less than the note asked for is the commonest
    "! yes there is -- feature 168 exists to tell somebody the stock has
    "! shrunk since the note was written -- so the quantity that was actually
    "! raised is recorded. Left out, it is the quantity the note asked for.
    "!
    "! A quantity is meaningless on a no, and a no is what a raise of nothing
    "! is, so both are refused rather than written down as something they are
    "! not. More than was proposed is allowed: whoever spoke to the other
    "! plant knows what they agreed.
    "!
    "! @parameter iv_proposal    | <p class="shorttext synchronized">The proposal</p>
    "! @parameter iv_status      | <p class="shorttext synchronized">D done, X dropped</p>
    "! @parameter iv_quantity    | <p class="shorttext synchronized">Quantity raised, the proposed one if empty</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">No such open proposal, or a senseless answer</p>
    METHODS answer
      IMPORTING
        iv_proposal TYPE zstock_alloc_trf-proposal
        iv_status   TYPE zstock_alloc_trf-status
        iv_quantity TYPE zif_allocation=>ty_quantity OPTIONAL
      RAISING
        zcx_allocation.

    "! <p class="shorttext synchronized">Close a proposal whose shortage has gone</p>
    "!
    "! Not an answer: nobody decided anything, the question stopped being one.
    "! Only an open proposal lapses, so a decision somebody has already made
    "! is never overwritten by a housekeeping run.
    "!
    "! @parameter iv_proposal    | <p class="shorttext synchronized">The proposal</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">No such open proposal</p>
    METHODS lapse
      IMPORTING
        iv_proposal TYPE zstock_alloc_trf-proposal
      RAISING
        zcx_allocation.

    "! <p class="shorttext synchronized">Whether this transfer is already on somebody's list</p>
    "!
    "! What stops the same proposal being written down every morning. It asks
    "! about the pair of plants rather than about the material alone, because
    "! two plants can both be able to help and the planner may want both.
    "!
    "! @parameter iv_matnr      | <p class="shorttext synchronized">Material</p>
    "! @parameter iv_to_werks   | <p class="shorttext synchronized">Plant that is short</p>
    "! @parameter iv_from_werks | <p class="shorttext synchronized">Plant that can spare it</p>
    "! @parameter rv_open       | <p class="shorttext synchronized">True if one is waiting for an answer</p>
    METHODS is_open
      IMPORTING
        iv_matnr       TYPE mard-matnr
        iv_to_werks    TYPE mard-werks
        iv_from_werks  TYPE mard-werks
      RETURNING
        VALUE(rv_open) TYPE abap_bool.

    "! <p class="shorttext synchronized">What a plant has already been asked to send</p>
    "!
    "! The other side of `OPEN_FOR`, which answers for the plant that is
    "! short. This answers for the plant being asked: everything anybody has
    "! an open note against it for, added up.
    "!
    "! Stock two plants have both been told to take is stock one of them is
    "! not going to get, and the second one finds that out by raising a
    "! transfer that cannot be filled. Whoever works out what a plant can
    "! spare has to take this off first.
    "!
    "! @parameter iv_matnr      | <p class="shorttext synchronized">Material</p>
    "! @parameter iv_from_werks | <p class="shorttext synchronized">Plant being asked</p>
    "! @parameter rv_quantity   | <p class="shorttext synchronized">Quantity on open notes against it</p>
    METHODS promised_by
      IMPORTING
        iv_matnr           TYPE mard-matnr
        iv_from_werks      TYPE mard-werks
      RETURNING
        VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity.

  PRIVATE SECTION.

    "! One open note's quantity, and nothing else of it.
    TYPES:
      BEGIN OF ty_note,
        quantity TYPE zstock_alloc_trf-quantity,
      END OF ty_note.

    DATA mo_run_id TYPE REF TO zif_run_id_supplier.

    METHODS close
      IMPORTING
        iv_proposal TYPE zstock_alloc_trf-proposal
        iv_status   TYPE zstock_alloc_trf-status
        iv_quantity TYPE zif_allocation=>ty_quantity DEFAULT 0
      RAISING
        zcx_allocation.

ENDCLASS.


CLASS zcl_alloc_transfer IMPLEMENTATION.

  METHOD constructor.

    mo_run_id = io_run_id.
    IF mo_run_id IS NOT BOUND.
      mo_run_id = NEW zcl_run_id_uuid( ).
    ENDIF.

  ENDMETHOD.

  METHOD propose.

    " typed explicitly, see ANOMALIES.md
    DATA lv_timestamp TYPE zstock_alloc_trf-created_at.

    GET TIME STAMP FIELD lv_timestamp.

    rv_proposal = mo_run_id->next( ).

    INSERT zstock_alloc_trf FROM @( VALUE #(
      mandt      = sy-mandt
      proposal   = rv_proposal
      matnr      = iv_matnr
      to_werks   = iv_to_werks
      from_werks = iv_from_werks
      quantity   = iv_quantity
      needed_by  = iv_needed_by
      status     = c_status-open
      note       = iv_note
      created_by = sy-uname
      created_at = lv_timestamp ) ).
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>save_failed
        mv_message = |{ iv_matnr } { iv_to_werks }| ).
    ENDIF.

  ENDMETHOD.

  METHOD open_for.

    DATA lt_matnr TYPE RANGE OF zstock_alloc_trf-matnr.

    " an empty material is every material, which is what every reader in this
    " solution means by it
    IF iv_matnr IS NOT INITIAL.
      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = iv_matnr ) TO lt_matnr.
    ENDIF.

    SELECT proposal,
           matnr,
           to_werks,
           from_werks,
           quantity,
           raised_qty,
           needed_by,
           status,
           note,
           created_by,
           created_at
      FROM zstock_alloc_trf
      WHERE to_werks = @iv_werks
        AND matnr IN @lt_matnr
        AND status = @c_status-open
      ORDER BY needed_by, created_at DESCENDING, proposal
      INTO TABLE @rt_proposal.
    IF sy-subrc <> 0.
      CLEAR rt_proposal.
    ENDIF.

  ENDMETHOD.

  METHOD history_for.

    DATA lv_from TYPE zstock_alloc_trf-created_at.

    " a day given is where the reading starts; none given is everything the
    " table has, which is what makes this a record rather than a report
    IF iv_since IS NOT INITIAL.
      lv_from = zcl_alloc_clock=>stamp_of( iv_since ).
    ENDIF.

    SELECT proposal,
           matnr,
           to_werks,
           from_werks,
           quantity,
           raised_qty,
           needed_by,
           status,
           note,
           created_by,
           created_at
      FROM zstock_alloc_trf
      WHERE to_werks = @iv_werks
        AND created_at >= @lv_from
      ORDER BY created_at DESCENDING, proposal
      INTO TABLE @rt_proposal.
    IF sy-subrc <> 0.
      CLEAR rt_proposal.
    ENDIF.

  ENDMETHOD.

  METHOD lapse.

    " the same write as an answer, and deliberately the same guard: two
    " people closing a proposal at once end with one of them doing it
    close(
      iv_proposal = iv_proposal
      iv_status   = c_status-lapsed ).

  ENDMETHOD.

  METHOD answer.

    " a proposal is a question, and only two of its states are answers.
    " Putting one back to open would lose who had already decided, and
    " lapsing is not something a person does.
    IF iv_status <> c_status-done
        AND iv_status <> c_status-dropped.
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>save_failed
        mv_message = |{ iv_proposal } { iv_status }| ).
    ENDIF.

    " a quantity says what was raised, so it belongs to a yes and to nothing
    " else; and a raise of nothing is a no by another name, which would leave
    " the table saying a transfer happened when none did
    IF iv_quantity < 0
        OR ( iv_quantity > 0 AND iv_status <> c_status-done ).
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>save_failed
        mv_message = |{ iv_proposal } { iv_quantity }| ).
    ENDIF.

    DATA(lv_raised) = iv_quantity.

    IF iv_status = c_status-done AND lv_raised = 0.
      " nothing said means the note was taken at its word
      SELECT SINGLE quantity
        FROM zstock_alloc_trf
        WHERE proposal = @iv_proposal
        INTO @lv_raised.
      IF sy-subrc <> 0.
        RAISE EXCEPTION NEW zcx_allocation(
          textid     = zcx_allocation=>save_failed
          mv_message = |{ iv_proposal }| ).
      ENDIF.
    ENDIF.

    close(
      iv_proposal = iv_proposal
      iv_status   = iv_status
      iv_quantity = lv_raised ).

  ENDMETHOD.

  METHOD close.

    DATA lv_timestamp TYPE zstock_alloc_trf-closed_at.

    GET TIME STAMP FIELD lv_timestamp.

    " only an open one is closed, so two people closing at once end with one
    " of them doing it rather than with the second overwriting the first
    UPDATE zstock_alloc_trf
      SET status     = @iv_status,
          raised_qty = @iv_quantity,
          closed_by  = @sy-uname,
          closed_at  = @lv_timestamp
      WHERE proposal = @iv_proposal
        AND status = @c_status-open.
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>save_failed
        mv_message = |{ iv_proposal }| ).
    ENDIF.

  ENDMETHOD.

  METHOD is_open.

    " the key of the table is the proposal, so this is not a single read of a
    " full key however it is written. Counting is the honest way to ask a
    " question about a set, and one row is enough to answer it.
    SELECT COUNT( * )
      FROM zstock_alloc_trf
      WHERE to_werks = @iv_to_werks
        AND matnr = @iv_matnr
        AND from_werks = @iv_from_werks
        AND status = @c_status-open
      INTO @DATA(lv_count).

    rv_open = xsdbool( lv_count > 0 ).

  ENDMETHOD.

  METHOD promised_by.

    " the line type is spelled out rather than inlined, see ANOMALIES.md
    DATA lt_note TYPE STANDARD TABLE OF ty_note WITH EMPTY KEY.

    " added up here rather than by the database, because SUM over a quantity
    " field is where a rounding argument with the database starts and there
    " are never many open notes about one material
    SELECT quantity
      FROM zstock_alloc_trf
      WHERE from_werks = @iv_from_werks
        AND matnr = @iv_matnr
        AND status = @c_status-open
      ORDER BY PRIMARY KEY
      INTO TABLE @lt_note.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT lt_note INTO DATA(ls_note).
      rv_quantity = rv_quantity + ls_note-quantity.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
