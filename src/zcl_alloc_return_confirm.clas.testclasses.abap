CLASS ltcl_alloc_return_confirm DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_confirm.
    DATA mt_lin TYPE zcl_alloc_return_confirm=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_quantity TYPE i.

    METHODS builds_text    FOR TESTING.
    METHODS header_line    FOR TESTING.
    METHODS counts_lines   FOR TESTING.
    METHODS empty_input    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_confirm IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_confirm( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_return_confirm=>ty_line.

    ls_line-material = iv_material.
    ls_line-quantity = iv_quantity.
    APPEND ls_line TO mt_lin.
  ENDMETHOD.

  METHOD builds_text.
    DATA lt_text TYPE zcl_alloc_return_confirm=>ty_text_tt.

    add( iv_material = 'M1' iv_quantity = 5 ).
    add( iv_material = 'M2' iv_quantity = 3 ).

    lt_text = mo_cut->build( it_lines = mt_lin iv_rma = 'R1' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_text ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_text[ 1 ] exp = 'Return R1 confirmation' ).
    cl_abap_unit_assert=>assert_equals( act = lt_text[ 2 ] exp = '1: 5 units' ).
    cl_abap_unit_assert=>assert_equals( act = lt_text[ 3 ] exp = '2: 3 units' ).
  ENDMETHOD.

  METHOD header_line.
    DATA lt_text TYPE zcl_alloc_return_confirm=>ty_text_tt.

    lt_text = mo_cut->build( it_lines = mt_lin iv_rma = 'R2' ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_text[ 1 ] exp = 'Return R2 confirmation' ).
  ENDMETHOD.

  METHOD counts_lines.
    add( iv_material = 'M1' iv_quantity = 5 ).
    add( iv_material = 'M2' iv_quantity = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->line_count( mt_lin ) exp = 2 ).
  ENDMETHOD.

  METHOD empty_input.
    DATA lt_text TYPE zcl_alloc_return_confirm=>ty_text_tt.

    lt_text = mo_cut->build( it_lines = mt_lin iv_rma = 'R1' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_text ) exp = 1 ).
  ENDMETHOD.

ENDCLASS.
