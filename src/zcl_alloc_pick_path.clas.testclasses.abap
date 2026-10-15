CLASS ltcl_alloc_pick_path DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_pick_path.
    DATA mt_stp TYPE zcl_alloc_bin_distance=>ty_coord_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_aisle TYPE i
        iv_rack  TYPE i.

    METHODS sums_legs    FOR TESTING.
    METHODS no_stops     FOR TESTING.
    METHODS single_stop  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_pick_path IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_pick_path( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_coord TYPE zcl_alloc_bin_coord=>ty_coord.

    ls_coord-aisle = iv_aisle.
    ls_coord-rack = iv_rack.
    APPEND ls_coord TO mt_stp.
  ENDMETHOD.

  METHOD sums_legs.
    add( iv_aisle = 1 iv_rack = 1 ).
    add( iv_aisle = 2 iv_rack = 1 ).
    add( iv_aisle = 2 iv_rack = 4 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->length( is_start = VALUE #( aisle = 0 rack = 0 )
                            it_stops = mt_stp )
      exp = 6 ).
  ENDMETHOD.

  METHOD no_stops.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->length( is_start = VALUE #( aisle = 1 rack = 1 )
                            it_stops = mt_stp )
      exp = 0 ).
  ENDMETHOD.

  METHOD single_stop.
    add( iv_aisle = 3 iv_rack = 1 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->length( is_start = VALUE #( aisle = 1 rack = 1 )
                            it_stops = mt_stp )
      exp = 2 ).
  ENDMETHOD.

ENDCLASS.
