CLASS ltcl_alloc_scale_guard DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_scale_guard.

    METHODS setup.

    METHODS measure
      IMPORTING
        iv_size           TYPE i
        iv_work           TYPE i
      RETURNING
        VALUE(rs_measure) TYPE zcl_alloc_scale_guard=>ty_measure.

    METHODS ratio_of        FOR TESTING.
    METHODS ratio_guarded   FOR TESTING.
    METHODS linear_growth   FOR TESTING.
    METHODS slack_is_near   FOR TESTING.
    METHODS quadratic_growth FOR TESTING.
    METHODS zero_size       FOR TESTING.
    METHODS zero_work       FOR TESTING.
    METHODS shrunken_input  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_scale_guard IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_scale_guard( ).
  ENDMETHOD.

  METHOD measure.
    rs_measure-size = iv_size.
    rs_measure-work = iv_work.
  ENDMETHOD.

  METHOD ratio_of.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->ratio_x100( iv_small = 100 iv_large = 200 ) exp = 200 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->ratio_x100( iv_small = 4 iv_large = 5 ) exp = 125 ).
  ENDMETHOD.

  METHOD ratio_guarded.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->ratio_x100( iv_small = 0 iv_large = 5 ) exp = 0 ).
  ENDMETHOD.

  METHOD linear_growth.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( is_small = measure( iv_size = 100 iv_work = 100 )
                              is_large = measure( iv_size = 200 iv_work = 200 ) )
      exp = 'linear' ).
  ENDMETHOD.

  METHOD slack_is_near.
    " Work grew half again as fast as the input: still not a complexity change.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( is_small = measure( iv_size = 100 iv_work = 100 )
                              is_large = measure( iv_size = 200 iv_work = 300 ) )
      exp = 'near_linear' ).
  ENDMETHOD.

  METHOD quadratic_growth.
    " Four times the work for twice the input is the quadratic signature.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( is_small = measure( iv_size = 100 iv_work = 100 )
                              is_large = measure( iv_size = 200 iv_work = 40000 ) )
      exp = 'quadratic' ).
  ENDMETHOD.

  METHOD zero_size.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( is_small = measure( iv_size = 0 iv_work = 0 )
                              is_large = measure( iv_size = 200 iv_work = 200 ) )
      exp = 'unknown' ).
  ENDMETHOD.

  METHOD zero_work.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( is_small = measure( iv_size = 100 iv_work = 0 )
                              is_large = measure( iv_size = 200 iv_work = 200 ) )
      exp = 'unknown' ).
  ENDMETHOD.

  METHOD shrunken_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( is_small = measure( iv_size = 100 iv_work = 100 )
                              is_large = measure( iv_size = 0 iv_work = 0 ) )
      exp = 'unknown' ).
  ENDMETHOD.

ENDCLASS.
