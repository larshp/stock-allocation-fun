CLASS ltcl_alloc_rma DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_rma.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_quantity TYPE menge_d
        iv_reason   TYPE string.

    METHODS sums_quantity FOR TESTING.
    METHODS counts_lines  FOR TESTING.
    METHODS keeps_order   FOR TESTING.
    METHODS clears        FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_rma IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_rma( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_rma=>ty_line.

    ls_line-material = iv_material.
    ls_line-quantity = iv_quantity.
    ls_line-reason = iv_reason.
    mo_cut->add( ls_line ).
  ENDMETHOD.

  METHOD sums_quantity.
    add( iv_material = 'M1' iv_quantity = 10 iv_reason = 'DAMAGED' ).
    add( iv_material = 'M2' iv_quantity = 5 iv_reason = 'WRONG_ITEM' ).
    add( iv_material = 'M3' iv_quantity = 2 iv_reason = 'DAMAGED' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_quantity( ) exp = 17 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->line_count( ) exp = 3 ).
  ENDMETHOD.

  METHOD counts_lines.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->line_count( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_quantity( ) exp = 0 ).
  ENDMETHOD.

  METHOD keeps_order.
    DATA lt_lines TYPE zcl_alloc_rma=>ty_line_tt.

    add( iv_material = 'M1' iv_quantity = 1 iv_reason = 'A' ).
    add( iv_material = 'M2' iv_quantity = 2 iv_reason = 'B' ).

    lt_lines = mo_cut->line_list( ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-material exp = 'M1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-material exp = 'M2' ).
  ENDMETHOD.

  METHOD clears.
    add( iv_material = 'M1' iv_quantity = 1 iv_reason = 'A' ).
    mo_cut->clear( ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->line_count( ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
