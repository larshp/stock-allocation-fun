CLASS ltcl_alloc_dock_door DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_dock_door.
    DATA mt_loa TYPE zcl_alloc_dock_door=>ty_load_tt.
    DATA mt_doo TYPE zcl_alloc_dock_door=>ty_door_tt.

    METHODS setup.

    METHODS add_load
      IMPORTING
        iv_id TYPE string.

    METHODS balances_doors FOR TESTING.
    METHODS first_door     FOR TESTING.
    METHODS no_doors       FOR TESTING.
    METHODS empty_loads    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_dock_door IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_dock_door( ).
    APPEND 'D1' TO mt_doo.
    APPEND 'D2' TO mt_doo.
  ENDMETHOD.

  METHOD add_load.
    DATA ls_load TYPE zcl_alloc_dock_door=>ty_load.

    ls_load-load_id = iv_id.
    APPEND ls_load TO mt_loa.
  ENDMETHOD.

  METHOD balances_doors.
    DATA lt_assign TYPE zcl_alloc_dock_door=>ty_assign_tt.

    add_load( 'L1' ).
    add_load( 'L2' ).
    add_load( 'L3' ).
    add_load( 'L4' ).

    lt_assign = mo_cut->assign( it_loads = mt_loa it_doors = mt_doo ).

    cl_abap_unit_assert=>assert_equals( act = lt_assign[ 1 ]-door exp = 'D1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_assign[ 2 ]-door exp = 'D2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_assign[ 3 ]-door exp = 'D1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_assign[ 4 ]-door exp = 'D2' ).
  ENDMETHOD.

  METHOD first_door.
    DATA lt_assign TYPE zcl_alloc_dock_door=>ty_assign_tt.

    add_load( 'L1' ).

    lt_assign = mo_cut->assign( it_loads = mt_loa it_doors = mt_doo ).

    cl_abap_unit_assert=>assert_equals( act = lt_assign[ 1 ]-load_id exp = 'L1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_assign[ 1 ]-door exp = 'D1' ).
  ENDMETHOD.

  METHOD no_doors.
    DATA lt_assign TYPE zcl_alloc_dock_door=>ty_assign_tt.
    DATA lt_none   TYPE zcl_alloc_dock_door=>ty_door_tt.

    add_load( 'L1' ).

    lt_assign = mo_cut->assign( it_loads = mt_loa it_doors = lt_none ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_assign ) exp = 0 ).
  ENDMETHOD.

  METHOD empty_loads.
    DATA lt_assign TYPE zcl_alloc_dock_door=>ty_assign_tt.

    lt_assign = mo_cut->assign( it_loads = mt_loa it_doors = mt_doo ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_assign ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
