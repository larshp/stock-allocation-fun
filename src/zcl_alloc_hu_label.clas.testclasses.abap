CLASS ltcl_alloc_hu_label DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_hu_label.
    DATA mt_fld TYPE zcl_alloc_hu_label=>ty_field_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_name  TYPE string
        iv_value TYPE string.

    METHODS title_first    FOR TESTING.
    METHODS appends_fields FOR TESTING.
    METHODS skips_no_name  FOR TESTING.
    METHODS no_title       FOR TESTING.
    METHODS empty_input    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_hu_label IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_hu_label( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_field TYPE zcl_alloc_hu_label=>ty_field.

    ls_field-name = iv_name.
    ls_field-value = iv_value.
    APPEND ls_field TO mt_fld.
  ENDMETHOD.

  METHOD title_first.
    DATA lt_lines TYPE zcl_alloc_hu_label=>ty_lines_tt.

    add( iv_name = 'HU' iv_value = 'HU-1' ).

    lt_lines = mo_cut->build( iv_title = 'Label' it_fields = mt_fld ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ] exp = 'Label' ).
  ENDMETHOD.

  METHOD appends_fields.
    DATA lt_lines TYPE zcl_alloc_hu_label=>ty_lines_tt.

    add( iv_name = 'HU' iv_value = 'HU-1' ).
    add( iv_name = 'BIN' iv_value = 'A-01' ).

    lt_lines = mo_cut->build( iv_title = 'Label' it_fields = mt_fld ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ] exp = 'HU: HU-1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ] exp = 'BIN: A-01' ).
  ENDMETHOD.

  METHOD skips_no_name.
    DATA lt_lines TYPE zcl_alloc_hu_label=>ty_lines_tt.

    add( iv_name = '' iv_value = 'ignored' ).
    add( iv_name = 'HU' iv_value = 'HU-1' ).

    lt_lines = mo_cut->build( iv_title = '' it_fields = mt_fld ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ] exp = 'HU: HU-1' ).
  ENDMETHOD.

  METHOD no_title.
    DATA lt_lines TYPE zcl_alloc_hu_label=>ty_lines_tt.

    add( iv_name = 'HU' iv_value = 'HU-1' ).

    lt_lines = mo_cut->build( iv_title = '' it_fields = mt_fld ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ] exp = 'HU: HU-1' ).
  ENDMETHOD.

  METHOD empty_input.
    DATA lt_lines TYPE zcl_alloc_hu_label=>ty_lines_tt.

    lt_lines = mo_cut->build( iv_title = '' it_fields = mt_fld ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
