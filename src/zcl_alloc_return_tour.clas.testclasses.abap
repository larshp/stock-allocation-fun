CLASS ltcl_alloc_return_tour DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_tour.
    DATA mt_stp TYPE zcl_alloc_bin_distance=>ty_coord_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_aisle TYPE i
        iv_rack  TYPE i.

    METHODS counts_round_trips FOR TESTING.
    METHODS order_independent    FOR TESTING.
    METHODS no_stops             FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_tour IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_tour( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_coord TYPE zcl_alloc_bin_coord=>ty_coord.

    ls_coord-aisle = iv_aisle.
    ls_coord-rack = iv_rack.
    APPEND ls_coord TO mt_stp.
  ENDMETHOD.

  METHOD counts_round_trips.
    add( iv_aisle = 2 iv_rack = 1 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->length( is_start = VALUE #( aisle = 1 rack = 1 )
                            it_stops = mt_stp )
      exp = 2 ).
  ENDMETHOD.

  METHOD order_independent.
    DATA lv_first  TYPE i.
    DATA lv_second TYPE i.

    add( iv_aisle = 2 iv_rack = 1 ).
    add( iv_aisle = 5 iv_rack = 1 ).

    lv_first = mo_cut->length( is_start = VALUE #( aisle = 1 rack = 1 )
                               it_stops = mt_stp ).

    CLEAR mt_stp.
    add( iv_aisle = 5 iv_rack = 1 ).
    add( iv_aisle = 2 iv_rack = 1 ).

    lv_second = mo_cut->length( is_start = VALUE #( aisle = 1 rack = 1 )
                                it_stops = mt_stp ).

    cl_abap_unit_assert=>assert_equals( act = lv_first exp = lv_second ).
  ENDMETHOD.

  METHOD no_stops.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->length( is_start = VALUE #( aisle = 1 rack = 1 )
                            it_stops = mt_stp )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
