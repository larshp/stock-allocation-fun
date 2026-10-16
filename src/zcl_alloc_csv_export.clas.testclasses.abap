CLASS ltcl_alloc_csv_export DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut     TYPE REF TO zcl_alloc_csv_export.
    DATA mt_col     TYPE zcl_alloc_columns=>ty_column_tt.
    DATA mt_row     TYPE zcl_alloc_csv_export=>ty_row_tt.
    DATA mt_pending TYPE zcl_alloc_csv_export=>ty_value_tt.

    METHODS setup.

    METHODS add_column
      IMPORTING
        iv_field TYPE string
        iv_title TYPE string.

    METHODS add_cell
      IMPORTING
        iv_field TYPE string
        iv_text  TYPE string.

    METHODS commit_row.

    METHODS empty_input   FOR TESTING.
    METHODS header_line   FOR TESTING.
    METHODS data_line     FOR TESTING.
    METHODS missing_value FOR TESTING.
    METHODS custom_separator FOR TESTING.
    METHODS escapes_quotes FOR TESTING.
    METHODS quotes_in_cell FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_csv_export IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_csv_export( ).
  ENDMETHOD.

  METHOD add_column.
    DATA ls_column TYPE zcl_alloc_columns=>ty_column.

    ls_column-field_name = iv_field.
    ls_column-title = iv_title.
    APPEND ls_column TO mt_col.
  ENDMETHOD.

  METHOD add_cell.
    DATA ls_value TYPE zcl_alloc_csv_export=>ty_value.

    ls_value-field_name = iv_field.
    ls_value-text = iv_text.
    APPEND ls_value TO mt_pending.
  ENDMETHOD.

  METHOD commit_row.
    DATA ls_row TYPE zcl_alloc_csv_export=>ty_row.

    ls_row-values = mt_pending.
    APPEND ls_row TO mt_row.
    CLEAR mt_pending.
  ENDMETHOD.

  METHOD empty_input.
    DATA(lt_lines) = mo_cut->render( it_rows      = mt_row
                                     it_columns   = mt_col
                                     iv_separator = ',' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 0 ).
  ENDMETHOD.

  METHOD header_line.
    add_column( iv_field = 'TITLE' iv_title = 'Title' ).
    add_column( iv_field = 'QTY' iv_title = 'Qty' ).

    DATA(lt_lines) = mo_cut->render( it_rows      = mt_row
                                     it_columns   = mt_col
                                     iv_separator = ',' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ] exp = 'Title,Qty' ).
  ENDMETHOD.

  METHOD data_line.
    add_column( iv_field = 'TITLE' iv_title = 'Title' ).
    add_column( iv_field = 'QTY' iv_title = 'Qty' ).
    add_cell( iv_field = 'TITLE' iv_text = 'Box' ).
    add_cell( iv_field = 'QTY' iv_text = '5' ).
    commit_row( ).

    DATA(lt_lines) = mo_cut->render( it_rows      = mt_row
                                     it_columns   = mt_col
                                     iv_separator = ',' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ] exp = 'Title,Qty' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ] exp = 'Box,5' ).
  ENDMETHOD.

  METHOD missing_value.
    add_column( iv_field = 'TITLE' iv_title = 'Title' ).
    add_column( iv_field = 'QTY' iv_title = 'Qty' ).
    add_cell( iv_field = 'TITLE' iv_text = 'Box' ).
    commit_row( ).

    DATA(lt_lines) = mo_cut->render( it_rows      = mt_row
                                     it_columns   = mt_col
                                     iv_separator = ',' ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ] exp = 'Box,' ).
  ENDMETHOD.

  METHOD custom_separator.
    add_column( iv_field = 'TITLE' iv_title = 'Title' ).
    add_column( iv_field = 'QTY' iv_title = 'Qty' ).

    DATA(lt_lines) = mo_cut->render( it_rows      = mt_row
                                     it_columns   = mt_col
                                     iv_separator = ';' ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ] exp = 'Title;Qty' ).
  ENDMETHOD.

  METHOD escapes_quotes.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->escape( 'plain' ) exp = 'plain' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->escape( 'say "hi"' ) exp = '"say ""hi"""' ).
  ENDMETHOD.

  METHOD quotes_in_cell.
    add_column( iv_field = 'TITLE' iv_title = 'Title' ).
    add_cell( iv_field = 'TITLE' iv_text = 'the "big" box' ).
    commit_row( ).

    DATA(lt_lines) = mo_cut->render( it_rows      = mt_row
                                     it_columns   = mt_col
                                     iv_separator = ',' ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ] exp = '"the ""big"" box"' ).
  ENDMETHOD.

ENDCLASS.
