CLASS ltcl_alloc_tsv_export DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut     TYPE REF TO zcl_alloc_tsv_export.
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

    METHODS separator_is_tab FOR TESTING.
    METHODS header_line      FOR TESTING.
    METHODS data_line        FOR TESTING.
    METHODS empty_input      FOR TESTING.
    METHODS replaces_quotes  FOR TESTING.
    METHODS replaces_tabs    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_tsv_export IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_tsv_export( ).
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

  METHOD separator_is_tab.
    DATA(lv_sep) = mo_cut->separator( ).

    cl_abap_unit_assert=>assert_equals( act = strlen( lv_sep ) exp = 1 ).
  ENDMETHOD.

  METHOD header_line.
    DATA lv_expected TYPE string.

    add_column( iv_field = 'TITLE' iv_title = 'Title' ).
    add_column( iv_field = 'QTY' iv_title = 'Qty' ).

    lv_expected = 'Title' && mo_cut->separator( ).
    lv_expected = lv_expected && 'Qty'.

    DATA(lt_lines) = mo_cut->render( it_rows    = mt_row
                                     it_columns = mt_col ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ] exp = lv_expected ).
  ENDMETHOD.

  METHOD data_line.
    DATA lv_expected TYPE string.

    add_column( iv_field = 'TITLE' iv_title = 'Title' ).
    add_column( iv_field = 'QTY' iv_title = 'Qty' ).
    add_cell( iv_field = 'TITLE' iv_text = 'Box' ).
    add_cell( iv_field = 'QTY' iv_text = '5' ).
    commit_row( ).

    lv_expected = 'Box' && mo_cut->separator( ).
    lv_expected = lv_expected && '5'.

    DATA(lt_lines) = mo_cut->render( it_rows    = mt_row
                                     it_columns = mt_col ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ] exp = lv_expected ).
  ENDMETHOD.

  METHOD empty_input.
    DATA(lt_lines) = mo_cut->render( it_rows    = mt_row
                                     it_columns = mt_col ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 0 ).
  ENDMETHOD.

  METHOD replaces_quotes.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->clean( 'the "big" box' ) exp = `the 'big' box` ).
  ENDMETHOD.

  METHOD replaces_tabs.
    DATA lv_input    TYPE string.
    DATA lv_expected TYPE string.

    lv_input = 'a' && mo_cut->separator( ).
    lv_input = lv_input && 'b'.

    lv_expected = 'a' && ` `.
    lv_expected = lv_expected && 'b'.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->clean( lv_input ) exp = lv_expected ).
  ENDMETHOD.

ENDCLASS.
