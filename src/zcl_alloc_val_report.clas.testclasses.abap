CLASS ltcl_alloc_val_report DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_val_report.
    DATA mt_line TYPE zcl_alloc_val_report=>ty_line_tt.
    DATA mt_row TYPE zcl_alloc_val_report=>ty_row_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material  TYPE matnr
        iv_quantity  TYPE i
        iv_unit_cost TYPE i.

    METHODS builds_rows  FOR TESTING.
    METHODS counts_rows  FOR TESTING.
    METHODS totals_value FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_val_report IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_val_report( ).

    add( iv_material = 'M1' iv_quantity = 100 iv_unit_cost = 10 ).
    add( iv_material = 'M2' iv_quantity = 50 iv_unit_cost = 12 ).

    mt_row = mo_cut->build( mt_line ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_val_report=>ty_line.

    ls_line-material = iv_material.
    ls_line-quantity = iv_quantity.
    ls_line-unit_cost = iv_unit_cost.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_rows.
    cl_abap_unit_assert=>assert_equals( act = lines( mt_row ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = mt_row[ 1 ]-value exp = 1000 ).
    cl_abap_unit_assert=>assert_equals( act = mt_row[ 2 ]-value exp = 600 ).
  ENDMETHOD.

  METHOD counts_rows.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->row_count( mt_row ) exp = 2 ).
  ENDMETHOD.

  METHOD totals_value.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_value( mt_row ) exp = 1600 ).
  ENDMETHOD.

ENDCLASS.
