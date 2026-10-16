CLASS ltcl_alloc_pvar_total DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_pvar_total.
    DATA mt_line TYPE zcl_alloc_pvar_total=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_item   TYPE string
        iv_amount TYPE i.

    METHODS sums_total   FOR TESTING.
    METHODS zero_rule    FOR TESTING.
    METHODS counts_items FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_pvar_total IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_pvar_total( ).

    add( iv_item = 'I1' iv_amount = 10 ).
    add( iv_item = 'I2' iv_amount = -5 ).
    add( iv_item = 'I3' iv_amount = 3 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_pvar_total=>ty_line.

    ls_line-item = iv_item.
    ls_line-amount = iv_amount.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD sums_total.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_line ) exp = 8 ).
  ENDMETHOD.

  METHOD zero_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 0 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 8 ) exp = abap_false ).
  ENDMETHOD.

  METHOD counts_items.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count( mt_line ) exp = 3 ).
  ENDMETHOD.

ENDCLASS.
