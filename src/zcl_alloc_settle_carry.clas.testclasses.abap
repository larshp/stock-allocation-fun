CLASS ltcl_alloc_settle_carry DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_settle_carry.
    DATA mt_line TYPE zcl_alloc_settle_carry=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_item   TYPE string
        iv_amount TYPE i.

    METHODS computes_carry FOR TESTING.
    METHODS carried_rule   FOR TESTING.
    METHODS sums_amount    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_settle_carry IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_settle_carry( ).

    add( iv_item = 'I1' iv_amount = 100 ).
    add( iv_item = 'I2' iv_amount = 50 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_settle_carry=>ty_line.

    ls_line-item = iv_item.
    ls_line-amount = iv_amount.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD computes_carry.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->carry( iv_closing = 1000 iv_settled = 900 )
      exp = 100 ).
  ENDMETHOD.

  METHOD carried_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_carried( 100 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_carried( 0 ) exp = abap_false ).
  ENDMETHOD.

  METHOD sums_amount.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->amount( mt_line ) exp = 150 ).
  ENDMETHOD.

ENDCLASS.
