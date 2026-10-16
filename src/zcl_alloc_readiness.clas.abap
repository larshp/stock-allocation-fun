CLASS zcl_alloc_readiness DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_probe,
             ready      TYPE abap_bool,
             reason     TYPE string,
             checks_run TYPE i,
             checks_ok  TYPE i,
           END OF ty_probe.

    METHODS probe
      IMPORTING
        it_indicators   TYPE zcl_alloc_health=>ty_indicator_tt
        iv_require_all  TYPE abap_bool
      RETURNING
        VALUE(rs_probe) TYPE ty_probe.

ENDCLASS.


CLASS zcl_alloc_readiness IMPLEMENTATION.

  METHOD probe.
    DATA lo_health TYPE REF TO zcl_alloc_health.
    DATA ls_report TYPE zcl_alloc_health=>ty_report.

    lo_health = NEW zcl_alloc_health( ).
    ls_report = lo_health->check( it_indicators ).

    rs_probe-checks_run = ls_report-total.
    rs_probe-checks_ok = ls_report-healthy.

    IF rs_probe-checks_run = 0.
      rs_probe-ready = abap_false.
      rs_probe-reason = 'no checks configured'.
      RETURN.
    ENDIF.

    IF iv_require_all = abap_true.
      IF ls_report-unhealthy = 0.
        rs_probe-ready = abap_true.
        rs_probe-reason = 'all checks passed'.
      ELSE.
        rs_probe-ready = abap_false.
        rs_probe-reason = 'at least one check failed'.
      ENDIF.
      RETURN.
    ENDIF.

    IF rs_probe-checks_ok > 0.
      rs_probe-ready = abap_true.
      rs_probe-reason = 'at least one check passed'.
    ELSE.
      rs_probe-ready = abap_false.
      rs_probe-reason = 'no check passed'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
