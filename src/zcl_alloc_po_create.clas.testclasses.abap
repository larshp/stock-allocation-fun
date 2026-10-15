CLASS ltcl_alloc_po_create DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_po_create.
    DATA mt_line TYPE zcl_alloc_po_create=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_quantity TYPE i
        iv_price    TYPE i.

    METHODS builds_order  FOR TESTING.
    METHODS counts_lines  FOR TESTING.
    METHODS sums_value    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_po_create IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_po_create( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_po_create=>ty_line.

    ls_line-material = iv_material.
    ls_line-quantity = iv_quantity.
    ls_line-price = iv_price.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_order.
    DATA ls_po TYPE zcl_alloc_po_create=>ty_po.

    add( iv_material = 'M1' iv_quantity = 10 iv_price = 5 ).
    add( iv_material = 'M2' iv_quantity = 2 iv_price = 20 ).

    ls_po = mo_cut->build( it_lines = mt_line iv_doc_no = 'PO001' ).

    cl_abap_unit_assert=>assert_equals( act = ls_po-doc_no exp = 'PO001' ).
    cl_abap_unit_assert=>assert_equals( act = ls_po-line_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_po-total_value exp = 90 ).
  ENDMETHOD.

  METHOD counts_lines.
    add( iv_material = 'M1' iv_quantity = 10 iv_price = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->line_count( mt_line ) exp = 1 ).
  ENDMETHOD.

  METHOD sums_value.
    add( iv_material = 'M1' iv_quantity = 10 iv_price = 5 ).
    add( iv_material = 'M2' iv_quantity = 2 iv_price = 20 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_value( mt_line ) exp = 90 ).
  ENDMETHOD.

ENDCLASS.
