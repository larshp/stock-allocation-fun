CLASS ltcl_alloc_csv_excel DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut     TYPE REF TO zcl_alloc_csv_excel.
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

    METHODS separator_is_semicolon FOR TESTING.
    METHODS hint_line              FOR TESTING.
    METHODS renders_with_hint      FOR TESTING.
    METHODS empty_input            FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_csv_excel IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_csv_excel( ).
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

  METHOD separator_is_semicolon.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->separator( ) exp = ';' ).
  ENDMETHOD.

  METHOD hint_line.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->hint( ) exp = 'sep=;' ).
  ENDMETHOD.

  METHOD renders_with_hint.
    add_column( iv_field = 'TITLE' iv_title = 'Title' ).
    add_column( iv_field = 'QTY' iv_title = 'Qty' ).
    add_cell( iv_field = 'TITLE' iv_text = 'Box' ).
    add_cell( iv_field = 'QTY' iv_text = '5' ).
    commit_row( ).

    DATA(lt_lines) = mo_cut->render( it_rows    = mt_row
                                     it_columns = mt_col ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ] exp = 'sep=;' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ] exp = 'Title;Qty' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ] exp = 'Box;5' ).
  ENDMETHOD.

  METHOD empty_input.
    DATA(lt_lines) = mo_cut->render( it_rows    = mt_row
                                     it_columns = mt_col ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ] exp = 'sep=;' ).
  ENDMETHOD.

ENDCLASS.
