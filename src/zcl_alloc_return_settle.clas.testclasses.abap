CLASS ltcl_alloc_return_settle DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_settle.
    DATA mt_lin TYPE zcl_alloc_return_settle=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_refund   TYPE i
        iv_fee      TYPE i
        iv_shipping TYPE i.

    METHODS builds_entries FOR TESTING.
    METHODS floors_net     FOR TESTING.
    METHODS skips_empty    FOR TESTING.
    METHODS counts_lines   FOR TESTING.
    METHODS nets_total     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_settle IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_settle( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_return_settle=>ty_line.

    ls_line-material = iv_material.
    ls_line-refund = iv_refund.
    ls_line-fee = iv_fee.
    ls_line-shipping = iv_shipping.
    APPEND ls_line TO mt_lin.
  ENDMETHOD.

  METHOD builds_entries.
    DATA lt_entries TYPE zcl_alloc_return_settle=>ty_entry_tt.

    add( iv_material = 'M1' iv_refund = 200 iv_fee = 20 iv_shipping = 10 ).

    lt_entries = mo_cut->build( mt_lin ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_entries ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_entries[ 1 ]-material exp = 'M1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_entries[ 1 ]-net exp = 170 ).
  ENDMETHOD.

  METHOD floors_net.
    DATA lt_entries TYPE zcl_alloc_return_settle=>ty_entry_tt.

    add( iv_material = 'M2' iv_refund = 20 iv_fee = 30 iv_shipping = 10 ).

    lt_entries = mo_cut->build( mt_lin ).

    cl_abap_unit_assert=>assert_equals( act = lt_entries[ 1 ]-net exp = 0 ).
  ENDMETHOD.

  METHOD skips_empty.
    DATA lt_entries TYPE zcl_alloc_return_settle=>ty_entry_tt.

    add( iv_material = 'M1' iv_refund = 0 iv_fee = 0 iv_shipping = 0 ).
    add( iv_material = 'M2' iv_refund = 100 iv_fee = 0 iv_shipping = 0 ).

    lt_entries = mo_cut->build( mt_lin ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_entries ) exp = 1 ).
  ENDMETHOD.

  METHOD counts_lines.
    DATA lt_entries TYPE zcl_alloc_return_settle=>ty_entry_tt.

    add( iv_material = 'M1' iv_refund = 200 iv_fee = 20 iv_shipping = 10 ).
    add( iv_material = 'M2' iv_refund = 100 iv_fee = 0 iv_shipping = 0 ).

    lt_entries = mo_cut->build( mt_lin ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->line_count( lt_entries ) exp = 2 ).
  ENDMETHOD.

  METHOD nets_total.
    DATA lt_entries TYPE zcl_alloc_return_settle=>ty_entry_tt.

    add( iv_material = 'M1' iv_refund = 200 iv_fee = 20 iv_shipping = 10 ).
    add( iv_material = 'M2' iv_refund = 20 iv_fee = 30 iv_shipping = 10 ).

    lt_entries = mo_cut->build( mt_lin ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->net_settlement( lt_entries ) exp = 170 ).
  ENDMETHOD.

ENDCLASS.
