CLASS ltcl_alloc_margin_summary DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_margin_summary.
    DATA mt_line TYPE zcl_alloc_margin_summary=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_revenue  TYPE i
        iv_cogs     TYPE i.

    METHODS builds_summary FOR TESTING.
    METHODS nets_margin    FOR TESTING.
    METHODS counts_lines   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_margin_summary IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_margin_summary( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_margin_summary=>ty_line.

    ls_line-material = iv_material.
    ls_line-revenue = iv_revenue.
    ls_line-cogs = iv_cogs.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_summary.
    DATA ls_summary TYPE zcl_alloc_margin_summary=>ty_summary.

    add( iv_material = 'M1' iv_revenue = 1500 iv_cogs = 1000 ).
    add( iv_material = 'M2' iv_revenue = 800 iv_cogs = 500 ).

    ls_summary = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-line_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-total_margin exp = 800 ).
  ENDMETHOD.

  METHOD nets_margin.
    add( iv_material = 'M1' iv_revenue = 1500 iv_cogs = 1000 ).
    add( iv_material = 'M2' iv_revenue = 800 iv_cogs = 500 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_margin( mt_line ) exp = 800 ).
  ENDMETHOD.

  METHOD counts_lines.
    add( iv_material = 'M1' iv_revenue = 1500 iv_cogs = 1000 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->line_count( mt_line ) exp = 1 ).
  ENDMETHOD.

ENDCLASS.
