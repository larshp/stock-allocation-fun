CLASS ltcl_alloc_absorb_summary DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_absorb_summary.
    DATA mt_line TYPE zcl_alloc_absorb_summary=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_name   TYPE string
        iv_amount TYPE i.

    METHODS builds_summary FOR TESTING.
    METHODS sums_total     FOR TESTING.
    METHODS counts_lines   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_absorb_summary IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_absorb_summary( ).

    add( iv_name = 'A' iv_amount = 600 ).
    add( iv_name = 'B' iv_amount = 300 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_absorb_summary=>ty_line.

    ls_line-name = iv_name.
    ls_line-amount = iv_amount.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_summary.
    DATA ls_summary TYPE zcl_alloc_absorb_summary=>ty_summary.

    ls_summary = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-line_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-total exp = 900 ).
  ENDMETHOD.

  METHOD sums_total.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_line ) exp = 900 ).
  ENDMETHOD.

  METHOD counts_lines.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->line_count( mt_line ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
