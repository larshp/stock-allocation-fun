CLASS ltcl_alloc_stdcost_approve DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_stdcost_approve.
    DATA mt_line TYPE zcl_alloc_stdcost_approve=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_version  TYPE string
        iv_approved TYPE abap_bool.

    METHODS approves_all   FOR TESTING.
    METHODS approved_rule  FOR TESTING.
    METHODS counts_pending FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_stdcost_approve IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_stdcost_approve( ).

    add( iv_version = 'V1' iv_approved = abap_true ).
    add( iv_version = 'V2' iv_approved = abap_false ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_stdcost_approve=>ty_line.

    ls_line-version = iv_version.
    ls_line-approved = iv_approved.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD approves_all.
    DATA lt_out TYPE zcl_alloc_stdcost_approve=>ty_line_tt.

    lt_out = mo_cut->approve( mt_line ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_out[ 2 ]-approved exp = abap_true ).
  ENDMETHOD.

  METHOD approved_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_approved( it_lines = mt_line iv_version = 'V1' )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_approved( it_lines = mt_line iv_version = 'V2' )
      exp = abap_false ).
  ENDMETHOD.

  METHOD counts_pending.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->pending_count( mt_line ) exp = 1 ).
  ENDMETHOD.

ENDCLASS.
