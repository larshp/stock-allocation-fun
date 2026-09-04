CLASS zcl_authority_alloc DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_allocation_authority.

    "! Allocating, releasing and re-cutting: everything that changes what the
    "! plant has promised.
    CONSTANTS c_activity_change TYPE activ_auth VALUE '02'.

    "! Reading what was decided, and working out what would be decided.
    CONSTANTS c_activity_display TYPE activ_auth VALUE '03'.

    "! <p class="shorttext synchronized">Wire up the check</p>
    "!
    "! `ZSTOCK_ALL` is this solution's own authorization object, with the two
    "! fields any check here needs: what is being done and where. Allocating is
    "! not maintaining a material master, and a business that lets a planner do
    "! the one has no reason to have to let them do the other, which is what
    "! guarding a custom process with `M_MATE_WRK` amounts to.
    "!
    "! Which activity to ask for is the caller's decision: a run changes the
    "! plant's stock situation, a display only reads it, and a user who may see
    "! the answer need not be allowed to work it out again.
    "!
    "! @parameter iv_activity | <p class="shorttext synchronized">Activity of ZSTOCK_ALL, change by default</p>
    METHODS constructor
      IMPORTING
        iv_activity TYPE activ_auth DEFAULT c_activity_change.

  PRIVATE SECTION.

    DATA mv_activity TYPE activ_auth.

ENDCLASS.


CLASS zcl_authority_alloc IMPLEMENTATION.

  METHOD constructor.
    mv_activity = iv_activity.
  ENDMETHOD.

  METHOD zif_allocation_authority~check_plant.

    AUTHORITY-CHECK OBJECT 'ZSTOCK_ALL'
      ID 'ACTVT' FIELD mv_activity
      ID 'WERKS' FIELD iv_werks.
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zcx_allocation(
        textid   = zcx_allocation=>not_authorised
        mv_werks = |{ iv_werks }| ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
