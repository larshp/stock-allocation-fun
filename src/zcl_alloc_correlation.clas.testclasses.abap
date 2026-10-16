CLASS ltcl_alloc_correlation DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_correlation.
    DATA mt_x   TYPE zcl_alloc_correlation=>ty_series_tt.
    DATA mt_y   TYPE zcl_alloc_correlation=>ty_series_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_x TYPE menge_d
        iv_y TYPE menge_d.

    METHODS perfect_positive FOR TESTING.
    METHODS perfect_negative FOR TESTING.
    METHODS weak_positive    FOR TESTING.
    METHODS too_few_points   FOR TESTING.
    METHODS length_mismatch  FOR TESTING.
    METHODS flat_series      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_correlation IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_correlation( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_x TO mt_x.
    APPEND iv_y TO mt_y.
  ENDMETHOD.

  METHOD perfect_positive.
    add( iv_x = 1 iv_y = 2 ).
    add( iv_x = 2 iv_y = 4 ).
    add( iv_x = 3 iv_y = 6 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( it_x = mt_x it_y = mt_y ) exp = 10000 ).
  ENDMETHOD.

  METHOD perfect_negative.
    add( iv_x = 1 iv_y = 6 ).
    add( iv_x = 2 iv_y = 4 ).
    add( iv_x = 3 iv_y = 2 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( it_x = mt_x it_y = mt_y ) exp = -10000 ).
  ENDMETHOD.

  METHOD weak_positive.
    add( iv_x = 1 iv_y = 1 ).
    add( iv_x = 2 iv_y = 3 ).
    add( iv_x = 3 iv_y = 2 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( it_x = mt_x it_y = mt_y ) exp = 5000 ).
  ENDMETHOD.

  METHOD too_few_points.
    add( iv_x = 1 iv_y = 2 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( it_x = mt_x it_y = mt_y ) exp = 0 ).
  ENDMETHOD.

  METHOD length_mismatch.
    add( iv_x = 1 iv_y = 2 ).
    add( iv_x = 2 iv_y = 4 ).
    APPEND 9 TO mt_x.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( it_x = mt_x it_y = mt_y ) exp = 0 ).
  ENDMETHOD.

  METHOD flat_series.
    add( iv_x = 1 iv_y = 5 ).
    add( iv_x = 2 iv_y = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( it_x = mt_x it_y = mt_y ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
