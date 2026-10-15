CLASS ltcl_alloc_replenish_run DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_replenish_run.
    DATA mt_line TYPE zcl_alloc_replenish_run=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_quantity TYPE i.

    METHODS builds_run   FOR TESTING.
    METHODS counts_lines FOR TESTING.
    METHODS sums_quantity FOR TESTING.
    METHODS empty_input  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_replenish_run IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_replenish_run( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_replenish_run=>ty_line.

    ls_line-material = iv_material.
    ls_line-quantity = iv_quantity.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_run.
    DATA ls_run TYPE zcl_alloc_replenish_run=>ty_run.

    add( iv_material = 'M1' iv_quantity = 10 ).
    add( iv_material = 'M2' iv_quantity = 5 ).

    ls_run = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = ls_run-line_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_run-total_quantity exp = 15 ).
  ENDMETHOD.

  METHOD counts_lines.
    add( iv_material = 'M1' iv_quantity = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->line_count( mt_line ) exp = 1 ).
  ENDMETHOD.

  METHOD sums_quantity.
    add( iv_material = 'M1' iv_quantity = 10 ).
    add( iv_material = 'M2' iv_quantity = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_quantity( mt_line ) exp = 15 ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_quantity( mt_line ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
