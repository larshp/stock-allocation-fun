CLASS ltcl_alloc_regression DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_regression.
    DATA mt_x   TYPE zcl_alloc_regression=>ty_series_tt.
    DATA mt_y   TYPE zcl_alloc_regression=>ty_series_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_x TYPE menge_d
        iv_y TYPE menge_d.

    METHODS slope_two          FOR TESTING.
    METHODS slope_two_offset   FOR TESTING.
    METHODS flat_line          FOR TESTING.
    METHODS rising_flag        FOR TESTING.
    METHODS vertical_line      FOR TESTING.
    METHODS single_point       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_regression IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_regression( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_x TO mt_x.
    APPEND iv_y TO mt_y.
  ENDMETHOD.

  METHOD slope_two.
    add( iv_x = 1 iv_y = 2 ).
    add( iv_x = 2 iv_y = 4 ).
    add( iv_x = 3 iv_y = 6 ).

    DATA(ls_result) = mo_cut->fit( it_x = mt_x it_y = mt_y ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-slope_x1000 exp = 2000 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-intercept exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-points exp = 3 ).
  ENDMETHOD.

  METHOD slope_two_offset.
    add( iv_x = 1 iv_y = 3 ).
    add( iv_x = 2 iv_y = 5 ).

    DATA(ls_result) = mo_cut->fit( it_x = mt_x it_y = mt_y ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-slope_x1000 exp = 2000 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-intercept exp = 1 ).
  ENDMETHOD.

  METHOD flat_line.
    add( iv_x = 1 iv_y = 4 ).
    add( iv_x = 2 iv_y = 4 ).

    DATA(ls_result) = mo_cut->fit( it_x = mt_x it_y = mt_y ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-slope_x1000 exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-intercept exp = 4 ).
  ENDMETHOD.

  METHOD rising_flag.
    add( iv_x = 1 iv_y = 1 ).
    add( iv_x = 2 iv_y = 5 ).

    DATA(ls_result) = mo_cut->fit( it_x = mt_x it_y = mt_y ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-rising exp = abap_true ).
  ENDMETHOD.

  METHOD vertical_line.
    add( iv_x = 1 iv_y = 2 ).
    add( iv_x = 1 iv_y = 8 ).

    DATA(ls_result) = mo_cut->fit( it_x = mt_x it_y = mt_y ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-points exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-slope_x1000 exp = 0 ).
  ENDMETHOD.

  METHOD single_point.
    add( iv_x = 1 iv_y = 2 ).

    DATA(ls_result) = mo_cut->fit( it_x = mt_x it_y = mt_y ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-points exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-rising exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
