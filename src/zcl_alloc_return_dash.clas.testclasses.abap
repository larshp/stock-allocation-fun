CLASS ltcl_alloc_return_dash DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_dash.
    DATA mt_lin TYPE zcl_alloc_return_dash=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_label TYPE string
        iv_value TYPE i.

    METHODS builds_lines FOR TESTING.
    METHODS drops_blank  FOR TESTING.
    METHODS counts_lines FOR TESTING.
    METHODS joins_lines  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_dash IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_dash( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_return_dash=>ty_line.

    ls_line-label = iv_label.
    ls_line-value = iv_value.
    APPEND ls_line TO mt_lin.
  ENDMETHOD.

  METHOD builds_lines.
    DATA lt_text TYPE zcl_alloc_return_dash=>ty_text_tt.

    add( iv_label = 'Returns' iv_value = 25 ).
    add( iv_label = 'Value' iv_value = 250 ).

    lt_text = mo_cut->build( mt_lin ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_text ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_text[ 1 ] exp = 'Returns: 25' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_text[ 2 ] exp = 'Value: 250' ).
  ENDMETHOD.

  METHOD drops_blank.
    DATA lt_text TYPE zcl_alloc_return_dash=>ty_text_tt.

    add( iv_label = '' iv_value = 5 ).
    add( iv_label = 'Returns' iv_value = 25 ).

    lt_text = mo_cut->build( mt_lin ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_text ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_text[ 1 ] exp = 'Returns: 25' ).
  ENDMETHOD.

  METHOD counts_lines.
    add( iv_label = 'Returns' iv_value = 25 ).
    add( iv_label = '' iv_value = 5 ).
    add( iv_label = 'Value' iv_value = 250 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->line_count( mt_lin ) exp = 2 ).
  ENDMETHOD.

  METHOD joins_lines.
    add( iv_label = 'Returns' iv_value = 25 ).
    add( iv_label = 'Value' iv_value = 250 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->join( mt_lin )
      exp = 'Returns: 25; Value: 250' ).
  ENDMETHOD.

ENDCLASS.
