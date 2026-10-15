CLASS ltcl_alloc_key_map DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut   TYPE REF TO zcl_alloc_key_map.
    DATA mo_guard TYPE REF TO zcl_alloc_scale_guard.

    METHODS setup.

    METHODS fill
      IMPORTING
        iv_keys TYPE i.

    METHODS empty_map           FOR TESTING.
    METHODS put_then_get        FOR TESTING.
    METHODS put_overwrites      FOR TESTING.
    METHODS add_accumulates     FOR TESTING.
    METHODS add_creates_key     FOR TESTING.
    METHODS has_present         FOR TESTING.
    METHODS has_missing         FOR TESTING.
    METHODS remove_deletes      FOR TESTING.
    METHODS remove_missing_noop FOR TESTING.
    METHODS size_counts_keys    FOR TESTING.
    METHODS first_seen_order    FOR TESTING.
    METHODS update_moves_to_end FOR TESTING.
    METHODS visits_count_ops    FOR TESTING.
    METHODS key_ops_are_linear  FOR TESTING.
    METHODS reset_clears        FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_key_map IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_key_map( ).
    mo_guard = NEW zcl_alloc_scale_guard( ).
  ENDMETHOD.

  METHOD fill.
    DATA lv_i TYPE i.

    WHILE lv_i < iv_keys.
      lv_i = lv_i + 1.
      mo_cut->add( iv_key   = 'K'
                   iv_delta = 1 ).
      mo_cut->get( iv_key = 'K' ).
    ENDWHILE.
  ENDMETHOD.

  METHOD empty_map.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->size( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get( iv_key = 'A' ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->has( iv_key = 'A' ) exp = abap_false ).
  ENDMETHOD.

  METHOD put_then_get.
    mo_cut->put( iv_key = 'A' iv_value = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get( iv_key = 'A' ) exp = 5 ).
  ENDMETHOD.

  METHOD put_overwrites.
    mo_cut->put( iv_key = 'A' iv_value = 5 ).
    mo_cut->put( iv_key = 'A' iv_value = 9 ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->size( ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get( iv_key = 'A' ) exp = 9 ).
  ENDMETHOD.

  METHOD add_accumulates.
    mo_cut->add( iv_key = 'A' iv_delta = 5 ).
    mo_cut->add( iv_key = 'A' iv_delta = 3 ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->size( ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get( iv_key = 'A' ) exp = 8 ).
  ENDMETHOD.

  METHOD add_creates_key.
    mo_cut->add( iv_key = 'B' iv_delta = 4 ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->size( ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->has( iv_key = 'B' ) exp = abap_true ).
  ENDMETHOD.

  METHOD has_present.
    mo_cut->put( iv_key = 'A' iv_value = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->has( iv_key = 'A' ) exp = abap_true ).
  ENDMETHOD.

  METHOD has_missing.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->has( iv_key = 'Z' ) exp = abap_false ).
  ENDMETHOD.

  METHOD remove_deletes.
    mo_cut->put( iv_key = 'A' iv_value = 1 ).
    mo_cut->put( iv_key = 'B' iv_value = 2 ).
    mo_cut->remove( iv_key = 'A' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->size( ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->has( iv_key = 'A' ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->has( iv_key = 'B' ) exp = abap_true ).
  ENDMETHOD.

  METHOD remove_missing_noop.
    mo_cut->put( iv_key = 'A' iv_value = 1 ).
    mo_cut->remove( iv_key = 'Z' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->size( ) exp = 1 ).
  ENDMETHOD.

  METHOD size_counts_keys.
    mo_cut->put( iv_key = 'A' iv_value = 1 ).
    mo_cut->put( iv_key = 'B' iv_value = 2 ).
    mo_cut->put( iv_key = 'A' iv_value = 3 ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->size( ) exp = 2 ).
  ENDMETHOD.

  METHOD first_seen_order.
    DATA lt_entries TYPE zcl_alloc_key_map=>ty_entry_tt.
    DATA lv_index   TYPE i.

    mo_cut->put( iv_key = 'B' iv_value = 1 ).
    mo_cut->put( iv_key = 'A' iv_value = 2 ).
    mo_cut->put( iv_key = 'B' iv_value = 3 ).

    lt_entries = mo_cut->entries( ).

    LOOP AT lt_entries INTO DATA(ls_entry).
      lv_index = lv_index + 1.
      IF lv_index = 1.
        cl_abap_unit_assert=>assert_equals(
          act = ls_entry-entry_key exp = 'B' ).
        cl_abap_unit_assert=>assert_equals( act = ls_entry-value exp = 3 ).
      ELSEIF lv_index = 2.
        cl_abap_unit_assert=>assert_equals(
          act = ls_entry-entry_key exp = 'A' ).
      ENDIF.
    ENDLOOP.

    cl_abap_unit_assert=>assert_equals( act = lines( lt_entries ) exp = 2 ).
  ENDMETHOD.

  METHOD update_moves_to_end.
    DATA lt_entries TYPE zcl_alloc_key_map=>ty_entry_tt.

    " add( ) is the companion of the read/delete/append bump, so re-adding a key
    " moves it to the end, exactly like the code it replaces.
    mo_cut->add( iv_key = 'A' iv_delta = 1 ).
    mo_cut->add( iv_key = 'B' iv_delta = 1 ).
    mo_cut->add( iv_key = 'A' iv_delta = 1 ).

    lt_entries = mo_cut->entries( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_entries ) exp = 2 ).

    LOOP AT lt_entries INTO DATA(ls_entry).
      IF sy-tabix = 1.
        cl_abap_unit_assert=>assert_equals(
          act = ls_entry-entry_key exp = 'B' ).
      ELSE.
        cl_abap_unit_assert=>assert_equals(
          act = ls_entry-entry_key exp = 'A' ).
        cl_abap_unit_assert=>assert_equals( act = ls_entry-value exp = 2 ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD visits_count_ops.
    mo_cut->put( iv_key = 'A' iv_value = 1 ).
    mo_cut->get( iv_key = 'A' ).
    mo_cut->has( iv_key = 'A' ).
    mo_cut->remove( iv_key = 'A' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->visits( ) exp = 4 ).
  ENDMETHOD.

  METHOD key_ops_are_linear.
    DATA ls_small TYPE zcl_alloc_scale_guard=>ty_measure.
    DATA ls_large TYPE zcl_alloc_scale_guard=>ty_measure.

    " Each add/get pair touches at most two keys, so doubling the number of
    " operations doubles the work instead of quadrupling it. The count is the
    " evidence, because the runtime has no microsecond clock.
    ls_small-size = 1000.
    fill( iv_keys = 1000 ).
    ls_small-work = mo_cut->visits( ).

    mo_cut->reset( ).

    ls_large-size = 2000.
    fill( iv_keys = 2000 ).
    ls_large-work = mo_cut->visits( ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_guard->classify( is_small = ls_small is_large = ls_large )
      exp = 'linear' ).
  ENDMETHOD.

  METHOD reset_clears.
    mo_cut->put( iv_key = 'A' iv_value = 1 ).
    mo_cut->reset( ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->size( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->visits( ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
