CLASS ltcl_alloc_abc_summary DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_abc_summary.
    DATA mt_line TYPE zcl_alloc_abc_summary=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_activity TYPE string
        iv_cost     TYPE i.

    METHODS builds_summary FOR TESTING.
    METHODS totals_cost    FOR TESTING.
    METHODS counts_lines   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_abc_summary IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_abc_summary( ).

    add( iv_activity = 'A' iv_cost = 600 ).
    add( iv_activity = 'B' iv_cost = 300 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_abc_summary=>ty_line.

    ls_line-activity = iv_activity.
    ls_line-cost = iv_cost.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_summary.
    DATA ls_summary TYPE zcl_alloc_abc_summary=>ty_summary.

    ls_summary = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-line_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-total_cost exp = 900 ).
  ENDMETHOD.

  METHOD totals_cost.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_cost( mt_line ) exp = 900 ).
  ENDMETHOD.

  METHOD counts_lines.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->line_count( mt_line ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
