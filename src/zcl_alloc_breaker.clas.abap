CLASS zcl_alloc_breaker DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_state TYPE c LENGTH 10.

    CONSTANTS: BEGIN OF state,
                 closed    TYPE ty_state VALUE 'CLOSED',
                 open      TYPE ty_state VALUE 'OPEN',
                 half_open TYPE ty_state VALUE 'HALF_OPEN',
               END OF state.

    METHODS constructor
      IMPORTING
        iv_threshold TYPE i DEFAULT 3.

    METHODS is_allowed
      RETURNING
        VALUE(rv_allowed) TYPE abap_bool.

    METHODS record_success
      RETURNING
        VALUE(rv_state) TYPE ty_state.

    METHODS record_failure
      RETURNING
        VALUE(rv_state) TYPE ty_state.

    METHODS probe_half_open
      RETURNING
        VALUE(rv_state) TYPE ty_state.

    METHODS get_state
      RETURNING
        VALUE(rv_state) TYPE ty_state.

    METHODS failure_count
      RETURNING
        VALUE(rv_count) TYPE i.

  PRIVATE SECTION.
    DATA mv_failures  TYPE i.
    DATA mv_state     TYPE ty_state.
    DATA mv_threshold TYPE i.

ENDCLASS.


CLASS zcl_alloc_breaker IMPLEMENTATION.

  METHOD constructor.
    mv_state = state-closed.
    mv_failures = 0.

    IF iv_threshold <= 0.
      mv_threshold = 1.
    ELSE.
      mv_threshold = iv_threshold.
    ENDIF.
  ENDMETHOD.

  METHOD get_state.
    rv_state = mv_state.
  ENDMETHOD.

  METHOD failure_count.
    rv_count = mv_failures.
  ENDMETHOD.

  METHOD is_allowed.
    IF mv_state = state-open.
      rv_allowed = abap_false.
    ELSE.
      rv_allowed = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD record_failure.
    mv_failures = mv_failures + 1.

    IF mv_state = state-half_open.
      mv_state = state-open.
    ELSEIF mv_failures >= mv_threshold.
      mv_state = state-open.
    ENDIF.

    rv_state = mv_state.
  ENDMETHOD.

  METHOD record_success.
    mv_failures = 0.

    IF mv_state = state-half_open.
      mv_state = state-closed.
    ENDIF.

    rv_state = mv_state.
  ENDMETHOD.

  METHOD probe_half_open.
    IF mv_state = state-open.
      mv_state = state-half_open.
    ENDIF.

    rv_state = mv_state.
  ENDMETHOD.

ENDCLASS.
