CLASS ltcl_alloc_var_summary DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_var_summary.
    DATA mt_line TYPE zcl_alloc_var_summary=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_name     TYPE string
        iv_variance TYPE i.

    METHODS builds_summary FOR TESTING.
    METHODS nets_total     FOR TESTING.
    METHODS counts_lines   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_var_summary IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_var_summary( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_var_summary=>ty_line.

    ls_line-name = iv_name.
    ls_line-variance = iv_variance.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_summary.
    DATA ls_summary TYPE zcl_alloc_var_summary=>ty_summary.

    add( iv_name = 'PRICE' iv_variance = 200 ).
    add( iv_name = 'QUANTITY' iv_variance = -50 ).

    ls_summary = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-line_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-total exp = 150 ).
  ENDMETHOD.

  METHOD nets_total.
    add( iv_name = 'PRICE' iv_variance = 200 ).
    add( iv_name = 'QUANTITY' iv_variance = -50 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_line ) exp = 150 ).
  ENDMETHOD.

  METHOD counts_lines.
    add( iv_name = 'PRICE' iv_variance = 200 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->line_count( mt_line ) exp = 1 ).
  ENDMETHOD.

ENDCLASS.
