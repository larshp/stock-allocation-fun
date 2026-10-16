CLASS ltcl_alloc_return_top DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_top.
    DATA mt_itm TYPE zcl_alloc_return_top=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_quantity TYPE i.

    METHODS aggregates_and_orders FOR TESTING.
    METHODS respects_limit      FOR TESTING.
    METHODS quantity_of_matches FOR TESTING.
    METHODS counts_rows         FOR TESTING.
    METHODS zero_limit          FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_top IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_top( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_return_top=>ty_item.

    ls_item-material = iv_material.
    ls_item-quantity = iv_quantity.
    APPEND ls_item TO mt_itm.
  ENDMETHOD.

  METHOD aggregates_and_orders.
    DATA lt_top TYPE zcl_alloc_return_top=>ty_top_tt.

    add( iv_material = 'M1' iv_quantity = 5 ).
    add( iv_material = 'M2' iv_quantity = 3 ).
    add( iv_material = 'M1' iv_quantity = 2 ).

    lt_top = mo_cut->top( it_items = mt_itm iv_limit = 2 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_top ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_top[ 1 ]-material exp = 'M1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_top[ 1 ]-quantity exp = 7 ).
    cl_abap_unit_assert=>assert_equals( act = lt_top[ 2 ]-material exp = 'M2' ).
  ENDMETHOD.

  METHOD respects_limit.
    DATA lt_top TYPE zcl_alloc_return_top=>ty_top_tt.

    add( iv_material = 'M1' iv_quantity = 5 ).
    add( iv_material = 'M2' iv_quantity = 3 ).

    lt_top = mo_cut->top( it_items = mt_itm iv_limit = 1 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_top ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_top[ 1 ]-material exp = 'M1' ).
  ENDMETHOD.

  METHOD quantity_of_matches.
    add( iv_material = 'M1' iv_quantity = 5 ).
    add( iv_material = 'M1' iv_quantity = 2 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->quantity_of( it_items = mt_itm iv_material = 'M1' )
      exp = 7 ).
  ENDMETHOD.

  METHOD counts_rows.
    DATA lt_top TYPE zcl_alloc_return_top=>ty_top_tt.

    add( iv_material = 'M1' iv_quantity = 5 ).
    add( iv_material = 'M2' iv_quantity = 3 ).

    lt_top = mo_cut->top( it_items = mt_itm iv_limit = 2 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count( lt_top ) exp = 2 ).
  ENDMETHOD.

  METHOD zero_limit.
    DATA lt_top TYPE zcl_alloc_return_top=>ty_top_tt.

    add( iv_material = 'M1' iv_quantity = 5 ).

    lt_top = mo_cut->top( it_items = mt_itm iv_limit = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_top ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
