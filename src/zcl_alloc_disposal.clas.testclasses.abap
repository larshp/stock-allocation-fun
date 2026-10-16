CLASS ltcl_alloc_disposal DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_disposal.
    DATA mt_itm TYPE zcl_alloc_disposal=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_quantity TYPE i.

    METHODS proposes_lines FOR TESTING.
    METHODS skips_zero     FOR TESTING.
    METHODS totals         FOR TESTING.
    METHODS counts_lines   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_disposal IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_disposal( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_disposal=>ty_item.

    ls_item-material = iv_material.
    ls_item-quantity = iv_quantity.
    APPEND ls_item TO mt_itm.
  ENDMETHOD.

  METHOD proposes_lines.
    DATA lt_lines TYPE zcl_alloc_disposal=>ty_line_tt.

    add( iv_material = 'M1' iv_quantity = 5 ).
    add( iv_material = 'M2' iv_quantity = 0 ).
    add( iv_material = 'M3' iv_quantity = 2 ).

    lt_lines = mo_cut->propose( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-material exp = 'M1' ).
  ENDMETHOD.

  METHOD skips_zero.
    DATA lt_lines TYPE zcl_alloc_disposal=>ty_line_tt.

    add( iv_material = 'M1' iv_quantity = 0 ).

    lt_lines = mo_cut->propose( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 0 ).
  ENDMETHOD.

  METHOD totals.
    DATA lt_lines TYPE zcl_alloc_disposal=>ty_line_tt.

    add( iv_material = 'M1' iv_quantity = 5 ).
    add( iv_material = 'M3' iv_quantity = 2 ).

    lt_lines = mo_cut->propose( mt_itm ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( lt_lines ) exp = 7 ).
  ENDMETHOD.

  METHOD counts_lines.
    DATA lt_lines TYPE zcl_alloc_disposal=>ty_line_tt.

    add( iv_material = 'M1' iv_quantity = 5 ).
    add( iv_material = 'M3' iv_quantity = 2 ).

    lt_lines = mo_cut->propose( mt_itm ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->line_count( lt_lines ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
