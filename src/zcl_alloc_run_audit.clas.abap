CLASS zcl_alloc_run_audit DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_audit,
             lines        TYPE i,
             requested    TYPE menge_d,
             allocated    TYPE menge_d,
             shortage     TYPE menge_d,
             deferred     TYPE i,
             over_alloc   TYPE abap_bool,
             has_negative TYPE abap_bool,
             full         TYPE abap_bool,
           END OF ty_audit.

    METHODS audit
      IMPORTING
        it_result       TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rs_audit) TYPE ty_audit.

ENDCLASS.


CLASS zcl_alloc_run_audit IMPLEMENTATION.

  METHOD audit.
    DATA lv_gap TYPE menge_d.

    rs_audit-lines = lines( it_result ).

    LOOP AT it_result INTO DATA(ls_line).
      rs_audit-requested = rs_audit-requested + ls_line-requested_qty.
      rs_audit-allocated = rs_audit-allocated + ls_line-allocated_qty.

      " The shortage is derived from the quantities rather than read from the
      " line, so the audit is an independent check of the run.
      lv_gap = ls_line-requested_qty - ls_line-allocated_qty.
      IF lv_gap > 0.
        rs_audit-shortage = rs_audit-shortage + lv_gap.
      ENDIF.

      IF ls_line-deferred = abap_true.
        rs_audit-deferred = rs_audit-deferred + 1.
      ENDIF.

      IF ls_line-allocated_qty > ls_line-requested_qty.
        rs_audit-over_alloc = abap_true.
      ENDIF.

      IF ls_line-allocated_qty < 0.
        rs_audit-has_negative = abap_true.
      ENDIF.
    ENDLOOP.

    " A run without lines is not "full", it is empty.
    IF rs_audit-lines > 0 AND rs_audit-shortage = 0.
      rs_audit-full = abap_true.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
