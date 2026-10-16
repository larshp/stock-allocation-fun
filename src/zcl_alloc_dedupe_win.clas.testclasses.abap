CLASS ltcl_alloc_dedupe_win DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_dedupe_win.

    METHODS setup.

    METHODS first_not_duplicate FOR TESTING.
    METHODS inside_window_dup   FOR TESTING.
    METHODS outside_window_new  FOR TESTING.
    METHODS window_zero_is_dup  FOR TESTING.
    METHODS refresh_stamp       FOR TESTING.
    METHODS purge_removes_old   FOR TESTING.
    METHODS purge_keeps_cutoff  FOR TESTING.
    METHODS count_entries       FOR TESTING.
    METHODS reset_clears        FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_dedupe_win IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_dedupe_win( ).
  ENDMETHOD.

  METHOD first_not_duplicate.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_duplicate( iv_key = 'K1' iv_stamp = 100 iv_window = 10 )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 1 ).
  ENDMETHOD.

  METHOD inside_window_dup.
    mo_cut->is_duplicate( iv_key = 'K1' iv_stamp = 100 iv_window = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_duplicate( iv_key = 'K1' iv_stamp = 105 iv_window = 10 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 1 ).
  ENDMETHOD.

  METHOD outside_window_new.
    mo_cut->is_duplicate( iv_key = 'K1' iv_stamp = 100 iv_window = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_duplicate( iv_key = 'K1' iv_stamp = 120 iv_window = 10 )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 1 ).
  ENDMETHOD.

  METHOD window_zero_is_dup.
    mo_cut->is_duplicate( iv_key = 'K1' iv_stamp = 100 iv_window = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_duplicate( iv_key = 'K1' iv_stamp = 100 iv_window = 0 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD refresh_stamp.
    mo_cut->is_duplicate( iv_key = 'K1' iv_stamp = 100 iv_window = 10 ).
    mo_cut->is_duplicate( iv_key = 'K1' iv_stamp = 120 iv_window = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_duplicate( iv_key = 'K1' iv_stamp = 125 iv_window = 10 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD purge_removes_old.
    mo_cut->is_duplicate( iv_key = 'A' iv_stamp = 10 iv_window = 0 ).
    mo_cut->is_duplicate( iv_key = 'B' iv_stamp = 50 iv_window = 0 ).

    mo_cut->purge_before( 20 ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 1 ).
  ENDMETHOD.

  METHOD purge_keeps_cutoff.
    mo_cut->is_duplicate( iv_key = 'A' iv_stamp = 20 iv_window = 0 ).
    mo_cut->is_duplicate( iv_key = 'B' iv_stamp = 19 iv_window = 0 ).

    mo_cut->purge_before( 20 ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_duplicate( iv_key = 'A' iv_stamp = 20 iv_window = 0 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD count_entries.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 0 ).

    mo_cut->is_duplicate( iv_key = 'A' iv_stamp = 1 iv_window = 0 ).
    mo_cut->is_duplicate( iv_key = 'B' iv_stamp = 1 iv_window = 0 ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 2 ).
  ENDMETHOD.

  METHOD reset_clears.
    mo_cut->is_duplicate( iv_key = 'A' iv_stamp = 1 iv_window = 0 ).
    mo_cut->reset( ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_duplicate( iv_key = 'A' iv_stamp = 1 iv_window = 0 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
