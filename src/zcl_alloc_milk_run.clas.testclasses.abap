CLASS ltcl_alloc_milk_run DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_milk_run.
    DATA mt_stp TYPE zcl_alloc_milk_run=>ty_stop_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_id  TYPE string
        iv_dem TYPE menge_d.

    METHODS empty_stops      FOR TESTING.
    METHODS packs_greedily   FOR TESTING.
    METHODS biggest_first    FOR TESTING.
    METHODS skips_oversized  FOR TESTING.
    METHODS zero_capacity    FOR TESTING.
    METHODS reports_unassigned FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_milk_run IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_milk_run( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_stop TYPE zcl_alloc_milk_run=>ty_stop.

    ls_stop-stop_id = iv_id.
    ls_stop-demand = iv_dem.
    APPEND ls_stop TO mt_stp.
  ENDMETHOD.

  METHOD empty_stops.
    DATA(lt_tours) = mo_cut->group( it_stops    = mt_stp
                                    iv_capacity = 30 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_tours ) exp = 0 ).
  ENDMETHOD.

  METHOD packs_greedily.
    add( iv_id = 'A' iv_dem = 10 ).
    add( iv_id = 'B' iv_dem = 20 ).
    add( iv_id = 'C' iv_dem = 10 ).
    add( iv_id = 'D' iv_dem = 5 ).

    DATA(lt_tours) = mo_cut->group( it_stops    = mt_stp
                                    iv_capacity = 30 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_tours ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_tours[ 1 ]-load exp = 30 ).
    cl_abap_unit_assert=>assert_equals( act = lt_tours[ 1 ]-tour_index exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_tours[ 2 ]-load exp = 15 ).
    cl_abap_unit_assert=>assert_equals( act = lt_tours[ 2 ]-tour_index exp = 2 ).
  ENDMETHOD.

  METHOD biggest_first.
    add( iv_id = 'SMALL' iv_dem = 5 ).
    add( iv_id = 'BIG' iv_dem = 25 ).

    DATA(lt_tours) = mo_cut->group( it_stops    = mt_stp
                                    iv_capacity = 30 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_tours ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_tours[ 1 ]-stop_ids[ 1 ] exp = 'BIG' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_tours[ 1 ]-stop_ids[ 2 ] exp = 'SMALL' ).
  ENDMETHOD.

  METHOD skips_oversized.
    add( iv_id = 'HUGE' iv_dem = 100 ).
    add( iv_id = 'FITS' iv_dem = 10 ).

    DATA(lt_tours) = mo_cut->group( it_stops    = mt_stp
                                    iv_capacity = 30 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_tours ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_tours[ 1 ]-load exp = 10 ).
  ENDMETHOD.

  METHOD zero_capacity.
    add( iv_id = 'A' iv_dem = 10 ).

    DATA(lt_tours) = mo_cut->group( it_stops    = mt_stp
                                    iv_capacity = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_tours ) exp = 0 ).
  ENDMETHOD.

  METHOD reports_unassigned.
    add( iv_id = 'HUGE' iv_dem = 100 ).
    add( iv_id = 'FITS' iv_dem = 10 ).

    DATA(lt_big) = mo_cut->unassigned( it_stops    = mt_stp
                                       iv_capacity = 30 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_big ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_big[ 1 ]-stop_id exp = 'HUGE' ).
  ENDMETHOD.

ENDCLASS.
