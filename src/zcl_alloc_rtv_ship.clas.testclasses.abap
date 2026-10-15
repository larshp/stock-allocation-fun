CLASS ltcl_alloc_rtv_ship DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_rtv_ship.
    DATA mt_itm TYPE zcl_alloc_rtv_ship=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_quantity TYPE i
        iv_cost     TYPE i.

    METHODS builds_lines   FOR TESTING.
    METHODS skips_empty    FOR TESTING.
    METHODS totals         FOR TESTING.
    METHODS counts_lines   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_rtv_ship IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_rtv_ship( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_rtv_ship=>ty_item.

    ls_item-material = iv_material.
    ls_item-quantity = iv_quantity.
    ls_item-unit_cost = iv_cost.
    APPEND ls_item TO mt_itm.
  ENDMETHOD.

  METHOD builds_lines.
    DATA lt_lines TYPE zcl_alloc_rtv_ship=>ty_line_tt.

    add( iv_material = 'M1' iv_quantity = 2 iv_cost = 10 ).
    add( iv_material = 'M2' iv_quantity = 1 iv_cost = 5 ).

    lt_lines = mo_cut->build( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-value exp = 20 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-value exp = 5 ).
  ENDMETHOD.

  METHOD skips_empty.
    DATA lt_lines TYPE zcl_alloc_rtv_ship=>ty_line_tt.

    add( iv_material = 'M1' iv_quantity = 0 iv_cost = 10 ).
    add( iv_material = 'M2' iv_quantity = 3 iv_cost = 0 ).
    add( iv_material = 'M3' iv_quantity = 1 iv_cost = 7 ).

    lt_lines = mo_cut->build( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-material exp = 'M3' ).
  ENDMETHOD.

  METHOD totals.
    DATA lt_lines TYPE zcl_alloc_rtv_ship=>ty_line_tt.

    add( iv_material = 'M1' iv_quantity = 2 iv_cost = 10 ).
    add( iv_material = 'M2' iv_quantity = 1 iv_cost = 5 ).

    lt_lines = mo_cut->build( mt_itm ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( lt_lines ) exp = 25 ).
  ENDMETHOD.

  METHOD counts_lines.
    DATA lt_lines TYPE zcl_alloc_rtv_ship=>ty_line_tt.

    add( iv_material = 'M1' iv_quantity = 2 iv_cost = 10 ).
    add( iv_material = 'M2' iv_quantity = 1 iv_cost = 5 ).

    lt_lines = mo_cut->build( mt_itm ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->line_count( lt_lines ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
