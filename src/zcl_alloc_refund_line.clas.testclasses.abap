CLASS ltcl_alloc_refund_line DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_refund_line.
    DATA mt_itm TYPE zcl_alloc_refund_line=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_quantity TYPE i
        iv_price    TYPE i.

    METHODS numbers_and_runs FOR TESTING.
    METHODS skips_empty      FOR TESTING.
    METHODS counts           FOR TESTING.
    METHODS totals           FOR TESTING.
    METHODS empty_input      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_refund_line IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_refund_line( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_refund_line=>ty_item.

    ls_item-material = iv_material.
    ls_item-quantity = iv_quantity.
    ls_item-unit_price = iv_price.
    APPEND ls_item TO mt_itm.
  ENDMETHOD.

  METHOD numbers_and_runs.
    DATA lt_lines TYPE zcl_alloc_refund_line=>ty_line_tt.

    add( iv_material = 'M1' iv_quantity = 2 iv_price = 100 ).
    add( iv_material = 'M2' iv_quantity = 1 iv_price = 50 ).

    lt_lines = mo_cut->build( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-line_no exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-value exp = 200 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-running exp = 200 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-running exp = 250 ).
  ENDMETHOD.

  METHOD skips_empty.
    DATA lt_lines TYPE zcl_alloc_refund_line=>ty_line_tt.

    add( iv_material = 'M1' iv_quantity = 0 iv_price = 100 ).
    add( iv_material = 'M2' iv_quantity = 1 iv_price = 50 ).

    lt_lines = mo_cut->build( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-material exp = 'M2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-line_no exp = 1 ).
  ENDMETHOD.

  METHOD counts.
    DATA lt_lines TYPE zcl_alloc_refund_line=>ty_line_tt.

    add( iv_material = 'M1' iv_quantity = 2 iv_price = 100 ).
    add( iv_material = 'M2' iv_quantity = 1 iv_price = 50 ).

    lt_lines = mo_cut->build( mt_itm ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->line_count( lt_lines ) exp = 2 ).
  ENDMETHOD.

  METHOD totals.
    DATA lt_lines TYPE zcl_alloc_refund_line=>ty_line_tt.

    add( iv_material = 'M1' iv_quantity = 2 iv_price = 100 ).
    add( iv_material = 'M2' iv_quantity = 1 iv_price = 50 ).

    lt_lines = mo_cut->build( mt_itm ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( lt_lines ) exp = 250 ).
  ENDMETHOD.

  METHOD empty_input.
    DATA lt_lines TYPE zcl_alloc_refund_line=>ty_line_tt.

    lt_lines = mo_cut->build( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( lt_lines ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
