CLASS ltcl_alloc_count_adjust DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_count_adjust.

    METHODS setup.

    METHODS gain_proposal FOR TESTING.
    METHODS loss_proposal FOR TESTING.
    METHODS none_proposal FOR TESTING.
    METHODS posting_sign  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_count_adjust IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_count_adjust( ).
  ENDMETHOD.

  METHOD gain_proposal.
    DATA ls_res TYPE zcl_alloc_count_adjust=>ty_proposal.

    ls_res = mo_cut->propose( iv_book = 100 iv_counted = 110 ).

    cl_abap_unit_assert=>assert_equals( act = ls_res-adjust_qty exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = ls_res-reason exp = 'GAIN' ).
  ENDMETHOD.

  METHOD loss_proposal.
    DATA ls_res TYPE zcl_alloc_count_adjust=>ty_proposal.

    ls_res = mo_cut->propose( iv_book = 100 iv_counted = 90 ).

    cl_abap_unit_assert=>assert_equals( act = ls_res-adjust_qty exp = -10 ).
    cl_abap_unit_assert=>assert_equals( act = ls_res-reason exp = 'LOSS' ).
  ENDMETHOD.

  METHOD none_proposal.
    DATA ls_res TYPE zcl_alloc_count_adjust=>ty_proposal.

    ls_res = mo_cut->propose( iv_book = 100 iv_counted = 100 ).

    cl_abap_unit_assert=>assert_equals( act = ls_res-adjust_qty exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_res-reason exp = 'NONE' ).
  ENDMETHOD.

  METHOD posting_sign.
    DATA ls_res TYPE zcl_alloc_count_adjust=>ty_proposal.

    ls_res = mo_cut->propose( iv_book = 100 iv_counted = 90 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->posting_qty( ls_res ) exp = 10 ).
  ENDMETHOD.

ENDCLASS.
