CLASS ltcl_alloc_env_fee DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_env_fee.
    DATA mt_lin TYPE zcl_alloc_env_fee=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_quantity TYPE i
        iv_fee      TYPE i.

    METHODS fee_value      FOR TESTING.
    METHODS fee_guard      FOR TESTING.
    METHODS totals         FOR TESTING.
    METHODS exempt_rule    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_env_fee IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_env_fee( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_env_fee=>ty_line.

    ls_line-quantity = iv_quantity.
    ls_line-unit_fee = iv_fee.
    APPEND ls_line TO mt_lin.
  ENDMETHOD.

  METHOD fee_value.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->fee( iv_quantity = 3 iv_unit_fee = 2 )
      exp = 6 ).
  ENDMETHOD.

  METHOD fee_guard.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->fee( iv_quantity = 0 iv_unit_fee = 2 )
      exp = 0 ).
  ENDMETHOD.

  METHOD totals.
    add( iv_quantity = 3 iv_fee = 2 ).
    add( iv_quantity = 1 iv_fee = 4 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_lin ) exp = 10 ).
  ENDMETHOD.

  METHOD exempt_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_exempt( 'REUSABLE' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_exempt( 'RECYCLED' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_exempt( 'STANDARD' ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
