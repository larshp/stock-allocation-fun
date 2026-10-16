CLASS ltcl_alloc_prep_export DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_prep_export.
    DATA mt_line TYPE zcl_alloc_prep_export=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_order TYPE string
        iv_cost  TYPE i.

    METHODS exports_rows FOR TESTING.
    METHODS counts_rows  FOR TESTING.
    METHODS empty_rule   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_prep_export IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_prep_export( ).

    add( iv_order = 'O1' iv_cost = 100 ).
    add( iv_order = 'O2' iv_cost = 300 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_prep_export=>ty_line.

    ls_line-order_id = iv_order.
    ls_line-cost = iv_cost.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD exports_rows.
    DATA lt_rows TYPE zcl_alloc_prep_export=>ty_string_tt.

    lt_rows = mo_cut->export_rows( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_rows ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 1 ] exp = 'O1;100' ).
  ENDMETHOD.

  METHOD counts_rows.
    DATA lt_rows TYPE zcl_alloc_prep_export=>ty_string_tt.

    lt_rows = mo_cut->export_rows( mt_line ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->row_count( lt_rows ) exp = 2 ).
  ENDMETHOD.

  METHOD empty_rule.
    DATA lt_empty TYPE zcl_alloc_prep_export=>ty_line_tt.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_empty( lt_empty ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_empty( mt_line ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
