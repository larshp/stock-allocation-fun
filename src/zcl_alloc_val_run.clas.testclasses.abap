CLASS ltcl_alloc_val_run DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_val_run.
    DATA mt_line TYPE zcl_alloc_val_run=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_quantity TYPE i
        iv_price    TYPE i.

    METHODS builds_result FOR TESTING.
    METHODS counts_lines  FOR TESTING.
    METHODS sums_value    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_val_run IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_val_run( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_val_run=>ty_line.

    ls_line-material = iv_material.
    ls_line-quantity = iv_quantity.
    ls_line-price = iv_price.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_result.
    DATA ls_result TYPE zcl_alloc_val_run=>ty_result.

    add( iv_material = 'M1' iv_quantity = 100 iv_price = 10 ).
    add( iv_material = 'M2' iv_quantity = 50 iv_price = 12 ).

    ls_result = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-line_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-total_value exp = 1600 ).
  ENDMETHOD.

  METHOD counts_lines.
    add( iv_material = 'M1' iv_quantity = 100 iv_price = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->line_count( mt_line ) exp = 1 ).
  ENDMETHOD.

  METHOD sums_value.
    add( iv_material = 'M1' iv_quantity = 100 iv_price = 10 ).
    add( iv_material = 'M2' iv_quantity = 50 iv_price = 12 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_value( mt_line ) exp = 1600 ).
  ENDMETHOD.

ENDCLASS.
