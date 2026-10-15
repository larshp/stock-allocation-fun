CLASS ltcl_alloc_replenish_dash DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_replenish_dash.
    DATA mt_row TYPE zcl_alloc_replenish_dash=>ty_row_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_label TYPE string
        iv_value TYPE i.

    METHODS builds_lines FOR TESTING.
    METHODS counts_lines FOR TESTING.
    METHODS joins_lines  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_replenish_dash IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_replenish_dash( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_row TYPE zcl_alloc_replenish_dash=>ty_row.

    ls_row-label = iv_label.
    ls_row-value = iv_value.
    APPEND ls_row TO mt_row.
  ENDMETHOD.

  METHOD builds_lines.
    DATA lt_lines TYPE zcl_alloc_replenish_dash=>ty_lines_tt.

    add( iv_label = 'FILL' iv_value = 80 ).
    add( iv_label = 'OTD' iv_value = 90 ).

    lt_lines = mo_cut->build( mt_row ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ] exp = 'FILL: 80' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ] exp = 'OTD: 90' ).
  ENDMETHOD.

  METHOD counts_lines.
    add( iv_label = 'FILL' iv_value = 80 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->line_count( mt_row ) exp = 1 ).
  ENDMETHOD.

  METHOD joins_lines.
    DATA lt_lines TYPE zcl_alloc_replenish_dash=>ty_lines_tt.

    add( iv_label = 'FILL' iv_value = 80 ).
    add( iv_label = 'OTD' iv_value = 90 ).

    lt_lines = mo_cut->build( mt_row ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->join( lt_lines ) exp = 'FILL: 80; OTD: 90' ).
  ENDMETHOD.

ENDCLASS.
