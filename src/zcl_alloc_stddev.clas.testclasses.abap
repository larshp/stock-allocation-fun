CLASS ltcl_alloc_stddev DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_stddev.
    DATA mt_ser TYPE zcl_alloc_stddev=>ty_series_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE menge_d.

    METHODS empty_series   FOR TESTING.
    METHODS mean_reported  FOR TESTING.
    METHODS four_points    FOR TESTING.
    METHODS identical_zero FOR TESTING.
    METHODS single_value   FOR TESTING.
    METHODS two_points     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_stddev IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_stddev( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_ser.
  ENDMETHOD.

  METHOD empty_series.
    DATA(ls_result) = mo_cut->calculate( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-count exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-sd_x100 exp = 0 ).
  ENDMETHOD.

  METHOD mean_reported.
    add( iv_value = 10 ).
    add( iv_value = 20 ).
    add( iv_value = 30 ).
    add( iv_value = 40 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->mean_of( mt_ser ) exp = 25 ).
  ENDMETHOD.

  METHOD four_points.
    add( iv_value = 10 ).
    add( iv_value = 20 ).
    add( iv_value = 30 ).
    add( iv_value = 40 ).

    DATA(ls_result) = mo_cut->calculate( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-count exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-mean exp = 25 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-variance_x100 exp = 12500 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-sd_x100 exp = 1118 ).
  ENDMETHOD.

  METHOD identical_zero.
    add( iv_value = 5 ).
    add( iv_value = 5 ).
    add( iv_value = 5 ).

    DATA(ls_result) = mo_cut->calculate( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-mean exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-variance_x100 exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-sd_x100 exp = 0 ).
  ENDMETHOD.

  METHOD single_value.
    add( iv_value = 7 ).

    DATA(ls_result) = mo_cut->calculate( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-count exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-sd_x100 exp = 0 ).
  ENDMETHOD.

  METHOD two_points.
    add( iv_value = 10 ).
    add( iv_value = 20 ).

    DATA(ls_result) = mo_cut->calculate( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-mean exp = 15 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-variance_x100 exp = 2500 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-sd_x100 exp = 500 ).
  ENDMETHOD.

ENDCLASS.
