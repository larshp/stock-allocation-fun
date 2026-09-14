CLASS zcl_alloc_timeout DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_status,
             expired           TYPE abap_bool,
             remaining_seconds TYPE i,
             message           TYPE c LENGTH 60,
           END OF ty_status.

    METHODS check
      IMPORTING
        iv_limit_seconds TYPE i
        iv_elapsed       TYPE i
      RETURNING
        VALUE(rs_status) TYPE ty_status.

    METHODS is_expired
      IMPORTING
        iv_limit_seconds  TYPE i
        iv_elapsed        TYPE i
      RETURNING
        VALUE(rv_expired) TYPE abap_bool.

    METHODS remaining
      IMPORTING
        iv_limit_seconds    TYPE i
        iv_elapsed          TYPE i
      RETURNING
        VALUE(rv_remaining) TYPE i.

ENDCLASS.


CLASS zcl_alloc_timeout IMPLEMENTATION.

  METHOD check.
    rs_status-expired = is_expired( iv_limit_seconds = iv_limit_seconds
                                    iv_elapsed       = iv_elapsed ).
    rs_status-remaining_seconds = remaining( iv_limit_seconds = iv_limit_seconds
                                             iv_elapsed       = iv_elapsed ).

    IF rs_status-expired = abap_true.
      rs_status-message = 'Timeout exceeded'.
    ELSE.
      rs_status-message = |{ rs_status-remaining_seconds } seconds remaining|.
    ENDIF.
  ENDMETHOD.

  METHOD is_expired.
    IF iv_limit_seconds <= 0.
      rv_expired = abap_false.
      RETURN.
    ENDIF.

    IF iv_elapsed >= iv_limit_seconds.
      rv_expired = abap_true.
    ELSE.
      rv_expired = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD remaining.
    IF iv_limit_seconds <= 0.
      rv_remaining = 0.
      RETURN.
    ENDIF.

    rv_remaining = iv_limit_seconds - iv_elapsed.
    IF rv_remaining < 0.
      rv_remaining = 0.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
