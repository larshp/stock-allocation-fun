CLASS ltcl_alloc_delivery_note DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_delivery_note.
    DATA mt_ite TYPE zcl_alloc_delivery_note=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_mat TYPE string
        iv_qty TYPE i
        iv_uom TYPE string.

    METHODS header_lines FOR TESTING.
    METHODS item_line    FOR TESTING.
    METHODS header_only  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_delivery_note IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_delivery_note( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_delivery_note=>ty_item.

    ls_item-material = iv_mat.
    ls_item-quantity = iv_qty.
    ls_item-uom = iv_uom.
    APPEND ls_item TO mt_ite.
  ENDMETHOD.

  METHOD header_lines.
    DATA lt_lines TYPE zcl_alloc_delivery_note=>ty_text_tt.

    add( iv_mat = 'M1' iv_qty = 5 iv_uom = 'PC' ).

    lt_lines = mo_cut->build( iv_delivery_no = 'DN-1' iv_customer = 'ACME'
                              it_items = mt_ite ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ] exp = 'Delivery: DN-1' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 2 ] exp = 'Customer: ACME' ).
  ENDMETHOD.

  METHOD item_line.
    DATA lt_lines TYPE zcl_alloc_delivery_note=>ty_text_tt.

    add( iv_mat = 'M1' iv_qty = 5 iv_uom = 'PC' ).

    lt_lines = mo_cut->build( iv_delivery_no = 'DN-1' iv_customer = 'ACME'
                              it_items = mt_ite ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 3 ] exp = '  M1 5 PC' ).
  ENDMETHOD.

  METHOD header_only.
    DATA lt_lines TYPE zcl_alloc_delivery_note=>ty_text_tt.

    lt_lines = mo_cut->build( iv_delivery_no = 'DN-2' iv_customer = 'ACME'
                              it_items = mt_ite ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
