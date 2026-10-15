CLASS ltcl_alloc_val_detail DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_val_detail.
    DATA mt_line TYPE zcl_alloc_val_detail=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material  TYPE matnr
        iv_quantity  TYPE i
        iv_unit_cost TYPE i.

    METHODS reads_detail   FOR TESTING.
    METHODS totals_material FOR TESTING.
    METHODS counts_lines   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_val_detail IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_val_detail( ).

    add( iv_material = 'M1' iv_quantity = 100 iv_unit_cost = 10 ).
    add( iv_material = 'M2' iv_quantity = 50 iv_unit_cost = 12 ).
    add( iv_material = 'M1' iv_quantity = 20 iv_unit_cost = 10 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_val_detail=>ty_line.

    ls_line-material = iv_material.
    ls_line-quantity = iv_quantity.
    ls_line-unit_cost = iv_unit_cost.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD reads_detail.
    DATA lt_values TYPE zcl_alloc_val_detail=>ty_values_tt.

    lt_values = mo_cut->detail( it_lines = mt_line iv_material = 'M1' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_values ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_values[ 1 ] exp = 1000 ).
    cl_abap_unit_assert=>assert_equals( act = lt_values[ 2 ] exp = 200 ).
  ENDMETHOD.

  METHOD totals_material.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->for_material( it_lines = mt_line iv_material = 'M1' )
      exp = 1200 ).
  ENDMETHOD.

  METHOD counts_lines.
    DATA lt_values TYPE zcl_alloc_val_detail=>ty_values_tt.

    lt_values = mo_cut->detail( it_lines = mt_line iv_material = 'M1' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->line_count( lt_values ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
