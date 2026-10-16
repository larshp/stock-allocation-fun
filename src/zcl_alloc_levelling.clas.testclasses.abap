CLASS ltcl_alloc_levelling DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_levelling.
    DATA mt_dem TYPE zcl_alloc_levelling=>ty_series_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE menge_d.

    METHODS empty_series     FOR TESTING.
    METHODS no_levelling     FOR TESTING.
    METHODS shifts_excess    FOR TESTING.
    METHODS reports_rest     FOR TESTING.
    METHODS zero_capacity    FOR TESTING.
    METHODS keeps_total      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_levelling IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_levelling( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_dem.
  ENDMETHOD.

  METHOD empty_series.
    DATA(ls_result) = mo_cut->level( it_demand   = mt_dem
                                     iv_capacity = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-periods ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-overloaded exp = abap_false ).
  ENDMETHOD.

  METHOD no_levelling.
    add( iv_value = 5 ).
    add( iv_value = 5 ).
    add( iv_value = 5 ).

    DATA(ls_result) = mo_cut->level( it_demand   = mt_dem
                                     iv_capacity = 10 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-periods[ 1 ] exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-periods[ 3 ] exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-rest exp = 0 ).
  ENDMETHOD.

  METHOD shifts_excess.
    add( iv_value = 5 ).
    add( iv_value = 15 ).
    add( iv_value = 5 ).

    DATA(ls_result) = mo_cut->level( it_demand   = mt_dem
                                     iv_capacity = 10 ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-periods ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-periods[ 1 ] exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-periods[ 2 ] exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-periods[ 3 ] exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-overloaded exp = abap_false ).
  ENDMETHOD.

  METHOD reports_rest.
    add( iv_value = 5 ).
    add( iv_value = 25 ).

    DATA(ls_result) = mo_cut->level( it_demand   = mt_dem
                                     iv_capacity = 10 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-periods[ 2 ] exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-rest exp = 15 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-overloaded exp = abap_true ).
  ENDMETHOD.

  METHOD zero_capacity.
    add( iv_value = 5 ).
    add( iv_value = 25 ).

    DATA(ls_result) = mo_cut->level( it_demand   = mt_dem
                                     iv_capacity = 0 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-periods[ 2 ] exp = 25 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-rest exp = 0 ).
  ENDMETHOD.

  METHOD keeps_total.
    DATA lv_sum TYPE menge_d.

    add( iv_value = 5 ).
    add( iv_value = 15 ).
    add( iv_value = 5 ).

    DATA(ls_result) = mo_cut->level( it_demand   = mt_dem
                                     iv_capacity = 10 ).

    LOOP AT ls_result-periods INTO DATA(lv_value).
      lv_sum = lv_sum + lv_value.
    ENDLOOP.

    lv_sum = lv_sum + ls_result-rest.

    cl_abap_unit_assert=>assert_equals( act = lv_sum exp = 25 ).
  ENDMETHOD.

ENDCLASS.
