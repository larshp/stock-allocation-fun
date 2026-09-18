CLASS ltcl_alloc_key_agg_str DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut   TYPE REF TO zcl_alloc_key_agg_str.
    DATA mo_guard TYPE REF TO zcl_alloc_scale_guard.

    METHODS setup.

    METHODS fill
      IMPORTING
        iv_rows TYPE i.

    METHODS empty_has_no_sums   FOR TESTING.
    METHODS groups_equal_keys   FOR TESTING.
    METHODS keeps_first_seen_order FOR TESTING.
    METHODS distinct_keys_kept  FOR TESTING.
    METHODS sums_are_idempotent FOR TESTING.
    METHODS reset_clears        FOR TESTING.
    METHODS additive_after_read FOR TESTING.
    METHODS grouping_is_linear  FOR TESTING.
    METHODS find_returns_sum   FOR TESTING.
    METHODS find_missing_key   FOR TESTING.
    METHODS find_on_empty      FOR TESTING.
    METHODS find_after_add     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_key_agg_str IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_key_agg_str( ).
    mo_guard = NEW zcl_alloc_scale_guard( ).
  ENDMETHOD.

  METHOD fill.
    DATA lv_i TYPE i.

    WHILE lv_i < iv_rows.
      lv_i = lv_i + 1.
      mo_cut->add( iv_key      = 'K'
                   iv_quantity = 1 ).
    ENDWHILE.
  ENDMETHOD.

  METHOD empty_has_no_sums.
    DATA(lt_sums) = mo_cut->sums( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_sums ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->visits( ) exp = 0 ).
  ENDMETHOD.

  METHOD groups_equal_keys.
    mo_cut->add( iv_key = 'B' iv_quantity = 1 ).
    mo_cut->add( iv_key = 'A' iv_quantity = 2 ).
    mo_cut->add( iv_key = 'B' iv_quantity = 3 ).

    DATA(lt_sums) = mo_cut->sums( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_sums ) exp = 2 ).
  ENDMETHOD.

  METHOD keeps_first_seen_order.
    mo_cut->add( iv_key = 'B' iv_quantity = 1 ).
    mo_cut->add( iv_key = 'A' iv_quantity = 2 ).
    mo_cut->add( iv_key = 'B' iv_quantity = 3 ).

    DATA(lt_sums) = mo_cut->sums( ).

    " B was seen first, so B stays first even though A sorts before it. This is
    " what makes the class a drop-in replacement for the read/delete/append code.
    cl_abap_unit_assert=>assert_equals( act = lt_sums[ 1 ]-key exp = 'B' ).
    cl_abap_unit_assert=>assert_equals( act = lt_sums[ 1 ]-quantity exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = lt_sums[ 2 ]-key exp = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = lt_sums[ 2 ]-quantity exp = 2 ).
  ENDMETHOD.

  METHOD distinct_keys_kept.
    mo_cut->add( iv_key = 'C' iv_quantity = 1 ).
    mo_cut->add( iv_key = 'A' iv_quantity = 2 ).
    mo_cut->add( iv_key = 'B' iv_quantity = 4 ).

    DATA(lt_sums) = mo_cut->sums( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_sums ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_sums[ 1 ]-key exp = 'C' ).
    cl_abap_unit_assert=>assert_equals( act = lt_sums[ 2 ]-key exp = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = lt_sums[ 3 ]-key exp = 'B' ).
  ENDMETHOD.

  METHOD sums_are_idempotent.
    mo_cut->add( iv_key = 'A' iv_quantity = 2 ).

    DATA(lt_first) = mo_cut->sums( ).
    DATA(lt_second) = mo_cut->sums( ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_second ) exp = lines( lt_first ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_second[ 1 ]-quantity exp = 2 ).
  ENDMETHOD.

  METHOD reset_clears.
    mo_cut->add( iv_key = 'A' iv_quantity = 1 ).
    mo_cut->sums( ).
    mo_cut->reset( ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->size( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->visits( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_cut->sums( ) ) exp = 0 ).
  ENDMETHOD.

  METHOD additive_after_read.
    mo_cut->add( iv_key = 'A' iv_quantity = 2 ).
    DATA(lt_first) = mo_cut->sums( ).

    mo_cut->add( iv_key = 'A' iv_quantity = 5 ).
    DATA(lt_second) = mo_cut->sums( ).

    " Reading must not freeze the accumulator: a later add has to be included.
    cl_abap_unit_assert=>assert_equals( act = lines( lt_first ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_first[ 1 ]-quantity exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_second ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_second[ 1 ]-quantity exp = 7 ).
  ENDMETHOD.

  METHOD grouping_is_linear.
    DATA ls_small TYPE zcl_alloc_scale_guard=>ty_measure.
    DATA ls_large TYPE zcl_alloc_scale_guard=>ty_measure.
    DATA lt_sums  TYPE zcl_alloc_key_agg_str=>ty_sum_tt.

    ls_small-size = 1000.
    fill( iv_rows = 1000 ).
    lt_sums = mo_cut->sums( ).
    ls_small-work = mo_cut->visits( ).

    mo_cut->reset( ).

    ls_large-size = 2000.
    fill( iv_rows = 2000 ).
    lt_sums = mo_cut->sums( ).
    ls_large-work = mo_cut->visits( ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_guard->classify( is_small = ls_small is_large = ls_large )
      exp = 'linear' ).
  ENDMETHOD.

  METHOD find_returns_sum.
    mo_cut->add( iv_key = 'B' iv_quantity = 10 ).
    mo_cut->add( iv_key = 'A' iv_quantity = 5 ).
    mo_cut->add( iv_key = 'B' iv_quantity = 7 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->find( iv_key = 'B' ) exp = 17 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->find( iv_key = 'A' ) exp = 5 ).
  ENDMETHOD.

  METHOD find_missing_key.
    mo_cut->add( iv_key = 'A' iv_quantity = 1 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->find( iv_key = 'Z' ) exp = 0 ).
  ENDMETHOD.

  METHOD find_on_empty.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->find( iv_key = 'A' ) exp = 0 ).
  ENDMETHOD.

  METHOD find_after_add.
    mo_cut->add( iv_key = 'A' iv_quantity = 2 ).
    mo_cut->find( iv_key = 'A' ).

    " A lookup must not freeze the accumulator either.
    mo_cut->add( iv_key = 'A' iv_quantity = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->find( iv_key = 'A' ) exp = 5 ).
  ENDMETHOD.

ENDCLASS.
