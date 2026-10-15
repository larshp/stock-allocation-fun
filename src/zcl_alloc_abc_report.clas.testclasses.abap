CLASS ltcl_alloc_abc_report DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_abc_report.
    DATA mt_line TYPE zcl_alloc_abc_report=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_activity TYPE string
        iv_cost     TYPE i.

    METHODS builds_rows FOR TESTING.
    METHODS totals_cost FOR TESTING.
    METHODS counts_lines FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_abc_report IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_abc_report( ).

    add( iv_activity = 'A' iv_cost = 600 ).
    add( iv_activity = 'B' iv_cost = 300 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_abc_report=>ty_line.

    ls_line-activity = iv_activity.
    ls_line-cost = iv_cost.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_rows.
    DATA lt_rows TYPE zcl_alloc_abc_report=>ty_line_tt.

    lt_rows = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_rows ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_rows[ 1 ]-activity exp = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 2 ]-cost exp = 300 ).
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
