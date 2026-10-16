CLASS ltcl_alloc_return_trend DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_trend.
    DATA mt_ser TYPE zcl_alloc_return_trend=>ty_series_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS rising       FOR TESTING.
    METHODS falling      FOR TESTING.
    METHODS flat         FOR TESTING.
    METHODS empty_series FOR TESTING.
    METHODS single_value FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_trend IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_trend( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_ser.
  ENDMETHOD.

  METHOD rising.
    add( 1 ).
    add( 2 ).
    add( 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( mt_ser ) exp = 'UP' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->slope_sign( mt_ser ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_rising( mt_ser ) exp = abap_true ).
  ENDMETHOD.

  METHOD falling.
    add( 3 ).
    add( 2 ).
    add( 1 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( mt_ser ) exp = 'DOWN' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->slope_sign( mt_ser ) exp = -1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_rising( mt_ser ) exp = abap_false ).
  ENDMETHOD.

  METHOD flat.
    add( 5 ).
    add( 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( mt_ser ) exp = 'FLAT' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->slope_sign( mt_ser ) exp = 0 ).
  ENDMETHOD.

  METHOD empty_series.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( mt_ser ) exp = 'FLAT' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_rising( mt_ser ) exp = abap_false ).
  ENDMETHOD.

  METHOD single_value.
    add( 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( mt_ser ) exp = 'FLAT' ).
  ENDMETHOD.

ENDCLASS.
