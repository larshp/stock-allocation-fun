CLASS zcl_alloc_e2e_scenario DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_verdict,
             lines        TYPE i,
             requested    TYPE menge_d,
             allocated    TYPE menge_d,
             shortage     TYPE menge_d,
             rules_failed TYPE i,
             stock_alerts TYPE i,
             posting_ok   TYPE abap_bool,
             reason       TYPE string,
           END OF ty_verdict.

    METHODS run
      IMPORTING
        it_result         TYPE zcl_stock_allocator=>ty_result_tt
        iv_available      TYPE menge_d
        it_positions      TYPE zcl_alloc_stock_guard=>ty_position_tt
      RETURNING
        VALUE(rs_verdict) TYPE ty_verdict.

  PRIVATE SECTION.
    CONSTANTS c_ok    TYPE string VALUE 'ok'.
    CONSTANTS c_stock TYPE string VALUE 'stock would go negative'.

ENDCLASS.


CLASS zcl_alloc_e2e_scenario IMPLEMENTATION.

  METHOD run.
    DATA lo_audit    TYPE REF TO zcl_alloc_run_audit.
    DATA lo_check    TYPE REF TO zcl_alloc_invariant_check.
    DATA lo_guard    TYPE REF TO zcl_alloc_stock_guard.
    DATA ls_audit    TYPE zcl_alloc_run_audit=>ty_audit.
    DATA lt_checks   TYPE zcl_alloc_invariant_check=>ty_check_tt.
    DATA lt_findings TYPE zcl_alloc_stock_guard=>ty_finding_tt.

    lo_audit = NEW zcl_alloc_run_audit( ).
    lo_check = NEW zcl_alloc_invariant_check( ).
    lo_guard = NEW zcl_alloc_stock_guard( ).

    ls_audit = lo_audit->audit( it_result ).
    lt_checks = lo_check->check( it_result    = it_result
                                 iv_available = iv_available ).
    lt_findings = lo_guard->check( it_positions ).

    rs_verdict-lines = ls_audit-lines.
    rs_verdict-requested = ls_audit-requested.
    rs_verdict-allocated = ls_audit-allocated.
    rs_verdict-shortage = ls_audit-shortage.
    rs_verdict-stock_alerts = lines( lt_findings ).

    " The first broken rule is the most useful thing to report, so it becomes
    " the reason instead of a generic message.
    LOOP AT lt_checks INTO DATA(ls_check).
      IF ls_check-ok = abap_true.
        CONTINUE.
      ENDIF.

      rs_verdict-rules_failed = rs_verdict-rules_failed + 1.

      IF rs_verdict-reason IS INITIAL.
        rs_verdict-reason = ls_check-rule_id.
      ENDIF.
    ENDLOOP.

    IF rs_verdict-rules_failed > 0.
      RETURN.
    ENDIF.

    IF rs_verdict-stock_alerts > 0.
      rs_verdict-reason = c_stock.
      RETURN.
    ENDIF.

    rs_verdict-posting_ok = abap_true.
    rs_verdict-reason = c_ok.
  ENDMETHOD.

ENDCLASS.
