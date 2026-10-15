CLASS ltcl_alloc_carton_seq DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_carton_seq.
    DATA mt_ite TYPE zcl_alloc_carton_seq=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_qty      TYPE i.

    METHODS carries_over    FOR TESTING.
    METHODS packs_in_order  FOR TESTING.
    METHODS counts_cartons  FOR TESTING.
    METHODS zero_capacity   FOR TESTING.
    METHODS skips_zero_item FOR TESTING.
    METHODS exact_fill      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_carton_seq IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_carton_seq( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_carton_seq=>ty_item.

    ls_item-material = iv_material.
    ls_item-quantity = iv_qty.
    APPEND ls_item TO mt_ite.
  ENDMETHOD.

  METHOD carries_over.
    DATA lt_fills TYPE zcl_alloc_carton_seq=>ty_fill_tt.

    add( iv_material = 'M1' iv_qty = 3 ).
    add( iv_material = 'M2' iv_qty = 4 ).

    lt_fills = mo_cut->pack( it_items = mt_ite iv_capacity = 5 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_fills ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_fills[ 1 ]-quantity exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_fills[ 2 ]-quantity exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_fills[ 3 ]-quantity exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_fills[ 3 ]-carton_no exp = 2 ).
  ENDMETHOD.

  METHOD packs_in_order.
    DATA lt_fills TYPE zcl_alloc_carton_seq=>ty_fill_tt.

    add( iv_material = 'M1' iv_qty = 2 ).
    add( iv_material = 'M2' iv_qty = 2 ).

    lt_fills = mo_cut->pack( it_items = mt_ite iv_capacity = 10 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_fills ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_fills[ 1 ]-material exp = 'M1' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_fills[ 2 ]-material exp = 'M2' ).
  ENDMETHOD.

  METHOD counts_cartons.
    DATA lt_fills TYPE zcl_alloc_carton_seq=>ty_fill_tt.

    add( iv_material = 'M1' iv_qty = 11 ).

    lt_fills = mo_cut->pack( it_items = mt_ite iv_capacity = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->carton_count( it_fills = lt_fills ) exp = 3 ).
  ENDMETHOD.

  METHOD zero_capacity.
    DATA lt_fills TYPE zcl_alloc_carton_seq=>ty_fill_tt.

    add( iv_material = 'M1' iv_qty = 5 ).

    lt_fills = mo_cut->pack( it_items = mt_ite iv_capacity = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_fills ) exp = 0 ).
  ENDMETHOD.

  METHOD skips_zero_item.
    DATA lt_fills TYPE zcl_alloc_carton_seq=>ty_fill_tt.

    add( iv_material = 'M1' iv_qty = 0 ).
    add( iv_material = 'M2' iv_qty = 2 ).

    lt_fills = mo_cut->pack( it_items = mt_ite iv_capacity = 5 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_fills ) exp = 1 ).
  ENDMETHOD.

  METHOD exact_fill.
    DATA lt_fills TYPE zcl_alloc_carton_seq=>ty_fill_tt.

    add( iv_material = 'M1' iv_qty = 10 ).

    lt_fills = mo_cut->pack( it_items = mt_ite iv_capacity = 5 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_fills ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_fills[ 2 ]-carton_no exp = 2 ).
  ENDMETHOD.

ENDCLASS.
