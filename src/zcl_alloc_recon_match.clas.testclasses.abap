CLASS ltcl_alloc_recon_match DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_recon_match.
    DATA mt_left TYPE zcl_alloc_recon_match=>ty_line_tt.
    DATA mt_right TYPE zcl_alloc_recon_match=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_side   TYPE string
        iv_key    TYPE string
        iv_amount TYPE i.

    METHODS matches_keys FOR TESTING.
    METHODS matched_rule FOR TESTING.
    METHODS builds_key   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_recon_match IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_recon_match( ).

    add( iv_side = 'L' iv_key = 'K1' iv_amount = 900 ).
    add( iv_side = 'R' iv_key = 'K1' iv_amount = 900 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_recon_match=>ty_line.

    ls_line-key = iv_key.
    ls_line-amount = iv_amount.

    IF iv_side = 'L'.
      APPEND ls_line TO mt_left.
    ELSE.
      APPEND ls_line TO mt_right.
    ENDIF.
  ENDMETHOD.

  METHOD matches_keys.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->matches( it_left = mt_left it_right = mt_right iv_key = 'K1' )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->matches( it_left = mt_left it_right = mt_right iv_key = 'K9' )
      exp = abap_false ).
  ENDMETHOD.

  METHOD matched_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_matched( iv_amount_a = 900 iv_amount_b = 900 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_matched( iv_amount_a = 900 iv_amount_b = 800 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD builds_key.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->key_of( iv_prefix = 'K' iv_index = 3 )
      exp = 'K-3' ).
  ENDMETHOD.

ENDCLASS.
