CLASS ltcl_alloc_destruction_cert DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_destruction_cert.
    DATA mt_itm TYPE zcl_alloc_destruction_cert=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_quantity TYPE i.

    METHODS builds_cert     FOR TESTING.
    METHODS sums_quantity   FOR TESTING.
    METHODS complete_rule   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_destruction_cert IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_destruction_cert( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_destruction_cert=>ty_item.

    ls_item-material = iv_material.
    ls_item-quantity = iv_quantity.
    APPEND ls_item TO mt_itm.
  ENDMETHOD.

  METHOD builds_cert.
    DATA ls_cert TYPE zcl_alloc_destruction_cert=>ty_cert.

    add( iv_material = 'M1' iv_quantity = 5 ).
    add( iv_material = 'M2' iv_quantity = 3 ).
    add( iv_material = 'M3' iv_quantity = 0 ).

    ls_cert = mo_cut->build( it_items = mt_itm iv_cert_no = 'C1' ).

    cl_abap_unit_assert=>assert_equals( act = ls_cert-cert_no exp = 'C1' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_cert-quantity_total exp = 8 ).
    cl_abap_unit_assert=>assert_equals( act = ls_cert-line_count exp = 2 ).
  ENDMETHOD.

  METHOD sums_quantity.
    add( iv_material = 'M1' iv_quantity = 5 ).
    add( iv_material = 'M2' iv_quantity = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->quantity_total( mt_itm ) exp = 8 ).
  ENDMETHOD.

  METHOD complete_rule.
    DATA ls_cert TYPE zcl_alloc_destruction_cert=>ty_cert.

    add( iv_material = 'M1' iv_quantity = 5 ).

    ls_cert = mo_cut->build( it_items = mt_itm iv_cert_no = 'C1' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_complete( ls_cert ) exp = abap_true ).

    ls_cert = mo_cut->build( it_items = mt_itm iv_cert_no = '' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_complete( ls_cert ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
