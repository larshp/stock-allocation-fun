CLASS zcl_alloc_retry DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_plan,
             attempt       TYPE i,
             retry         TYPE abap_bool,
             delay_seconds TYPE i,
             message       TYPE c LENGTH 60,
           END OF ty_plan.

    METHODS plan
      IMPORTING
        iv_attempt      TYPE i
        iv_max_attempts TYPE i
        iv_base_delay   TYPE i
      RETURNING
        VALUE(rs_plan)  TYPE ty_plan.

    METHODS should_retry
      IMPORTING
        iv_attempt      TYPE i
        iv_max_attempts TYPE i
      RETURNING
        VALUE(rv_retry) TYPE abap_bool.

    METHODS backoff
      IMPORTING
        iv_attempt        TYPE i
        iv_base_delay     TYPE i
      RETURNING
        VALUE(rv_seconds) TYPE i.

ENDCLASS.


CLASS zcl_alloc_retry IMPLEMENTATION.

  METHOD backoff.
    DATA lv_steps TYPE i.
    DATA lv_value TYPE i.

    IF iv_base_delay <= 0.
      rv_seconds = 0.
      RETURN.
    ENDIF.

    lv_value = iv_base_delay.
    lv_steps = iv_attempt - 1.
    IF lv_steps < 0.
      lv_steps = 0.
    ENDIF.

    DO lv_steps TIMES.
      lv_value = lv_value * 2.
      IF lv_value >= 300.
        lv_value = 300.
        EXIT.
      ENDIF.
    ENDDO.

    rv_seconds = lv_value.
  ENDMETHOD.

  METHOD should_retry.
    IF iv_max_attempts <= 0.
      rv_retry = abap_false.
      RETURN.
    ENDIF.

    IF iv_attempt < iv_max_attempts.
      rv_retry = abap_true.
    ELSE.
      rv_retry = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD plan.
    rs_plan-attempt = iv_attempt.
    rs_plan-retry = should_retry( iv_attempt = iv_attempt iv_max_attempts = iv_max_attempts ).

    IF rs_plan-retry = abap_true.
      rs_plan-delay_seconds = backoff( iv_attempt = iv_attempt iv_base_delay = iv_base_delay ).
      rs_plan-message = |Retry { iv_attempt } in { rs_plan-delay_seconds }s|.
    ELSE.
      rs_plan-delay_seconds = 0.
      rs_plan-message = |Giving up after { iv_attempt } attempts|.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
