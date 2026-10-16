CLASS ltcl_alloc_accept_decision DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_accept_decision.

    METHODS setup.

    METHODS accepts_zero     FOR TESTING.
    METHODS accepts_at_limit FOR TESTING.
    METHODS rejects_at_limit FOR TESTING.
    METHODS continues_between FOR TESTING.
    METHODS bad_limits       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_accept_decision IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_accept_decision( ).
  ENDMETHOD.

  METHOD accepts_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->decide( iv_defects = 0 iv_accept_no = 0
                            iv_reject_no = 1 )
      exp = 'ACCEPT' ).
  ENDMETHOD.

  METHOD accepts_at_limit.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->decide( iv_defects = 2 iv_accept_no = 2
                            iv_reject_no = 5 )
      exp = 'ACCEPT' ).
  ENDMETHOD.

  METHOD rejects_at_limit.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->decide( iv_defects = 5 iv_accept_no = 2
                            iv_reject_no = 5 )
      exp = 'REJECT' ).
  ENDMETHOD.

  METHOD continues_between.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->decide( iv_defects = 3 iv_accept_no = 2
                            iv_reject_no = 5 )
      exp = 'CONTINUE' ).
  ENDMETHOD.

  METHOD bad_limits.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->decide( iv_defects = 3 iv_accept_no = 5
                            iv_reject_no = 5 )
      exp = '' ).
  ENDMETHOD.

ENDCLASS.
