CLASS ltcl_alloc_gov_report DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_gov_report.
    DATA mt_line TYPE zcl_alloc_gov_report=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_key  TYPE string
        iv_open TYPE abap_bool.

    METHODS builds_rows  FOR TESTING.
    METHODS counts_items FOR TESTING.
    METHODS counts_open  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_gov_report IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_gov_report( ).

    add( iv_key = 'K1' iv_open = abap_true ).
    add( iv_key = 'K2' iv_open = abap_false ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_gov_report=>ty_line.

    ls_line-key = iv_key.
    ls_line-open = iv_open.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_rows.
    DATA lt_rows TYPE zcl_alloc_gov_report=>ty_row_tt.

    lt_rows = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_rows ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_rows[ 1 ]-status exp = 'OPEN' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_rows[ 2 ]-status exp = 'CLOSED' ).
  ENDMETHOD.

  METHOD counts_items.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->item_count( mt_line ) exp = 2 ).
  ENDMETHOD.

  METHOD counts_open.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->open_count( mt_line ) exp = 1 ).
  ENDMETHOD.

ENDCLASS.
