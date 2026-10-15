CLASS ltcl_alloc_valm_report DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_valm_report.
    DATA mt_line TYPE zcl_alloc_valm_report=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_value    TYPE i.

    METHODS builds_report  FOR TESTING.
    METHODS counts_breach  FOR TESTING.
    METHODS totals_value   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_valm_report IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_valm_report( ).

    add( iv_material = 'M1' iv_value = 1500 ).
    add( iv_material = 'M2' iv_value = 800 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_valm_report=>ty_line.

    ls_line-material = iv_material.
    ls_line-value = iv_value.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_report.
    DATA ls_rows TYPE zcl_alloc_valm_report=>ty_rows.

    ls_rows = mo_cut->build( it_lines = mt_line iv_threshold = 1000 ).

    cl_abap_unit_assert=>assert_equals( act = ls_rows-total exp = 2300 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_rows-breach_count exp = 1 ).
  ENDMETHOD.

  METHOD counts_breach.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->breach_count( it_lines = mt_line iv_threshold = 1000 )
      exp = 1 ).
  ENDMETHOD.

  METHOD totals_value.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_line ) exp = 2300 ).
  ENDMETHOD.

ENDCLASS.
