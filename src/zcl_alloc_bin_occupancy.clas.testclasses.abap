CLASS ltcl_alloc_bin_occupancy DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bin_occupancy.
    DATA mt_bin TYPE zcl_alloc_bin_occupancy=>ty_bin_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_capacity TYPE i
        iv_used     TYPE i.

    METHODS counts_occupied FOR TESTING.
    METHODS sums_capacity   FOR TESTING.
    METHODS average_used    FOR TESTING.
    METHODS empty_input     FOR TESTING.
    METHODS all_empty       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_bin_occupancy IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bin_occupancy( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_bin TYPE zcl_alloc_bin_occupancy=>ty_bin.

    ls_bin-capacity = iv_capacity.
    ls_bin-used = iv_used.
    APPEND ls_bin TO mt_bin.
  ENDMETHOD.

  METHOD counts_occupied.
    DATA ls_stat TYPE zcl_alloc_bin_occupancy=>ty_stat.

    add( iv_capacity = 100 iv_used = 40 ).
    add( iv_capacity = 100 iv_used = 0 ).
    add( iv_capacity = 50 iv_used = 50 ).

    ls_stat = mo_cut->analyse( it_bins = mt_bin ).

    cl_abap_unit_assert=>assert_equals( act = ls_stat-occupied exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_stat-empty exp = 1 ).
  ENDMETHOD.

  METHOD sums_capacity.
    DATA ls_stat TYPE zcl_alloc_bin_occupancy=>ty_stat.

    add( iv_capacity = 100 iv_used = 40 ).
    add( iv_capacity = 50 iv_used = 50 ).

    ls_stat = mo_cut->analyse( it_bins = mt_bin ).

    cl_abap_unit_assert=>assert_equals( act = ls_stat-total_used exp = 90 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_stat-total_capacity exp = 150 ).
  ENDMETHOD.

  METHOD average_used.
    DATA ls_stat TYPE zcl_alloc_bin_occupancy=>ty_stat.

    add( iv_capacity = 100 iv_used = 50 ).

    ls_stat = mo_cut->analyse( it_bins = mt_bin ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_stat-avg_utilisation exp = 50 ).
  ENDMETHOD.

  METHOD empty_input.
    DATA ls_stat TYPE zcl_alloc_bin_occupancy=>ty_stat.

    ls_stat = mo_cut->analyse( it_bins = mt_bin ).

    cl_abap_unit_assert=>assert_equals( act = ls_stat-occupied exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_stat-avg_utilisation exp = 0 ).
  ENDMETHOD.

  METHOD all_empty.
    DATA ls_stat TYPE zcl_alloc_bin_occupancy=>ty_stat.

    add( iv_capacity = 100 iv_used = 0 ).

    ls_stat = mo_cut->analyse( it_bins = mt_bin ).

    cl_abap_unit_assert=>assert_equals( act = ls_stat-empty exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_stat-avg_utilisation exp = 0 ).
  ENDMETHOD.

ENDCLASS.
