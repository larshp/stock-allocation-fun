CLASS zcl_alloc_valm_alert DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material TYPE matnr,
             value    TYPE i,
             limit    TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_alert,
             material TYPE matnr,
             message  TYPE string,
           END OF ty_alert.
    TYPES ty_alert_tt TYPE STANDARD TABLE OF ty_alert WITH DEFAULT KEY.

    METHODS alerts
      IMPORTING
        it_lines         TYPE ty_line_tt
      RETURNING
        VALUE(rt_alerts) TYPE ty_alert_tt.

    METHODS alert_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS is_alerting
      IMPORTING
        iv_value     TYPE i
        iv_limit     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_valm_alert IMPLEMENTATION.

  METHOD is_alerting.
    " A value raises an alert once it passes its limit.
    rv_ok = xsdbool( iv_value > iv_limit ).
  ENDMETHOD.

  METHOD alerts.
    DATA ls_alert TYPE ty_alert.

    " Every line past its limit raises one alert.
    LOOP AT it_lines INTO DATA(ls_line).
      IF is_alerting( iv_value = ls_line-value
                      iv_limit = ls_line-limit ) = abap_false.
        CONTINUE.
      ENDIF.

      ls_alert-material = ls_line-material.
      ls_alert-message = 'value over limit'.
      APPEND ls_alert TO rt_alerts.
    ENDLOOP.
  ENDMETHOD.

  METHOD alert_count.
    DATA lt_alerts TYPE ty_alert_tt.

    " The count is how many alerts the lines raised.
    lt_alerts = alerts( it_lines ).
    rv_count = lines( lt_alerts ).
  ENDMETHOD.

ENDCLASS.
