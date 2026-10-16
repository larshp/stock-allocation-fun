CLASS ltcl_alloc_gap_check DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_gap_check.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS no_gaps          FOR TESTING.
    METHODS finds_single_gap FOR TESTING.
    METHODS finds_two_gaps   FOR TESTING.
    METHODS unsorted_input   FOR TESTING.
    METHODS empty_no_gaps    FOR TESTING.
    METHODS single_no_gaps   FOR TESTING.
    METHODS duplicates_ok    FOR TESTING.
    METHODS missing_count    FOR TESTING.

    DATA mt_numbers TYPE zcl_alloc_gap_check=>ty_numbers_tt.

ENDCLASS.


CLASS ltcl_alloc_gap_check IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_gap_check( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_number TYPE zcl_alloc_gap_check=>ty_number.

    ls_number-value = iv_value.
    APPEND ls_number TO mt_numbers.
  ENDMETHOD.

  METHOD no_gaps.
    DATA lt_gaps TYPE zcl_alloc_gap_check=>ty_gap_tt.

    add( 1 ).
    add( 2 ).
    add( 3 ).

    lt_gaps = mo_cut->find( mt_numbers ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_gaps ) exp = 0 ).
  ENDMETHOD.

  METHOD finds_single_gap.
    DATA lt_gaps TYPE zcl_alloc_gap_check=>ty_gap_tt.

    add( 1 ).
    add( 2 ).
    add( 5 ).

    lt_gaps = mo_cut->find( mt_numbers ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_gaps ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_gaps[ 1 ]-after exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_gaps[ 1 ]-before exp = 5 ).
  ENDMETHOD.

  METHOD finds_two_gaps.
    DATA lt_gaps TYPE zcl_alloc_gap_check=>ty_gap_tt.

    add( 1 ).
    add( 4 ).
    add( 10 ).

    lt_gaps = mo_cut->find( mt_numbers ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_gaps ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_gaps[ 2 ]-after exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = lt_gaps[ 2 ]-before exp = 10 ).
  ENDMETHOD.

  METHOD unsorted_input.
    DATA lt_gaps TYPE zcl_alloc_gap_check=>ty_gap_tt.

    add( 5 ).
    add( 1 ).
    add( 3 ).

    lt_gaps = mo_cut->find( mt_numbers ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_gaps ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_gaps[ 1 ]-after exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_gaps[ 1 ]-before exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_gaps[ 2 ]-after exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_gaps[ 2 ]-before exp = 5 ).
  ENDMETHOD.

  METHOD empty_no_gaps.
    DATA lt_gaps TYPE zcl_alloc_gap_check=>ty_gap_tt.

    lt_gaps = mo_cut->find( mt_numbers ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_gaps ) exp = 0 ).
  ENDMETHOD.

  METHOD single_no_gaps.
    DATA lt_gaps TYPE zcl_alloc_gap_check=>ty_gap_tt.

    add( 7 ).

    lt_gaps = mo_cut->find( mt_numbers ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_gaps ) exp = 0 ).
  ENDMETHOD.

  METHOD duplicates_ok.
    DATA lt_gaps TYPE zcl_alloc_gap_check=>ty_gap_tt.

    add( 1 ).
    add( 1 ).
    add( 2 ).

    lt_gaps = mo_cut->find( mt_numbers ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_gaps ) exp = 0 ).
  ENDMETHOD.

  METHOD missing_count.
    DATA lt_gaps TYPE zcl_alloc_gap_check=>ty_gap_tt.

    add( 1 ).
    add( 6 ).

    lt_gaps = mo_cut->find( mt_numbers ).

    cl_abap_unit_assert=>assert_equals( act = lt_gaps[ 1 ]-missing exp = 4 ).
  ENDMETHOD.

ENDCLASS.
