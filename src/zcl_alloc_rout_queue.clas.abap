CLASS zcl_alloc_rout_queue DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS queue_time
      IMPORTING
        iv_wait         TYPE i
        iv_count        TYPE i
      RETURNING
        VALUE(rv_queue) TYPE i.

    METHODS is_waiting
      IMPORTING
        iv_wait      TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS wait_count
      IMPORTING
        it_waits        TYPE ty_values_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_rout_queue IMPLEMENTATION.

  METHOD queue_time.
    " The average queue time is the wait spread over the operations.
    IF iv_count <= 0.
      RETURN.
    ENDIF.

    rv_queue = iv_wait DIV iv_count.
  ENDMETHOD.

  METHOD is_waiting.
    " The operation is waiting once any queue time has built up.
    rv_ok = xsdbool( iv_wait > 0 ).
  ENDMETHOD.

  METHOD wait_count.
    " The count gathers the operations that are waiting.
    LOOP AT it_waits INTO DATA(lv_wait).
      IF lv_wait > 0.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
