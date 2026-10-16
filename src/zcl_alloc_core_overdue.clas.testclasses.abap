CLASS ltcl_alloc_core_overdue DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_core_overdue.
    DATA mt_cor TYPE zcl_alloc_core_overdue=>ty_core_tt.

    METHODS setup.

    METHODS core
      IMPORTING
        iv_due         TYPE d
        iv_return      TYPE d
      RETURNING
        VALUE(rs_core) TYPE zcl_alloc_core_overdue=>ty_core.

    METHODS flags_late      FOR TESTING.
    METHODS ignores_returned FOR TESTING.
    METHODS not_due_yet     FOR TESTING.
    METHODS counts_days     FOR TESTING.
    METHODS any_overdue     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_core_overdue IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_core_overdue( ).
  ENDMETHOD.

  METHOD core.
    rs_core-material = 'M1'.
    rs_core-due_day = iv_due.
    rs_core-return_day = iv_return.
  ENDMETHOD.

  METHOD flags_late.
    DATA ls_core TYPE zcl_alloc_core_overdue=>ty_core.

    ls_core = core( iv_due = '20260101' iv_return = '00000000' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->overdue( is_core = ls_core iv_today = '20260111' )
      exp = abap_true ).
  ENDMETHOD.

  METHOD ignores_returned.
    DATA ls_core TYPE zcl_alloc_core_overdue=>ty_core.

    ls_core = core( iv_due = '20260101' iv_return = '20260105' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->overdue( is_core = ls_core iv_today = '20260111' )
      exp = abap_false ).
  ENDMETHOD.

  METHOD not_due_yet.
    DATA ls_core TYPE zcl_alloc_core_overdue=>ty_core.

    ls_core = core( iv_due = '20260101' iv_return = '00000000' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->overdue( is_core = ls_core iv_today = '20251231' )
      exp = abap_false ).
  ENDMETHOD.

  METHOD counts_days.
    DATA ls_core TYPE zcl_alloc_core_overdue=>ty_core.

    ls_core = core( iv_due = '20260101' iv_return = '00000000' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->overdue_days( is_core = ls_core iv_today = '20260111' )
      exp = 10 ).
  ENDMETHOD.

  METHOD any_overdue.
    DATA ls_core TYPE zcl_alloc_core_overdue=>ty_core.

    ls_core = core( iv_due = '20260101' iv_return = '20260105' ).
    APPEND ls_core TO mt_cor.
    ls_core = core( iv_due = '20260101' iv_return = '00000000' ).
    APPEND ls_core TO mt_cor.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_overdue( it_cores = mt_cor iv_today = '20260111' )
      exp = abap_true ).
  ENDMETHOD.

ENDCLASS.
