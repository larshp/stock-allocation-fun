CLASS ltcl_alloc_return_segregate DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_segregate.
    DATA mt_itm TYPE zcl_alloc_return_segregate=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_quantity TYPE i
        iv_sellable TYPE abap_bool.

    METHODS separates_sellable FOR TESTING.
    METHODS separates_blocked  FOR TESTING.
    METHODS sums_sellable      FOR TESTING.
    METHODS sums_blocked       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_segregate IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_segregate( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_return_segregate=>ty_item.

    ls_item-material = iv_material.
    ls_item-quantity = iv_quantity.
    ls_item-sellable = iv_sellable.
    APPEND ls_item TO mt_itm.
  ENDMETHOD.

  METHOD separates_sellable.
    DATA lt_lines TYPE zcl_alloc_return_segregate=>ty_line_tt.

    add( iv_material = 'M1' iv_quantity = 5 iv_sellable = abap_true ).
    add( iv_material = 'M2' iv_quantity = 3 iv_sellable = abap_false ).
    add( iv_material = 'M3' iv_quantity = 2 iv_sellable = abap_true ).

    lt_lines = mo_cut->separate( it_items    = mt_itm
                                 iv_sellable = abap_true ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-material exp = 'M1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-material exp = 'M3' ).
  ENDMETHOD.

  METHOD separates_blocked.
    DATA lt_lines TYPE zcl_alloc_return_segregate=>ty_line_tt.

    add( iv_material = 'M1' iv_quantity = 5 iv_sellable = abap_true ).
    add( iv_material = 'M2' iv_quantity = 3 iv_sellable = abap_false ).

    lt_lines = mo_cut->separate( it_items    = mt_itm
                                 iv_sellable = abap_false ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-material exp = 'M2' ).
  ENDMETHOD.

  METHOD sums_sellable.
    add( iv_material = 'M1' iv_quantity = 5 iv_sellable = abap_true ).
    add( iv_material = 'M2' iv_quantity = 3 iv_sellable = abap_false ).
    add( iv_material = 'M3' iv_quantity = 2 iv_sellable = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->sellable( mt_itm ) exp = 7 ).
  ENDMETHOD.

  METHOD sums_blocked.
    add( iv_material = 'M1' iv_quantity = 5 iv_sellable = abap_true ).
    add( iv_material = 'M2' iv_quantity = 3 iv_sellable = abap_false ).
    add( iv_material = 'M3' iv_quantity = 2 iv_sellable = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->blocked( mt_itm ) exp = 3 ).
  ENDMETHOD.

ENDCLASS.
