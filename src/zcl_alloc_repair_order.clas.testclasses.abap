CLASS ltcl_alloc_repair_order DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_repair_order.
    DATA mt_itm TYPE zcl_alloc_repair_order=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_quantity TYPE menge_d.

    METHODS renumbers_lines FOR TESTING.
    METHODS skips_empty     FOR TESTING.
    METHODS totals          FOR TESTING.
    METHODS empty_input     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_repair_order IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_repair_order( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_repair_order=>ty_item.

    ls_item-material = iv_material.
    ls_item-quantity = iv_quantity.
    APPEND ls_item TO mt_itm.
  ENDMETHOD.

  METHOD renumbers_lines.
    DATA lt_lines TYPE zcl_alloc_repair_order=>ty_line_tt.

    add( iv_material = 'M1' iv_quantity = 2 ).
    add( iv_material = 'M2' iv_quantity = 0 ).
    add( iv_material = 'M3' iv_quantity = 1 ).

    lt_lines = mo_cut->build( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-line_no exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ]-material exp = 'M1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-line_no exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 2 ]-material exp = 'M3' ).
  ENDMETHOD.

  METHOD skips_empty.
    DATA lt_lines TYPE zcl_alloc_repair_order=>ty_line_tt.

    add( iv_material = 'M1' iv_quantity = -5 ).

    lt_lines = mo_cut->build( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 0 ).
  ENDMETHOD.

  METHOD totals.
    DATA lt_lines TYPE zcl_alloc_repair_order=>ty_line_tt.

    add( iv_material = 'M1' iv_quantity = 2 ).
    add( iv_material = 'M3' iv_quantity = 1 ).

    lt_lines = mo_cut->build( mt_itm ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( lt_lines ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->line_count( lt_lines ) exp = 2 ).
  ENDMETHOD.

  METHOD empty_input.
    DATA lt_lines TYPE zcl_alloc_repair_order=>ty_line_tt.

    lt_lines = mo_cut->build( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( lt_lines ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
