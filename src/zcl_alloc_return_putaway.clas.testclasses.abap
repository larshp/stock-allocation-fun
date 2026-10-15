CLASS ltcl_alloc_return_putaway DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_putaway.
    DATA mt_itm TYPE zcl_alloc_return_putaway=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_quantity TYPE i
        iv_bin      TYPE string.

    METHODS proposes_lines FOR TESTING.
    METHODS skips_empty    FOR TESTING.
    METHODS finds_bin      FOR TESTING.
    METHODS counts_lines   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_putaway IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_putaway( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_return_putaway=>ty_item.

    ls_item-material = iv_material.
    ls_item-quantity = iv_quantity.
    ls_item-bin = iv_bin.
    APPEND ls_item TO mt_itm.
  ENDMETHOD.

  METHOD proposes_lines.
    DATA lt_lines TYPE zcl_alloc_return_putaway=>ty_line_tt.

    add( iv_material = 'M1' iv_quantity = 5 iv_bin = 'A1' ).
    add( iv_material = 'M2' iv_quantity = 3 iv_bin = 'B1' ).

    lt_lines = mo_cut->propose( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-bin exp = 'A1' ).
  ENDMETHOD.

  METHOD skips_empty.
    DATA lt_lines TYPE zcl_alloc_return_putaway=>ty_line_tt.

    add( iv_material = '' iv_quantity = 5 iv_bin = 'A1' ).
    add( iv_material = 'M2' iv_quantity = 0 iv_bin = 'B1' ).

    lt_lines = mo_cut->propose( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 0 ).
  ENDMETHOD.

  METHOD finds_bin.
    DATA lt_lines TYPE zcl_alloc_return_putaway=>ty_line_tt.

    add( iv_material = 'M1' iv_quantity = 5 iv_bin = 'A1' ).
    add( iv_material = 'M2' iv_quantity = 3 iv_bin = 'B1' ).

    lt_lines = mo_cut->propose( mt_itm ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->bin_of( it_lines = lt_lines iv_material = 'M2' )
      exp = 'B1' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->bin_of( it_lines = lt_lines iv_material = 'X' )
      exp = '' ).
  ENDMETHOD.

  METHOD counts_lines.
    DATA lt_lines TYPE zcl_alloc_return_putaway=>ty_line_tt.

    add( iv_material = 'M1' iv_quantity = 5 iv_bin = 'A1' ).
    add( iv_material = 'M2' iv_quantity = 3 iv_bin = 'B1' ).

    lt_lines = mo_cut->propose( mt_itm ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->line_count( lt_lines ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
