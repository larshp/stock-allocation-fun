CLASS zcl_authority_plant DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_allocation_authority.

    "! Changing material stock at plant level, the same object the standard
    "! inventory transactions check.
    CONSTANTS c_activity_change TYPE activ_auth VALUE '02'.

    "! <p class="shorttext synchronized">Wire up the check</p>
    "!
    "! Which activity to ask for is the caller's decision: a run changes the
    "! plant's stock situation, a display only reads it, and a user who may see
    "! the answer need not be allowed to work it out again.
    "!
    "! @parameter iv_activity | <p class="shorttext synchronized">Activity of M_MATE_WRK, change by default</p>
    METHODS constructor
      IMPORTING
        iv_activity TYPE activ_auth DEFAULT c_activity_change.

  PRIVATE SECTION.

    DATA mv_activity TYPE activ_auth.

ENDCLASS.


CLASS zcl_authority_plant IMPLEMENTATION.

  METHOD constructor.
    mv_activity = iv_activity.
  ENDMETHOD.

  METHOD zif_allocation_authority~check_plant.

    AUTHORITY-CHECK OBJECT 'M_MATE_WRK'
      ID 'ACTVT' FIELD mv_activity
      ID 'WERKS' FIELD iv_werks.
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zcx_allocation(
        textid   = zcx_allocation=>not_authorised
        mv_werks = |{ iv_werks }| ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
