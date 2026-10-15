CLASS ltcl_alloc_return_rate DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_rate.

    METHODS setup.

    METHODS rate_per_thousand FOR TESTING.
    METHODS rate_percent      FOR TESTING.
    METHODS guards_zero       FOR TESTING.
    METHODS target_test       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_rate IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_rate( ).
  ENDMETHOD.

  METHOD rate_per_thousand.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rate( iv_returned = 25 iv_shipped = 1000 )
      exp = 25 ).
  ENDMETHOD.

  METHOD rate_percent.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rate_percent( iv_returned = 25 iv_shipped = 1000 )
      exp = 2 ).
  ENDMETHOD.

  METHOD guards_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rate( iv_returned = 25 iv_shipped = 0 )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rate_percent( iv_returned = 25 iv_shipped = 0 )
      exp = 0 ).
  ENDMETHOD.

  METHOD target_test.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->above_target( iv_percent = 3 iv_target = 2 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->above_target( iv_percent = 2 iv_target = 2 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
