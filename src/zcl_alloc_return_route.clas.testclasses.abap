CLASS ltcl_alloc_return_route DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_route.
    DATA mt_stp TYPE zcl_alloc_return_route=>ty_stop_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_customer TYPE string
        iv_quantity TYPE i
        iv_distance TYPE i.

    METHODS nearest_first  FOR TESTING.
    METHODS skips_empty    FOR TESTING.
    METHODS counts_stops   FOR TESTING.
    METHODS sums_quantity  FOR TESTING.
    METHODS empty_input    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_route IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_route( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_stop TYPE zcl_alloc_return_route=>ty_stop.

    ls_stop-customer = iv_customer.
    ls_stop-quantity = iv_quantity.
    ls_stop-distance = iv_distance.
    APPEND ls_stop TO mt_stp.
  ENDMETHOD.

  METHOD nearest_first.
    DATA lt_route TYPE zcl_alloc_return_route=>ty_leg_tt.

    add( iv_customer = 'A' iv_quantity = 10 iv_distance = 5 ).
    add( iv_customer = 'B' iv_quantity = 7 iv_distance = 3 ).

    lt_route = mo_cut->build( mt_stp ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_route ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_route[ 1 ]-customer exp = 'B' ).
    cl_abap_unit_assert=>assert_equals( act = lt_route[ 1 ]-cumulative exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_route[ 2 ]-customer exp = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = lt_route[ 2 ]-cumulative exp = 8 ).
  ENDMETHOD.

  METHOD skips_empty.
    DATA lt_route TYPE zcl_alloc_return_route=>ty_leg_tt.

    add( iv_customer = '' iv_quantity = 5 iv_distance = 1 ).
    add( iv_customer = 'B' iv_quantity = 0 iv_distance = 2 ).
    add( iv_customer = 'C' iv_quantity = 3 iv_distance = 4 ).

    lt_route = mo_cut->build( mt_stp ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_route ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_route[ 1 ]-customer exp = 'C' ).
  ENDMETHOD.

  METHOD counts_stops.
    add( iv_customer = 'A' iv_quantity = 10 iv_distance = 5 ).
    add( iv_customer = 'B' iv_quantity = 7 iv_distance = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->stop_count( mt_stp ) exp = 2 ).
  ENDMETHOD.

  METHOD sums_quantity.
    add( iv_customer = 'A' iv_quantity = 10 iv_distance = 5 ).
    add( iv_customer = 'B' iv_quantity = 7 iv_distance = 3 ).
    add( iv_customer = 'C' iv_quantity = 0 iv_distance = 1 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_quantity( mt_stp ) exp = 17 ).
  ENDMETHOD.

  METHOD empty_input.
    DATA lt_route TYPE zcl_alloc_return_route=>ty_leg_tt.

    lt_route = mo_cut->build( mt_stp ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_route ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
