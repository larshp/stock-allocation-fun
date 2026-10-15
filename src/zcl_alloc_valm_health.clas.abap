CLASS zcl_alloc_valm_health DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS is_healthy
      IMPORTING
        iv_alert_count TYPE i
        iv_max_alerts  TYPE i
      RETURNING
        VALUE(rv_ok)   TYPE abap_bool.

    METHODS issue_count
      IMPORTING
        it_values       TYPE ty_values_tt
        iv_threshold    TYPE i
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS score
      IMPORTING
        iv_alert_count  TYPE i
        iv_line_count   TYPE i
      RETURNING
        VALUE(rv_score) TYPE i.

ENDCLASS.


CLASS zcl_alloc_valm_health IMPLEMENTATION.

  METHOD is_healthy.
    " The valuation is healthy while it stays under the alert allowance.
    rv_ok = xsdbool( iv_alert_count <= iv_max_alerts ).
  ENDMETHOD.

  METHOD issue_count.
    " An issue is a value that has grown past its threshold.
    LOOP AT it_values INTO DATA(lv_value).
      IF lv_value <= iv_threshold.
        CONTINUE.
      ENDIF.

      rv_count = rv_count + 1.
    ENDLOOP.
  ENDMETHOD.

  METHOD score.
    " The score is the share of lines without an alert.
    IF iv_line_count <= 0.
      RETURN.
    ENDIF.

    rv_score = ( iv_line_count - iv_alert_count ) * 100 DIV iv_line_count.
  ENDMETHOD.

ENDCLASS.
