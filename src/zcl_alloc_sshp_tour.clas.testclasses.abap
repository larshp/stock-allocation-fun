CLASS ltcl_alloc_sshp_tour DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_sshp_tour.
    DATA mt_stp TYPE zcl_alloc_bin_distance=>ty_coord_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_aisle TYPE i
        iv_rack  TYPE i.

    METHODS groups_by_aisle FOR TESTING.
    METHODS keeps_aisle_order FOR TESTING.
    METHODS empty_stops      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_sshp_tour IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_sshp_tour( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_coord TYPE zcl_alloc_bin_coord=>ty_coord.

    ls_coord-aisle = iv_aisle.
    ls_coord-rack = iv_rack.
    APPEND ls_coord TO mt_stp.
  ENDMETHOD.

  METHOD groups_by_aisle.
    DATA lt_order TYPE zcl_alloc_bin_distance=>ty_coord_tt.

    add( iv_aisle = 2 iv_rack = 1 ).
    add( iv_aisle = 1 iv_rack = 5 ).
    add( iv_aisle = 2 iv_rack = 3 ).

    lt_order = mo_cut->order( it_stops = mt_stp ).

    cl_abap_unit_assert=>assert_equals( act = lt_order[ 1 ]-aisle exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_order[ 2 ]-aisle exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_order[ 3 ]-aisle exp = 2 ).
  ENDMETHOD.

  METHOD keeps_aisle_order.
    DATA lt_order TYPE zcl_alloc_bin_distance=>ty_coord_tt.

    add( iv_aisle = 2 iv_rack = 1 ).
    add( iv_aisle = 2 iv_rack = 3 ).

    lt_order = mo_cut->order( it_stops = mt_stp ).

    cl_abap_unit_assert=>assert_equals( act = lt_order[ 1 ]-rack exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_order[ 2 ]-rack exp = 3 ).
  ENDMETHOD.

  METHOD empty_stops.
    DATA lt_order TYPE zcl_alloc_bin_distance=>ty_coord_tt.

    lt_order = mo_cut->order( it_stops = mt_stp ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_order ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
