CLASS ltcl_alloc_stats DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_stats.

    METHODS setup.

    METHODS starts_empty    FOR TESTING.
    METHODS totals_requests FOR TESTING.
    METHODS splits_coverage FOR TESTING.
    METHODS clamps_shortage FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_stats IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_stats( ).
  ENDMETHOD.

  METHOD starts_empty.
    DATA(ls_stats) = mo_cut->get( ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->runs( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_stats-requests exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_stats-allocated exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_stats-shortage exp = 0 ).
  ENDMETHOD.

  METHOD totals_requests.
    DATA ls_stats TYPE zcl_alloc_stats=>ty_stats.

    ls_stats = mo_cut->note( iv_requested = 100 iv_allocated = 40 ).
    ls_stats = mo_cut->note( iv_requested = 50 iv_allocated = 50 ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->runs( ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_stats-requests exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_stats-allocated exp = 90 ).
    cl_abap_unit_assert=>assert_equals( act = ls_stats-shortage exp = 60 ).
  ENDMETHOD.

  METHOD splits_coverage.
    DATA ls_stats TYPE zcl_alloc_stats=>ty_stats.

    ls_stats = mo_cut->note( iv_requested = 100 iv_allocated = 100 ).
    ls_stats = mo_cut->note( iv_requested = 100 iv_allocated = 70 ).

    cl_abap_unit_assert=>assert_equals( act = ls_stats-fully_covered exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_stats-short_covered exp = 1 ).
  ENDMETHOD.

  METHOD clamps_shortage.
    DATA ls_stats TYPE zcl_alloc_stats=>ty_stats.

    ls_stats = mo_cut->note( iv_requested = 10 iv_allocated = 25 ).

    cl_abap_unit_assert=>assert_equals( act = ls_stats-shortage exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_stats-fully_covered exp = 1 ).
  ENDMETHOD.

ENDCLASS.
