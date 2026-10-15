CLASS ltcl_alloc_recon_report DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_recon_report.
    DATA mt_line TYPE zcl_alloc_recon_report=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_key  TYPE string
        iv_diff TYPE i.

    METHODS builds_rows FOR TESTING.
    METHODS counts_diffs FOR TESTING.
    METHODS totals_diffs FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_recon_report IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_recon_report( ).

    add( iv_key = 'K1' iv_diff = 100 ).
    add( iv_key = 'K2' iv_diff = -50 ).
    add( iv_key = 'K3' iv_diff = 0 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_recon_report=>ty_line.

    ls_line-key = iv_key.
    ls_line-diff = iv_diff.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_rows.
    DATA lt_rows TYPE zcl_alloc_recon_report=>ty_row_tt.

    lt_rows = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_rows ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_rows[ 1 ]-magnitude exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_rows[ 2 ]-magnitude exp = 50 ).
  ENDMETHOD.

  METHOD counts_diffs.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->diff_count( mt_line ) exp = 2 ).
  ENDMETHOD.

  METHOD totals_diffs.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_diff( mt_line ) exp = 150 ).
  ENDMETHOD.

ENDCLASS.
