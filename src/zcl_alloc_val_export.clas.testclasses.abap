CLASS ltcl_alloc_val_export DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_val_export.
    DATA mt_line TYPE zcl_alloc_val_export=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_value    TYPE i.

    METHODS exports_rows FOR TESTING.
    METHODS writes_text  FOR TESTING.
    METHODS counts_rows  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_val_export IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_val_export( ).

    add( iv_material = 'M1' iv_value = 1000 ).
    add( iv_material = 'M2' iv_value = 600 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_val_export=>ty_line.

    ls_line-material = iv_material.
    ls_line-value = iv_value.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD exports_rows.
    DATA lt_values TYPE zcl_alloc_val_export=>ty_values_tt.

    lt_values = mo_cut->to_rows( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_values ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_values[ 1 ] exp = 1000 ).
    cl_abap_unit_assert=>assert_equals( act = lt_values[ 2 ] exp = 600 ).
  ENDMETHOD.

  METHOD writes_text.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->to_text( 1000 ) exp = '1000' ).
  ENDMETHOD.

  METHOD counts_rows.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->row_count( mt_line ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
