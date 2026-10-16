CLASS ltcl_alloc_ship_consolidate DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_ship_consolidate.
    DATA mt_lin TYPE zcl_alloc_ship_consolidate=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_dest TYPE string
        iv_mat  TYPE matnr
        iv_qty  TYPE menge_d.

    METHODS groups_by_dest  FOR TESTING.
    METHODS keeps_order     FOR TESTING.
    METHODS counts_lines    FOR TESTING.
    METHODS empty_input     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_ship_consolidate IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_ship_consolidate( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_ship_consolidate=>ty_line.

    ls_line-destination = iv_dest.
    ls_line-material = iv_mat.
    ls_line-quantity = iv_qty.
    APPEND ls_line TO mt_lin.
  ENDMETHOD.

  METHOD groups_by_dest.
    DATA lt_ships TYPE zcl_alloc_ship_consolidate=>ty_shipment_tt.

    add( iv_dest = 'HAMBURG' iv_mat = 'M1' iv_qty = 10 ).
    add( iv_dest = 'HAMBURG' iv_mat = 'M2' iv_qty = 5 ).
    add( iv_dest = 'BREMEN' iv_mat = 'M1' iv_qty = 3 ).

    lt_ships = mo_cut->consolidate( mt_lin ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_ships ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_ships[ 1 ]-total_qty exp = 15 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_ships[ 2 ]-total_qty exp = 3 ).
  ENDMETHOD.

  METHOD keeps_order.
    DATA lt_ships TYPE zcl_alloc_ship_consolidate=>ty_shipment_tt.

    add( iv_dest = 'BREMEN' iv_mat = 'M1' iv_qty = 3 ).
    add( iv_dest = 'HAMBURG' iv_mat = 'M1' iv_qty = 10 ).
    add( iv_dest = 'BREMEN' iv_mat = 'M2' iv_qty = 1 ).

    lt_ships = mo_cut->consolidate( mt_lin ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_ships[ 1 ]-destination exp = 'BREMEN' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_ships[ 2 ]-destination exp = 'HAMBURG' ).
  ENDMETHOD.

  METHOD counts_lines.
    DATA lt_ships TYPE zcl_alloc_ship_consolidate=>ty_shipment_tt.

    add( iv_dest = 'HAMBURG' iv_mat = 'M1' iv_qty = 10 ).
    add( iv_dest = 'HAMBURG' iv_mat = 'M2' iv_qty = 5 ).

    lt_ships = mo_cut->consolidate( mt_lin ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_ships[ 1 ]-line_count exp = 2 ).
  ENDMETHOD.

  METHOD empty_input.
    DATA lt_ships TYPE zcl_alloc_ship_consolidate=>ty_shipment_tt.

    lt_ships = mo_cut->consolidate( mt_lin ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_ships ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
