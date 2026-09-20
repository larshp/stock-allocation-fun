CLASS zcl_alloc_visible DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    "! <p class="shorttext synchronized">Wire up the question</p>
    "!
    "! @parameter io_authority | <p class="shorttext synchronized">Decides who may see a plant</p>
    METHODS constructor
      IMPORTING
        io_authority TYPE REF TO zif_allocation_authority.

    "! <p class="shorttext synchronized">Whether the user may see a plant at all</p>
    "!
    "! Three pages now ask about plants other than the one they were called
    "! for: where else the stock is, what is worth proposing, and what the
    "! proposals on the worklist would cost the plant sending them. All three
    "! leave a plant the user may not see out rather than refusing the page --
    "! a user allowed to see the plant that is short is not thereby allowed to
    "! see the rest of the company, and the question they asked was about
    "! their own plant.
    "!
    "! The answer is remembered per plant. A plant asked about once per
    "! material would be an authority check per material, and forty short
    "! materials of the same six plants is two hundred and forty checks for
    "! six answers.
    "!
    "! @parameter iv_werks | <p class="shorttext synchronized">Plant</p>
    "! @parameter rv_seen  | <p class="shorttext synchronized">True if the user may see it</p>
    METHODS may_see
      IMPORTING
        iv_werks       TYPE mard-werks
      RETURNING
        VALUE(rv_seen) TYPE abap_bool.

    "! <p class="shorttext synchronized">Refuse the page to a user who may not see the plant</p>
    "!
    "! The plant a page was called for is refused rather than left out, so this
    "! hands the question straight to the authority object and lets its
    "! exception through untouched: a site that swapped in its own object said
    "! something particular in it, and answering "not authorised" on its behalf
    "! would throw that away.
    "!
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">User may not see this plant</p>
    METHODS check_plant
      IMPORTING
        iv_werks TYPE mard-werks
      RAISING
        zcx_allocation.

  PRIVATE SECTION.

    "! The plants already asked about, and what the answer was.
    TYPES:
      BEGIN OF ty_asked,
        werks TYPE mard-werks,
        seen  TYPE abap_bool,
      END OF ty_asked.
    TYPES ty_asked_tab TYPE STANDARD TABLE OF ty_asked WITH EMPTY KEY.

    DATA mo_authority TYPE REF TO zif_allocation_authority.
    DATA mt_asked     TYPE ty_asked_tab.

ENDCLASS.


CLASS zcl_alloc_visible IMPLEMENTATION.

  METHOD constructor.

    mo_authority = io_authority.

  ENDMETHOD.

  METHOD check_plant.

    mo_authority->check_plant( iv_werks ).

  ENDMETHOD.

  METHOD may_see.

    IF line_exists( mt_asked[ werks = iv_werks ] ).
      rv_seen = mt_asked[ werks = iv_werks ]-seen.
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
      werks = iv_werks
      seen  = rv_seen ) TO mt_asked.

  ENDMETHOD.

ENDCLASS.
