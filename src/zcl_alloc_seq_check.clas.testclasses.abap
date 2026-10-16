CLASS ltcl_alloc_seq_check DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut     TYPE REF TO zcl_alloc_seq_check.
    DATA mt_numbers TYPE zcl_alloc_gap_check=>ty_numbers_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS clean_sequence    FOR TESTING.
    METHODS unordered_flag    FOR TESTING.
    METHODS duplicate_flag    FOR TESTING.
    METHODS gap_counting      FOR TESTING.
    METHODS empty_sequence    FOR TESTING.
    METHODS single_value      FOR TESTING.
    METHODS first_and_last    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_seq_check IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_seq_check( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_number TYPE zcl_alloc_gap_check=>ty_number.

    ls_number-value = iv_value.
    APPEND ls_number TO mt_numbers.
  ENDMETHOD.

  METHOD clean_sequence.
    add( 1 ).
    add( 2 ).
    add( 3 ).

    DATA(ls_result) = mo_cut->check( mt_numbers ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-is_ordered exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-has_dupes exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-gap_count exp = 0 ).
  ENDMETHOD.

  METHOD unordered_flag.
    add( 3 ).
    add( 1 ).
    add( 2 ).

    DATA(ls_result) = mo_cut->check( mt_numbers ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-is_ordered exp = abap_false ).
  ENDMETHOD.

  METHOD duplicate_flag.
    add( 1 ).
    add( 1 ).
    add( 2 ).

    DATA(ls_result) = mo_cut->check( mt_numbers ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-has_dupes exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-is_ordered exp = abap_false ).
  ENDMETHOD.

  METHOD gap_counting.
    add( 1 ).
    add( 3 ).
    add( 7 ).

    DATA(ls_result) = mo_cut->check( mt_numbers ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-gap_count exp = 2 ).
  ENDMETHOD.

  METHOD empty_sequence.
    DATA(ls_result) = mo_cut->check( mt_numbers ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-is_ordered exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-first_value exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-gap_count exp = 0 ).
  ENDMETHOD.

  METHOD single_value.
    add( 9 ).

    DATA(ls_result) = mo_cut->check( mt_numbers ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-is_ordered exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-first_value exp = 9 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-last_value exp = 9 ).
  ENDMETHOD.

  METHOD first_and_last.
    add( 4 ).
    add( 5 ).
    add( 8 ).

    DATA(ls_result) = mo_cut->check( mt_numbers ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-first_value exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-last_value exp = 8 ).
  ENDMETHOD.

ENDCLASS.
