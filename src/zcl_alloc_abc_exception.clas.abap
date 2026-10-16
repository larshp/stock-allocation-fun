CLASS zcl_alloc_abc_exception DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS is_exception
      IMPORTING
        iv_cost      TYPE i
        iv_limit     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS reason
      IMPORTING
        iv_cost          TYPE i
        iv_limit         TYPE i
      RETURNING
        VALUE(rv_reason) TYPE string.

    METHODS count_of
      IMPORTING
        it_values       TYPE ty_values_tt
        iv_limit        TYPE i
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_abc_exception IMPLEMENTATION.

  METHOD is_exception.
    " An activity is an exception once its cost passes the limit.
    rv_ok = xsdbool( iv_cost > iv_limit ).
  ENDMETHOD.

  METHOD reason.
    " The exception carries the reason it was raised.
    IF is_exception( iv_cost = iv_cost iv_limit = iv_limit ) = abap_true.
      rv_reason = 'over limit'.
    ELSE.
      rv_reason = 'none'.
    ENDIF.
  ENDMETHOD.

  METHOD count_of.
    " The count gathers the activities that are exceptions.
    LOOP AT it_values INTO DATA(lv_value).
      IF lv_value > iv_limit.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
