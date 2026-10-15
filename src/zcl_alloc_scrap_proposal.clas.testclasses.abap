CLASS ltcl_alloc_scrap_proposal DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_scrap_proposal.
    DATA mt_itm TYPE zcl_alloc_scrap_proposal=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_quantity TYPE menge_d.

    METHODS skips_empty    FOR TESTING.
    METHODS totals         FOR TESTING.
    METHODS reasons        FOR TESTING.
    METHODS empty_input    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_scrap_proposal IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_scrap_proposal( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_scrap_proposal=>ty_item.

    ls_item-material = iv_material.
    ls_item-quantity = iv_quantity.
    APPEND ls_item TO mt_itm.
  ENDMETHOD.

  METHOD skips_empty.
    DATA lt_lines TYPE zcl_alloc_scrap_proposal=>ty_line_tt.

    add( iv_material = 'M1' iv_quantity = 5 ).
    add( iv_material = 'M2' iv_quantity = 0 ).
    add( iv_material = 'M3' iv_quantity = -1 ).
    add( iv_material = 'M4' iv_quantity = 3 ).

    lt_lines = mo_cut->propose( it_items  = mt_itm
                                iv_reason = 'DAMAGED' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ]-material exp = 'M1' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 2 ]-material exp = 'M4' ).
  ENDMETHOD.

  METHOD totals.
    DATA lt_lines TYPE zcl_alloc_scrap_proposal=>ty_line_tt.

    add( iv_material = 'M1' iv_quantity = 5 ).
    add( iv_material = 'M4' iv_quantity = 3 ).

    lt_lines = mo_cut->propose( it_items  = mt_itm
                                iv_reason = 'DAMAGED' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_quantity( lt_lines ) exp = 8 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ]-reason exp = 'DAMAGED' ).
  ENDMETHOD.

  METHOD reasons.
    DATA ls_item TYPE zcl_alloc_scrap_proposal=>ty_item.

    ls_item-material = 'M1'.
    ls_item-quantity = 5.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( ls_item ) exp = 'SCRAP' ).

    ls_item-quantity = 0.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( ls_item ) exp = '' ).
  ENDMETHOD.

  METHOD empty_input.
    DATA lt_lines TYPE zcl_alloc_scrap_proposal=>ty_line_tt.

    lt_lines = mo_cut->propose( it_items  = mt_itm
                                iv_reason = 'DAMAGED' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_quantity( lt_lines ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
