CLASS zcl_alloc_accept_decision DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS decide
      IMPORTING
        iv_defects         TYPE i
        iv_accept_no       TYPE i
        iv_reject_no       TYPE i
      RETURNING
        VALUE(rv_decision) TYPE string.

ENDCLASS.


CLASS zcl_alloc_accept_decision IMPLEMENTATION.

  METHOD decide.
    " Classic attribute sampling: at or below the accept number the lot is
    " accepted, at or above the reject number it is rejected, and in between
    " more samples are needed.
    IF iv_reject_no <= 0 OR iv_reject_no <= iv_accept_no.
      RETURN.
    ENDIF.

    IF iv_defects <= iv_accept_no.
      rv_decision = 'ACCEPT'.
    ELSEIF iv_defects >= iv_reject_no.
      rv_decision = 'REJECT'.
    ELSE.
      rv_decision = 'CONTINUE'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
