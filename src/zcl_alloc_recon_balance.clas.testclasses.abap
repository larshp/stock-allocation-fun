CLASS ltcl_alloc_recon_balance DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_recon_balance.
    DATA mt_left TYPE zcl_alloc_recon_balance=>ty_line_tt.
    DATA mt_right TYPE zcl_alloc_recon_balance=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_side   TYPE string
        iv_amount TYPE i.

    METHODS computes_balance FOR TESTING.
    METHODS balanced_rule    FOR TESTING.
    METHODS reads_residual   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_recon_balance IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_recon_balance( ).

    add( iv_side = 'L' iv_amount = 600 ).
    add( iv_side = 'L' iv_amount = 300 ).
    add( iv_side = 'R' iv_amount = 800 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_recon_balance=>ty_line.

    ls_line-amount = iv_amount.
    IF iv_side = 'L'.
      APPEND ls_line TO mt_left.
    ELSE.
      APPEND ls_line TO mt_right.
    ENDIF.
  ENDMETHOD.

  METHOD computes_balance.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->balance( it_left = mt_left it_right = mt_right )
      exp = 100 ).
  ENDMETHOD.

  METHOD balanced_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_balanced( it_left = mt_left it_right = mt_right )
      exp = abap_false ).
  ENDMETHOD.

  METHOD reads_residual.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->residual( 100 ) exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->residual( -100 ) exp = 100 ).
  ENDMETHOD.

ENDCLASS.
