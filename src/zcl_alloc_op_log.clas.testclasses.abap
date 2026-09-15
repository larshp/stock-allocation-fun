CLASS ltcl_alloc_op_log DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_op_log.

    METHODS setup.

    METHODS tracks_status        FOR TESTING.
    METHODS sums_durations       FOR TESTING.
    METHODS finds_errors         FOR TESTING.
    METHODS finds_slowest        FOR TESTING.
    METHODS empty_returns_defaults FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_op_log IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_op_log( ).
  ENDMETHOD.

  METHOD tracks_status.
    DATA ls_entry TYPE zcl_alloc_op_log=>ty_entry.

    ls_entry = mo_cut->add( iv_name = 'ALLOCATE' iv_duration_ms = 120 iv_ok = abap_true ).

    cl_abap_unit_assert=>assert_equals( act = ls_entry-status exp = 'S' ).
    cl_abap_unit_assert=>assert_equals( act = ls_entry-seq exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_entry-duration_ms exp = 120 ).

    ls_entry = mo_cut->add( iv_name = 'POST' iv_duration_ms = 40 iv_ok = abap_false ).

    cl_abap_unit_assert=>assert_equals( act = ls_entry-status exp = 'E' ).
    cl_abap_unit_assert=>assert_equals( act = ls_entry-name exp = 'POST' ).
  ENDMETHOD.

  METHOD sums_durations.
    DATA ls_entry TYPE zcl_alloc_op_log=>ty_entry.

    ls_entry = mo_cut->add( iv_name = 'A' iv_duration_ms = 10 iv_ok = abap_true ).
    ls_entry = mo_cut->add( iv_name = 'B' iv_duration_ms = 35 iv_ok = abap_true ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->total_ms( ) exp = 45 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 2 ).
  ENDMETHOD.

  METHOD finds_errors.
    DATA ls_entry  TYPE zcl_alloc_op_log=>ty_entry.
    DATA lt_errors TYPE zcl_alloc_op_log=>ty_entry_tt.

    ls_entry = mo_cut->add( iv_name = 'A' iv_duration_ms = 10 iv_ok = abap_true ).
    ls_entry = mo_cut->add( iv_name = 'B' iv_duration_ms = 20 iv_ok = abap_false ).

    lt_errors = mo_cut->errors( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_errors ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_errors[ 1 ]-name exp = 'B' ).
  ENDMETHOD.

  METHOD finds_slowest.
    DATA ls_entry TYPE zcl_alloc_op_log=>ty_entry.

    ls_entry = mo_cut->add( iv_name = 'A' iv_duration_ms = 10 iv_ok = abap_true ).
    ls_entry = mo_cut->add( iv_name = 'B' iv_duration_ms = 90 iv_ok = abap_true ).
    ls_entry = mo_cut->add( iv_name = 'C' iv_duration_ms = 30 iv_ok = abap_true ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->slowest( ) exp = 'B' ).
  ENDMETHOD.

  METHOD empty_returns_defaults.
    DATA lt_errors TYPE zcl_alloc_op_log=>ty_entry_tt.

    lt_errors = mo_cut->errors( ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->total_ms( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->slowest( ) exp = '' ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_errors ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
