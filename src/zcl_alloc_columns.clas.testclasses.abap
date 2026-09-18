CLASS ltcl_alloc_columns DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_columns.
    DATA mt_col TYPE zcl_alloc_columns=>ty_column_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_field TYPE string
        iv_title TYPE string
        iv_width TYPE i
        iv_num   TYPE abap_bool.

    METHODS empty_columns FOR TESTING.
    METHODS positions_are_sequential FOR TESTING.
    METHODS default_width FOR TESTING.
    METHODS numeric_alignment FOR TESTING.
    METHODS text_alignment  FOR TESTING.
    METHODS totals_width    FOR TESTING.
    METHODS clamps_width    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_columns IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_columns( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_column TYPE zcl_alloc_columns=>ty_column.

    ls_column-field_name = iv_field.
    ls_column-title = iv_title.
    ls_column-width = iv_width.
    ls_column-numeric = iv_num.
    APPEND ls_column TO mt_col.
  ENDMETHOD.

  METHOD empty_columns.
    DATA(lt_defs) = mo_cut->build( mt_col ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_defs ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_width( lt_defs ) exp = 0 ).
  ENDMETHOD.

  METHOD positions_are_sequential.
    add( iv_field = 'MATNR' iv_title = 'Material' iv_width = 18
         iv_num = abap_false ).
    add( iv_field = 'QTY' iv_title = 'Quantity' iv_width = 12
         iv_num = abap_true ).

    DATA(lt_defs) = mo_cut->build( mt_col ).

    cl_abap_unit_assert=>assert_equals( act = lt_defs[ 1 ]-position exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_defs[ 2 ]-position exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_defs[ 2 ]-field_name exp = 'QTY' ).
  ENDMETHOD.

  METHOD default_width.
    add( iv_field = 'QTY' iv_title = 'Quantity' iv_width = 0
         iv_num = abap_true ).

    DATA(lt_defs) = mo_cut->build( mt_col ).

    cl_abap_unit_assert=>assert_equals( act = lt_defs[ 1 ]-width exp = 10 ).
  ENDMETHOD.

  METHOD numeric_alignment.
    add( iv_field = 'QTY' iv_title = 'Quantity' iv_width = 12
         iv_num = abap_true ).

    DATA(lt_defs) = mo_cut->build( mt_col ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_defs[ 1 ]-right_aligned exp = abap_true ).
  ENDMETHOD.

  METHOD text_alignment.
    add( iv_field = 'MATNR' iv_title = 'Material' iv_width = 18
         iv_num = abap_false ).

    DATA(lt_defs) = mo_cut->build( mt_col ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_defs[ 1 ]-right_aligned exp = abap_false ).
  ENDMETHOD.

  METHOD totals_width.
    add( iv_field = 'MATNR' iv_title = 'Material' iv_width = 18
         iv_num = abap_false ).
    add( iv_field = 'QTY' iv_title = 'Quantity' iv_width = 12
         iv_num = abap_true ).

    DATA(lt_defs) = mo_cut->build( mt_col ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_width( lt_defs ) exp = 30 ).
  ENDMETHOD.

  METHOD clamps_width.
    add( iv_field = 'WIDE' iv_title = 'Wide' iv_width = 9999
         iv_num = abap_false ).
    add( iv_field = 'NEG' iv_title = 'Negative' iv_width = -5
         iv_num = abap_false ).

    DATA(lt_defs) = mo_cut->build( mt_col ).

    cl_abap_unit_assert=>assert_equals( act = lt_defs[ 1 ]-width exp = 255 ).
    cl_abap_unit_assert=>assert_equals( act = lt_defs[ 2 ]-width exp = 10 ).
  ENDMETHOD.

ENDCLASS.
