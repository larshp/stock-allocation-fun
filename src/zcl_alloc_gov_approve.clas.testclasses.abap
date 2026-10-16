CLASS ltcl_alloc_gov_approve DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_gov_approve.
    DATA mt_line TYPE zcl_alloc_gov_approve=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_key      TYPE string
        iv_approved TYPE abap_bool.

    METHODS approves_item  FOR TESTING.
    METHODS approved_rule  FOR TESTING.
    METHODS counts_pending FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_gov_approve IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_gov_approve( ).

    add( iv_key = 'K1' iv_approved = abap_false ).
    add( iv_key = 'K2' iv_approved = abap_false ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_gov_approve=>ty_line.

    ls_line-key = iv_key.
    ls_line-approved = iv_approved.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD approves_item.
    DATA lt_out TYPE zcl_alloc_gov_approve=>ty_line_tt.

    lt_out = mo_cut->approve( it_lines = mt_line iv_key = 'K1' ).

    cl_abap_unit_assert=>assert_equals( act = lt_out[ 1 ]-approved exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lt_out[ 2 ]-approved exp = abap_false ).
  ENDMETHOD.

  METHOD approved_rule.
    DATA lt_out TYPE zcl_alloc_gov_approve=>ty_line_tt.

    lt_out = mo_cut->approve( it_lines = mt_line iv_key = 'K1' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_approved( it_lines = lt_out iv_key = 'K1' )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_approved( it_lines = lt_out iv_key = 'K2' )
      exp = abap_false ).
  ENDMETHOD.

  METHOD counts_pending.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->pending_count( mt_line ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
