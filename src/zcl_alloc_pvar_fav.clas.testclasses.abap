CLASS ltcl_alloc_pvar_fav DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_pvar_fav.
    DATA mt_line TYPE zcl_alloc_pvar_fav=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_item   TYPE string
        iv_amount TYPE i.

    METHODS favourable_rule FOR TESTING.
    METHODS sums_favourable FOR TESTING.
    METHODS counts_favourable FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_pvar_fav IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_pvar_fav( ).

    add( iv_item = 'I1' iv_amount = -50 ).
    add( iv_item = 'I2' iv_amount = 30 ).
    add( iv_item = 'I3' iv_amount = -20 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_pvar_fav=>ty_line.

    ls_line-item = iv_item.
    ls_line-amount = iv_amount.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD favourable_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_favourable( -50 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_favourable( 30 ) exp = abap_false ).
  ENDMETHOD.

  METHOD sums_favourable.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->amount( mt_line ) exp = 70 ).
  ENDMETHOD.

  METHOD counts_favourable.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count( mt_line ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
