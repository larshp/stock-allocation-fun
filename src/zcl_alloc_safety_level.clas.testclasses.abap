CLASS ltcl_alloc_safety_level DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_safety_level.

    METHODS setup.

    METHODS make_input
      IMPORTING
        iv_avg          TYPE menge_d
        iv_sig          TYPE menge_d
        iv_lead         TYPE i
        iv_z            TYPE i
      RETURNING
        VALUE(rs_input) TYPE zcl_alloc_safety_level=>ty_input.

    METHODS root_of_perfect_squares FOR TESTING.
    METHODS root_is_truncated      FOR TESTING.
    METHODS root_of_zero           FOR TESTING.
    METHODS root_of_negative       FOR TESTING.
    METHODS scales_with_variation  FOR TESTING.
    METHODS scales_with_lead_time  FOR TESTING.
    METHODS zero_factor_is_zero    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_safety_level IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_safety_level( ).
  ENDMETHOD.

  METHOD make_input.
    rs_input-avg_demand = iv_avg.
    rs_input-sigma = iv_sig.
    rs_input-lead_time = iv_lead.
    rs_input-z_x100 = iv_z.
  ENDMETHOD.

  METHOD root_of_perfect_squares.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->sqrt_of( 1 ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->sqrt_of( 4 ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->sqrt_of( 9 ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->sqrt_of( 100 ) exp = 10 ).
  ENDMETHOD.

  METHOD root_is_truncated.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->sqrt_of( 8 ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->sqrt_of( 15 ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->sqrt_of( 2 ) exp = 1 ).
  ENDMETHOD.

  METHOD root_of_zero.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->sqrt_of( 0 ) exp = 0 ).
  ENDMETHOD.

  METHOD root_of_negative.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->sqrt_of( -5 ) exp = 0 ).
  ENDMETHOD.

  METHOD scales_with_variation.
    DATA(ls_input) = make_input( iv_avg = 100 iv_sig = 10
                                 iv_lead = 4 iv_z = 165 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( ls_input ) exp = 33 ).
  ENDMETHOD.

  METHOD scales_with_lead_time.
    DATA(ls_input) = make_input( iv_avg = 100 iv_sig = 10
                                 iv_lead = 9 iv_z = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( ls_input ) exp = 30 ).
  ENDMETHOD.

  METHOD zero_factor_is_zero.
    DATA(ls_input) = make_input( iv_avg = 100 iv_sig = 10
                                 iv_lead = 4 iv_z = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( ls_input ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
