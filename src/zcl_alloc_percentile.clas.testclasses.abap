CLASS ltcl_alloc_percentile DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_percentile.
    DATA mt_ser TYPE zcl_alloc_percentile=>ty_series_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE menge_d.

    METHODS empty_series FOR TESTING.
    METHODS median_rank  FOR TESTING.
    METHODS extremes     FOR TESTING.
    METHODS quarter      FOR TESTING.
    METHODS clamps_range FOR TESTING.
    METHODS sorts_first  FOR TESTING.
    METHODS five_points  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_percentile IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_percentile( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_ser.
  ENDMETHOD.

  METHOD empty_series.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( it_values = mt_ser iv_pct = 50 ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rank_of( it_values = mt_ser iv_pct = 50 ) exp = 0 ).
  ENDMETHOD.

  METHOD median_rank.
    add( iv_value = 10 ).
    add( iv_value = 20 ).
    add( iv_value = 30 ).
    add( iv_value = 40 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rank_of( it_values = mt_ser iv_pct = 50 ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( it_values = mt_ser iv_pct = 50 ) exp = 20 ).
  ENDMETHOD.

  METHOD extremes.
    add( iv_value = 10 ).
    add( iv_value = 20 ).
    add( iv_value = 30 ).
    add( iv_value = 40 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( it_values = mt_ser iv_pct = 0 ) exp = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( it_values = mt_ser iv_pct = 100 ) exp = 40 ).
  ENDMETHOD.

  METHOD quarter.
    add( iv_value = 10 ).
    add( iv_value = 20 ).
    add( iv_value = 30 ).
    add( iv_value = 40 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( it_values = mt_ser iv_pct = 25 ) exp = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( it_values = mt_ser iv_pct = 75 ) exp = 30 ).
  ENDMETHOD.

  METHOD clamps_range.
    add( iv_value = 10 ).
    add( iv_value = 20 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( it_values = mt_ser iv_pct = -20 ) exp = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( it_values = mt_ser iv_pct = 500 ) exp = 20 ).
  ENDMETHOD.

  METHOD sorts_first.
    add( iv_value = 40 ).
    add( iv_value = 10 ).
    add( iv_value = 30 ).
    add( iv_value = 20 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( it_values = mt_ser iv_pct = 50 ) exp = 20 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( it_values = mt_ser iv_pct = 100 ) exp = 40 ).
  ENDMETHOD.

  METHOD five_points.
    add( iv_value = 10 ).
    add( iv_value = 20 ).
    add( iv_value = 30 ).
    add( iv_value = 40 ).
    add( iv_value = 50 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( it_values = mt_ser iv_pct = 25 ) exp = 20 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( it_values = mt_ser iv_pct = 50 ) exp = 30 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( it_values = mt_ser iv_pct = 75 ) exp = 40 ).
  ENDMETHOD.

ENDCLASS.
