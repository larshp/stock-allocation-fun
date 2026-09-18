CLASS zcl_alloc_smoke DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_check,
             check_name TYPE string,
             passed     TYPE abap_bool,
             detail     TYPE string,
           END OF ty_check.
    TYPES ty_check_tt TYPE STANDARD TABLE OF ty_check WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_summary,
             total  TYPE i,
             passed TYPE i,
             failed TYPE i,
             ok     TYPE abap_bool,
           END OF ty_summary.

    METHODS add
      IMPORTING
        iv_name   TYPE string
        iv_passed TYPE abap_bool
        iv_detail TYPE string.

    METHODS run
      RETURNING
        VALUE(rs_summary) TYPE ty_summary.

    METHODS failed
      RETURNING
        VALUE(rt_failed) TYPE ty_check_tt.

    METHODS reset.

  PRIVATE SECTION.
    DATA mt_checks TYPE ty_check_tt.

ENDCLASS.


CLASS zcl_alloc_smoke IMPLEMENTATION.

  METHOD add.
    DATA ls_check TYPE ty_check.

    DELETE mt_checks WHERE check_name = iv_name.

    ls_check-check_name = iv_name.
    ls_check-passed = iv_passed.
    ls_check-detail = iv_detail.
    APPEND ls_check TO mt_checks.
  ENDMETHOD.

  METHOD run.
    rs_summary-total = lines( mt_checks ).

    LOOP AT mt_checks INTO DATA(ls_check).
      IF ls_check-passed = abap_true.
        rs_summary-passed = rs_summary-passed + 1.
      ENDIF.
    ENDLOOP.

    rs_summary-failed = rs_summary-total - rs_summary-passed.

    IF rs_summary-failed = 0.
      rs_summary-ok = abap_true.
    ELSE.
      rs_summary-ok = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD failed.
    LOOP AT mt_checks INTO DATA(ls_check).
      IF ls_check-passed = abap_false.
        APPEND ls_check TO rt_failed.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD reset.
    CLEAR mt_checks.
  ENDMETHOD.

ENDCLASS.
