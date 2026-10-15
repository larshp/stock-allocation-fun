CLASS ltcl_alloc_area_capacity DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_area_capacity.

    METHODS setup.

    METHODS can_add_fits   FOR TESTING.
    METHODS cannot_add     FOR TESTING.
    METHODS exact_fit      FOR TESTING.
    METHODS zero_capacity  FOR TESTING.
    METHODS remaining_read FOR TESTING.
    METHODS remaining_zero FOR TESTING.
    METHODS overflow_read  FOR TESTING.
    METHODS overflow_none  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_area_capacity IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_area_capacity( ).
  ENDMETHOD.

  METHOD can_add_fits.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->can_add( iv_used = 40 iv_capacity = 100 iv_add = 30 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD cannot_add.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->can_add( iv_used = 40 iv_capacity = 100 iv_add = 61 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD exact_fit.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->can_add( iv_used = 40 iv_capacity = 100 iv_add = 60 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD zero_capacity.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->can_add( iv_used = 0 iv_capacity = 0 iv_add = 10 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD remaining_read.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->remaining_after( iv_used = 40 iv_capacity = 100
                                     iv_add = 30 )
      exp = 30 ).
  ENDMETHOD.

  METHOD remaining_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->remaining_after( iv_used = 40 iv_capacity = 100
                                     iv_add = 90 )
      exp = 0 ).
  ENDMETHOD.

  METHOD overflow_read.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->would_overflow( iv_used = 40 iv_capacity = 100
                                    iv_add = 90 )
      exp = 30 ).
  ENDMETHOD.

  METHOD overflow_none.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->would_overflow( iv_used = 40 iv_capacity = 100
                                    iv_add = 10 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
