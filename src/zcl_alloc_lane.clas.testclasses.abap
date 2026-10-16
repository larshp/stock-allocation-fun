CLASS ltcl_alloc_lane DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_lane.
    DATA mt_lan TYPE zcl_alloc_lane=>ty_lane_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_from TYPE string
        iv_to   TYPE string
        iv_dist TYPE i
        iv_rate TYPE menge_d.

    METHODS empty_lanes      FOR TESTING.
    METHODS cost_is_distance FOR TESTING.
    METHODS skips_zero_rate  FOR TESTING.
    METHODS skips_zero_dist  FOR TESTING.
    METHODS lookup_by_pair   FOR TESTING.
    METHODS finds_cheapest   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_lane IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_lane( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_lane TYPE zcl_alloc_lane=>ty_lane.

    ls_lane-from_node = iv_from.
    ls_lane-to_node = iv_to.
    ls_lane-distance = iv_dist.
    ls_lane-cost_per_km = iv_rate.
    APPEND ls_lane TO mt_lan.
  ENDMETHOD.

  METHOD empty_lanes.
    DATA(lt_cells) = mo_cut->build( mt_lan ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_cells ) exp = 0 ).
  ENDMETHOD.

  METHOD cost_is_distance.
    add( iv_from = 'A' iv_to = 'B' iv_dist = 100 iv_rate = '0.5' ).

    DATA(lt_cells) = mo_cut->build( mt_lan ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_cells ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_cells[ 1 ]-cost exp = 50 ).
  ENDMETHOD.

  METHOD skips_zero_rate.
    add( iv_from = 'A' iv_to = 'B' iv_dist = 100 iv_rate = 0 ).

    DATA(lt_cells) = mo_cut->build( mt_lan ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_cells ) exp = 0 ).
  ENDMETHOD.

  METHOD skips_zero_dist.
    add( iv_from = 'A' iv_to = 'B' iv_dist = 0 iv_rate = '1.0' ).

    DATA(lt_cells) = mo_cut->build( mt_lan ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_cells ) exp = 0 ).
  ENDMETHOD.

  METHOD lookup_by_pair.
    add( iv_from = 'A' iv_to = 'B' iv_dist = 10 iv_rate = '2.0' ).
    add( iv_from = 'B' iv_to = 'C' iv_dist = 5 iv_rate = '1.0' ).

    DATA(lt_cells) = mo_cut->build( mt_lan ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cost_of( it_cells = lt_cells
                             iv_from  = 'B'
                             iv_to    = 'C' )
      exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cost_of( it_cells = lt_cells
                             iv_from  = 'C'
                             iv_to    = 'B' )
      exp = 0 ).
  ENDMETHOD.

  METHOD finds_cheapest.
    add( iv_from = 'A' iv_to = 'B' iv_dist = 100 iv_rate = '2.0' ).
    add( iv_from = 'A' iv_to = 'C' iv_dist = 10 iv_rate = '1.0' ).

    DATA(lt_cells) = mo_cut->build( mt_lan ).
    DATA(ls_cell) = mo_cut->cheapest_lane( lt_cells ).

    cl_abap_unit_assert=>assert_equals( act = ls_cell-to_node exp = 'C' ).
    cl_abap_unit_assert=>assert_equals( act = ls_cell-cost exp = 10 ).
  ENDMETHOD.

ENDCLASS.
