CLASS zcl_alloc_timer DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_summary,
             started    TYPE abap_bool,
             stopped    TYPE abap_bool,
             elapsed_ms TYPE i,
             message    TYPE c LENGTH 60,
           END OF ty_summary.

    METHODS start.

    METHODS stop.

    METHODS add_ms
      IMPORTING
        iv_ms TYPE i.

    METHODS is_running
      RETURNING
        VALUE(rv_running) TYPE abap_bool.

    METHODS elapsed
      RETURNING
        VALUE(rv_ms) TYPE i.

    METHODS summary
      RETURNING
        VALUE(rs_summary) TYPE ty_summary.

  PRIVATE SECTION.
    DATA mv_elapsed TYPE i.
    DATA mv_running TYPE abap_bool.
    DATA mv_started TYPE abap_bool.
    DATA mv_stopped TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_timer IMPLEMENTATION.

  METHOD start.
    mv_started = abap_true.
    mv_stopped = abap_false.
    mv_running = abap_true.
    mv_elapsed = 0.
  ENDMETHOD.

  METHOD stop.
    mv_running = abap_false.
    mv_stopped = abap_true.
  ENDMETHOD.

  METHOD add_ms.
    IF mv_running = abap_true.
      mv_elapsed = mv_elapsed + iv_ms.
    ENDIF.
  ENDMETHOD.

  METHOD is_running.
    rv_running = mv_running.
  ENDMETHOD.

  METHOD elapsed.
    rv_ms = mv_elapsed.
  ENDMETHOD.

  METHOD summary.
    rs_summary-started = mv_started.
    rs_summary-stopped = mv_stopped.
    rs_summary-elapsed_ms = mv_elapsed.

    IF mv_running = abap_true.
      rs_summary-message = 'Running'.
    ELSEIF mv_started = abap_true.
      rs_summary-message = |Elapsed { mv_elapsed } ms|.
    ELSE.
      rs_summary-message = 'Not started'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
