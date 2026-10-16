CLASS ltcl_alloc_demand_class DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_demand_class.
    DATA mt_ser TYPE zcl_alloc_demand_class=>ty_series_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE menge_d.

    METHODS empty_is_unknown  FOR TESTING.
    METHODS no_demand         FOR TESTING.
    METHODS smooth_demand     FOR TESTING.
    METHODS intermittent      FOR TESTING.
    METHODS erratic_demand    FOR TESTING.
    METHODS lumpy_demand      FOR TESTING.
    METHODS reports_measures  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_demand_class IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_demand_class( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_ser.
  ENDMETHOD.

  METHOD empty_is_unknown.
    DATA(ls_result) = mo_cut->classify( mt_ser ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-demand_class exp = 'unknown' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-periods exp = 0 ).
  ENDMETHOD.

  METHOD no_demand.
    add( iv_value = 0 ).
    add( iv_value = 0 ).

    DATA(ls_result) = mo_cut->classify( mt_ser ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-demand_class exp = 'no demand' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-non_zero exp = 0 ).
  ENDMETHOD.

  METHOD smooth_demand.
    add( iv_value = 10 ).
    add( iv_value = 10 ).
    add( iv_value = 10 ).
    add( iv_value = 10 ).
    add( iv_value = 10 ).

    DATA(ls_result) = mo_cut->classify( mt_ser ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-demand_class exp = 'smooth' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-adi_x100 exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-cv2_x100 exp = 0 ).
  ENDMETHOD.

  METHOD intermittent.
    add( iv_value = 0 ).
    add( iv_value = 0 ).
    add( iv_value = 10 ).
    add( iv_value = 0 ).

    DATA(ls_result) = mo_cut->classify( mt_ser ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-demand_class exp = 'intermittent' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-adi_x100 exp = 400 ).
  ENDMETHOD.

  METHOD erratic_demand.
    add( iv_value = 10 ).
    add( iv_value = 90 ).

    DATA(ls_result) = mo_cut->classify( mt_ser ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-demand_class exp = 'erratic' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-adi_x100 exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-cv2_x100 exp = 6400 ).
  ENDMETHOD.

  METHOD lumpy_demand.
    add( iv_value = 0 ).
    add( iv_value = 0 ).
    add( iv_value = 10 ).
    add( iv_value = 90 ).

    DATA(ls_result) = mo_cut->classify( mt_ser ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-demand_class exp = 'lumpy' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-adi_x100 exp = 200 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-cv2_x100 exp = 6400 ).
  ENDMETHOD.

  METHOD reports_measures.
    add( iv_value = 10 ).
    add( iv_value = 30 ).

    DATA(ls_result) = mo_cut->classify( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-periods exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-non_zero exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-mean exp = 20 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-cv2_x100 exp = 2500 ).
  ENDMETHOD.

ENDCLASS.
