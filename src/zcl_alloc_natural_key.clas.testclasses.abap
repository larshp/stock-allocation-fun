CLASS ltcl_alloc_natural_key DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_natural_key.

    METHODS setup.

    METHODS composes_fields     FOR TESTING.
    METHODS counts_fields       FOR TESTING.
    METHODS reads_first_field   FOR TESTING.
    METHODS reads_second_field  FOR TESTING.
    METHODS unknown_index_empty FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_natural_key IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_natural_key( ).
  ENDMETHOD.

  METHOD composes_fields.
    DATA lt_fields TYPE zcl_alloc_natural_key=>ty_fields_tt.
    DATA lv_key    TYPE string.

    APPEND |MATNR| TO lt_fields.
    APPEND |1000| TO lt_fields.

    lv_key = mo_cut->compose( lt_fields ).

    cl_abap_unit_assert=>assert_equals( act = strlen( lv_key ) exp = 40 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->field_count( lv_key ) exp = 2 ).
  ENDMETHOD.

  METHOD counts_fields.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->field_count( '' ) exp = 0 ).
  ENDMETHOD.

  METHOD reads_first_field.
    DATA lt_fields TYPE zcl_alloc_natural_key=>ty_fields_tt.
    DATA lv_key    TYPE string.
    DATA lv_field  TYPE string.

    APPEND |MATNR| TO lt_fields.
    APPEND |1000| TO lt_fields.

    lv_key = mo_cut->compose( lt_fields ).
    lv_field = mo_cut->field_at( iv_key = lv_key iv_index = 1 ).

    cl_abap_unit_assert=>assert_equals( act = lv_field exp = 'MATNR' ).
  ENDMETHOD.

  METHOD reads_second_field.
    DATA lt_fields TYPE zcl_alloc_natural_key=>ty_fields_tt.
    DATA lv_key    TYPE string.
    DATA lv_field  TYPE string.

    APPEND |MATNR| TO lt_fields.
    APPEND |1000| TO lt_fields.

    lv_key = mo_cut->compose( lt_fields ).
    lv_field = mo_cut->field_at( iv_key = lv_key iv_index = 2 ).

    cl_abap_unit_assert=>assert_equals( act = lv_field exp = '1000' ).
  ENDMETHOD.

  METHOD unknown_index_empty.
    DATA lv_field TYPE string.

    lv_field = mo_cut->field_at( iv_key = 'MATNR' iv_index = 3 ).

    cl_abap_unit_assert=>assert_equals( act = lv_field exp = '' ).
  ENDMETHOD.

ENDCLASS.
