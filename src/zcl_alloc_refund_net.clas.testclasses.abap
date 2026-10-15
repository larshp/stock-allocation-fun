CLASS ltcl_alloc_refund_net DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_refund_net.
    DATA mt_lin TYPE zcl_alloc_refund_net=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value    TYPE i
        iv_fee      TYPE i
        iv_shipping TYPE i.

    METHODS nets_out     FOR TESTING.
    METHODS floors_at_zero FOR TESTING.
    METHODS fee_from_rate FOR TESTING.
    METHODS totals       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_refund_net IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_refund_net( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_refund_net=>ty_line.

    ls_line-value = iv_value.
    ls_line-fee = iv_fee.
    ls_line-shipping = iv_shipping.
    APPEND ls_line TO mt_lin.
  ENDMETHOD.

  METHOD nets_out.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->net( iv_value = 200 iv_fee = 20 iv_shipping = 10 )
      exp = 170 ).
  ENDMETHOD.

  METHOD floors_at_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->net( iv_value = 20 iv_fee = 30 iv_shipping = 10 )
      exp = 0 ).
  ENDMETHOD.

  METHOD fee_from_rate.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->fee_of( iv_value = 200 iv_fee_percent = 10 )
      exp = 20 ).
  ENDMETHOD.

  METHOD totals.
    add( iv_value = 200 iv_fee = 20 iv_shipping = 10 ).
    add( iv_value = 100 iv_fee = 0 iv_shipping = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_lin ) exp = 270 ).
  ENDMETHOD.

ENDCLASS.
