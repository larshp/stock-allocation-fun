CLASS zcl_alloc_health DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_indicator,
             indicator  TYPE string,
             is_healthy TYPE abap_bool,
             message    TYPE string,
           END OF ty_indicator.
    TYPES ty_indicator_tt TYPE STANDARD TABLE OF ty_indicator WITH DEFAULT KEY.

    TYPES ty_names_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_report,
             total     TYPE i,
             healthy   TYPE i,
             unhealthy TYPE i,
             status    TYPE string,
           END OF ty_report.

    METHODS check
      IMPORTING
        it_indicators    TYPE ty_indicator_tt
      RETURNING
        VALUE(rs_report) TYPE ty_report.

    METHODS unhealthy_names
      IMPORTING
        it_indicators   TYPE ty_indicator_tt
      RETURNING
        VALUE(rt_names) TYPE ty_names_tt.

ENDCLASS.


CLASS zcl_alloc_health IMPLEMENTATION.

  METHOD check.
    rs_report-total = lines( it_indicators ).

    LOOP AT it_indicators INTO DATA(ls_indicator).
      IF ls_indicator-is_healthy = abap_true.
        rs_report-healthy = rs_report-healthy + 1.
      ENDIF.
    ENDLOOP.

    rs_report-unhealthy = rs_report-total - rs_report-healthy.

    IF rs_report-total = 0.
      rs_report-status = 'unknown'.
    ELSEIF rs_report-unhealthy = 0.
      rs_report-status = 'up'.
    ELSEIF rs_report-healthy = 0.
      rs_report-status = 'down'.
    ELSE.
      rs_report-status = 'degraded'.
    ENDIF.
  ENDMETHOD.

  METHOD unhealthy_names.
    LOOP AT it_indicators INTO DATA(ls_indicator).
      IF ls_indicator-is_healthy = abap_false.
        APPEND ls_indicator-indicator TO rt_names.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
