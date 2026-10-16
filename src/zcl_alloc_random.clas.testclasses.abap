CLASS ltcl_alloc_random DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_random.

    METHODS setup.

    METHODS same_of
      IMPORTING
        iv_left        TYPE i
        iv_right       TYPE i
      RETURNING
        VALUE(rv_same) TYPE abap_bool.

    METHODS seeds_state       FOR TESTING.
    METHODS same_seed_repeats FOR TESTING.
    METHODS differs_by_seed   FOR TESTING.
    METHODS zero_seed_works   FOR TESTING.
    METHODS between_range     FOR TESTING.
    METHODS between_equal     FOR TESTING.
    METHODS advances_state    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_random IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_random( iv_seed = 4711 ).
  ENDMETHOD.

  METHOD same_of.
    IF iv_left = iv_right.
      rv_same = abap_true.
    ELSE.
      rv_same = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD seeds_state.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->state( ) exp = 4711 ).
  ENDMETHOD.

  METHOD same_seed_repeats.
    DATA lv_first  TYPE i.
    DATA lv_second TYPE i.

    lv_first = mo_cut->next( ).

    mo_cut->reset( iv_seed = 4711 ).
    lv_second = mo_cut->next( ).

    cl_abap_unit_assert=>assert_equals( act = lv_second exp = lv_first ).
  ENDMETHOD.

  METHOD differs_by_seed.
    DATA lv_first  TYPE i.
    DATA lv_second TYPE i.

    lv_first = mo_cut->next( ).

    mo_cut->reset( iv_seed = 99 ).
    lv_second = mo_cut->next( ).

    cl_abap_unit_assert=>assert_equals(
      act = same_of( iv_left = lv_second iv_right = lv_first )
      exp = abap_false ).
  ENDMETHOD.

  METHOD zero_seed_works.
    DATA lv_value TYPE i.
    DATA lv_next  TYPE i.

    mo_cut->reset( iv_seed = 0 ).
    lv_value = mo_cut->next( ).
    lv_next = mo_cut->next( ).

    cl_abap_unit_assert=>assert_equals(
      act = same_of( iv_left = lv_next iv_right = lv_value )
      exp = abap_false ).
  ENDMETHOD.

  METHOD between_range.
    DATA lv_value TYPE i.
    DATA lv_ok    TYPE abap_bool.

    DO 50 TIMES.
      lv_value = mo_cut->between( iv_from = 10 iv_to = 20 ).

      IF lv_value >= 10 AND lv_value <= 20.
        lv_ok = abap_true.
      ELSE.
        lv_ok = abap_false.
      ENDIF.

      cl_abap_unit_assert=>assert_equals( act = lv_ok exp = abap_true ).
    ENDDO.
  ENDMETHOD.

  METHOD between_equal.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->between( iv_from = 7 iv_to = 7 ) exp = 7 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->between( iv_from = 9 iv_to = 3 ) exp = 9 ).
  ENDMETHOD.

  METHOD advances_state.
    DATA lv_before TYPE i.
    DATA lv_after  TYPE i.

    lv_before = mo_cut->state( ).
    mo_cut->next( ).
    lv_after = mo_cut->state( ).

    cl_abap_unit_assert=>assert_equals(
      act = same_of( iv_left = lv_after iv_right = lv_before )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
