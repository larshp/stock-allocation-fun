CLASS ltcl_alloc_key_agg DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut  TYPE REF TO zcl_alloc_key_agg.
    DATA mo_guard TYPE REF TO zcl_alloc_scale_guard.

    METHODS setup.

    METHODS fill
      IMPORTING
        iv_rows TYPE i
        iv_keys TYPE i.

    METHODS sums_of
      IMPORTING
        iv_rows          TYPE i
        iv_keys          TYPE i
      RETURNING
        VALUE(rv_visits) TYPE i.

    METHODS empty_has_no_sums FOR TESTING.
    METHODS groups_equal_keys FOR TESTING.
    METHODS keeps_distinct_keys FOR TESTING.
    METHODS find_returns_sum  FOR TESTING.
    METHODS find_missing_key  FOR TESTING.
    METHODS size_counts_rows  FOR TESTING.
    METHODS reset_clears      FOR TESTING.
    METHODS grouping_is_linear FOR TESTING.
    METHODS find_is_logarithmic FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_key_agg IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_key_agg( ).
    mo_guard = NEW zcl_alloc_scale_guard( ).
  ENDMETHOD.

  METHOD fill.
    DATA lv_i  TYPE i.
    DATA lv_ix TYPE i.

    WHILE lv_i < iv_rows.
      lv_i = lv_i + 1.

      lv_ix = lv_i MOD iv_keys.
      lv_ix = lv_ix + 1.

      mo_cut->add( iv_key      = lv_ix
                   iv_quantity = 1 ).
    ENDWHILE.
  ENDMETHOD.

  METHOD sums_of.
    DATA lt_sums TYPE zcl_alloc_key_agg=>ty_sum_tt.

    fill( iv_rows = iv_rows iv_keys = iv_keys ).
    lt_sums = mo_cut->sums( ).
    rv_visits = mo_cut->visits( ).
  ENDMETHOD.

  METHOD empty_has_no_sums.
    DATA(lt_sums) = mo_cut->sums( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_sums ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->visits( ) exp = 0 ).
  ENDMETHOD.

  METHOD groups_equal_keys.
    mo_cut->add( iv_key = 1 iv_quantity = 10 ).
    mo_cut->add( iv_key = 2 iv_quantity = 5 ).
    mo_cut->add( iv_key = 1 iv_quantity = 7 ).

    DATA(lt_sums) = mo_cut->sums( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_sums ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_sums[ 1 ]-key exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_sums[ 1 ]-quantity exp = 17 ).
    cl_abap_unit_assert=>assert_equals( act = lt_sums[ 2 ]-key exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_sums[ 2 ]-quantity exp = 5 ).
  ENDMETHOD.

  METHOD keeps_distinct_keys.
    mo_cut->add( iv_key = 3 iv_quantity = 1 ).
    mo_cut->add( iv_key = 1 iv_quantity = 2 ).
    mo_cut->add( iv_key = 2 iv_quantity = 4 ).

    DATA(lt_sums) = mo_cut->sums( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_sums ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_sums[ 1 ]-key exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_sums[ 3 ]-key exp = 3 ).
  ENDMETHOD.

  METHOD find_returns_sum.
    mo_cut->add( iv_key = 1 iv_quantity = 10 ).
    mo_cut->add( iv_key = 2 iv_quantity = 5 ).
    mo_cut->add( iv_key = 1 iv_quantity = 7 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->find( iv_key = 1 ) exp = 17 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->find( iv_key = 2 ) exp = 5 ).
  ENDMETHOD.

  METHOD find_missing_key.
    mo_cut->add( iv_key = 1 iv_quantity = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->find( iv_key = 9 ) exp = 0 ).
  ENDMETHOD.

  METHOD size_counts_rows.
    mo_cut->add( iv_key = 1 iv_quantity = 1 ).
    mo_cut->add( iv_key = 1 iv_quantity = 1 ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->size( ) exp = 2 ).
  ENDMETHOD.

  METHOD reset_clears.
    mo_cut->add( iv_key = 1 iv_quantity = 1 ).
    mo_cut->sums( ).
    mo_cut->reset( ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->size( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->visits( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_cut->sums( ) ) exp = 0 ).
  ENDMETHOD.

  METHOD grouping_is_linear.
    DATA ls_small TYPE zcl_alloc_scale_guard=>ty_measure.
    DATA ls_large TYPE zcl_alloc_scale_guard=>ty_measure.

    " Doubling the input must not more than double the work. A quadratic
    " aggregation would show four times the work and fail this test.
    ls_small-size = 1000.
    ls_small-work = sums_of( iv_rows = 1000 iv_keys = 100 ).

    mo_cut->reset( ).

    ls_large-size = 2000.
    ls_large-work = sums_of( iv_rows = 2000 iv_keys = 100 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_guard->classify( is_small = ls_small is_large = ls_large )
      exp = 'linear' ).
  ENDMETHOD.

  METHOD find_is_logarithmic.
    DATA lv_before TYPE i.
    DATA lv_after  TYPE i.
    DATA lv_ok     TYPE abap_bool.

    DATA lv_i TYPE i.
    WHILE lv_i < 1024.
      lv_i = lv_i + 1.
      mo_cut->add( iv_key = lv_i iv_quantity = 1 ).
    ENDWHILE.

    mo_cut->sums( ).
    lv_before = mo_cut->visits( ).

    mo_cut->find( iv_key = 1024 ).
    lv_after = mo_cut->visits( ).

    " log2(1024) is 10, so eleven comparisons is the most a lookup may need.
    IF lv_after - lv_before <= 11.
      lv_ok = abap_true.
    ENDIF.

    cl_abap_unit_assert=>assert_equals( act = lv_ok exp = abap_true ).
  ENDMETHOD.

ENDCLASS.
