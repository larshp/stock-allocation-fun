CLASS zcl_alloc_cert_expiry DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS days_left
      IMPORTING
        iv_today       TYPE i
        iv_valid_to    TYPE i
      RETURNING
        VALUE(rv_days) TYPE i.

    METHODS state
      IMPORTING
        iv_today        TYPE i
        iv_valid_to     TYPE i
        iv_warn_days    TYPE i
      RETURNING
        VALUE(rv_state) TYPE string.

ENDCLASS.


CLASS zcl_alloc_cert_expiry IMPLEMENTATION.

  METHOD days_left.
    " A certificate is valid through its end day, so the remaining time is the
    " difference and never negative.
    IF iv_valid_to <= iv_today.
      RETURN.
    ENDIF.

    rv_days = iv_valid_to - iv_today.
  ENDMETHOD.

  METHOD state.
    IF iv_today > iv_valid_to.
      rv_state = 'EXPIRED'.
    ELSEIF iv_warn_days > 0
       AND days_left( iv_today    = iv_today
                      iv_valid_to = iv_valid_to ) <= iv_warn_days.
      rv_state = 'EXPIRING'.
    ELSE.
      rv_state = 'VALID'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
