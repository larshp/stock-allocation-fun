CLASS ltcl_alloc_sto_proposal DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_sto_proposal.
    DATA mt_loc TYPE zcl_alloc_sto_proposal=>ty_location_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_loc TYPE string
        iv_stk TYPE i
        iv_min TYPE i
        iv_max TYPE i.

    METHODS moves_surplus  FOR TESTING.
    METHODS no_surplus     FOR TESTING.
    METHODS splits_surplus FOR TESTING.
    METHODS balanced_noop  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_sto_proposal IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_sto_proposal( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_loc TYPE zcl_alloc_sto_proposal=>ty_location.

    ls_loc-location = iv_loc.
    ls_loc-stock = iv_stk.
    ls_loc-min_level = iv_min.
    ls_loc-max_level = iv_max.
    APPEND ls_loc TO mt_loc.
  ENDMETHOD.

  METHOD moves_surplus.
    DATA lt_prop TYPE zcl_alloc_sto_proposal=>ty_proposal_tt.

    add( iv_loc = 'A' iv_stk = 120 iv_min = 20 iv_max = 100 ).
    add( iv_loc = 'B' iv_stk = 10 iv_min = 50 iv_max = 100 ).

    lt_prop = mo_cut->propose( mt_loc ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_prop ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_prop[ 1 ]-from_location exp = 'A' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_prop[ 1 ]-to_location exp = 'B' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_prop[ 1 ]-quantity exp = 20 ).
  ENDMETHOD.

  METHOD no_surplus.
    DATA lt_prop TYPE zcl_alloc_sto_proposal=>ty_proposal_tt.

    add( iv_loc = 'A' iv_stk = 50 iv_min = 20 iv_max = 100 ).
    add( iv_loc = 'B' iv_stk = 10 iv_min = 50 iv_max = 100 ).

    lt_prop = mo_cut->propose( mt_loc ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_prop ) exp = 0 ).
  ENDMETHOD.

  METHOD splits_surplus.
    DATA lt_prop TYPE zcl_alloc_sto_proposal=>ty_proposal_tt.

    add( iv_loc = 'A' iv_stk = 110 iv_min = 20 iv_max = 100 ).
    add( iv_loc = 'B' iv_stk = 45 iv_min = 50 iv_max = 100 ).
    add( iv_loc = 'C' iv_stk = 45 iv_min = 50 iv_max = 100 ).

    lt_prop = mo_cut->propose( mt_loc ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_prop ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_prop[ 1 ]-quantity exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_prop[ 2 ]-to_location exp = 'C' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_prop[ 2 ]-quantity exp = 5 ).
  ENDMETHOD.

  METHOD balanced_noop.
    DATA lt_prop TYPE zcl_alloc_sto_proposal=>ty_proposal_tt.

    add( iv_loc = 'A' iv_stk = 50 iv_min = 20 iv_max = 100 ).

    lt_prop = mo_cut->propose( mt_loc ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_prop ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
