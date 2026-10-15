CLASS ltcl_alloc_gov_summary DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_gov_summary.
    DATA mt_line TYPE zcl_alloc_gov_summary=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_key      TYPE string
        iv_approved TYPE abap_bool.

    METHODS builds_summary FOR TESTING.
    METHODS counts_items   FOR TESTING.
    METHODS counts_approved FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_gov_summary IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_gov_summary( ).

    add( iv_key = 'K1' iv_approved = abap_true ).
    add( iv_key = 'K2' iv_approved = abap_false ).
    add( iv_key = 'K3' iv_approved = abap_true ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_gov_summary=>ty_line.

    ls_line-key = iv_key.
    ls_line-approved = iv_approved.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_summary.
    DATA ls_summary TYPE zcl_alloc_gov_summary=>ty_summary.

    ls_summary = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-item_count exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-approved_count exp = 2 ).
  ENDMETHOD.

  METHOD counts_items.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->item_count( mt_line ) exp = 3 ).
  ENDMETHOD.

  METHOD counts_approved.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->approved_count( mt_line ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
