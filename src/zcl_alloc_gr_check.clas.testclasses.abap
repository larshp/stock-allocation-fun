CLASS ltcl_alloc_gr_check DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_gr_check.

    METHODS setup.

    METHODS exact_delivery FOR TESTING.
    METHODS over_delivery  FOR TESTING.
    METHODS under_delivery FOR TESTING.
    METHODS percent_read   FOR TESTING.
    METHODS percent_zero   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_gr_check IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_gr_check( ).
  ENDMETHOD.

  METHOD exact_delivery.
    DATA ls_res TYPE zcl_alloc_gr_check=>ty_result.

    ls_res = mo_cut->check( iv_ordered = 100 iv_delivered = 100 ).

    cl_abap_unit_assert=>assert_equals( act = ls_res-diff exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_res-status exp = 'OK' ).
  ENDMETHOD.

  METHOD over_delivery.
    DATA ls_res TYPE zcl_alloc_gr_check=>ty_result.

    ls_res = mo_cut->check( iv_ordered = 100 iv_delivered = 110 ).

    cl_abap_unit_assert=>assert_equals( act = ls_res-diff exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = ls_res-status exp = 'OVER' ).
  ENDMETHOD.

  METHOD under_delivery.
    DATA ls_res TYPE zcl_alloc_gr_check=>ty_result.

    ls_res = mo_cut->check( iv_ordered = 100 iv_delivered = 90 ).

    cl_abap_unit_assert=>assert_equals( act = ls_res-diff exp = -10 ).
    cl_abap_unit_assert=>assert_equals( act = ls_res-status exp = 'UNDER' ).
  ENDMETHOD.

  METHOD percent_read.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->received_percent( iv_ordered = 100 iv_delivered = 90 )
      exp = 90 ).
  ENDMETHOD.

  METHOD percent_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->received_percent( iv_ordered = 0 iv_delivered = 90 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
