CLASS ltcl_alloc_return_advice DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_advice.
    DATA mt_fld TYPE zcl_alloc_return_advice=>ty_field_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_name  TYPE string
        iv_value TYPE string.

    METHODS joins_fields  FOR TESTING.
    METHODS skips_blank   FOR TESTING.
    METHODS counts_fields FOR TESTING.
    METHODS empty_input   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_advice IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_advice( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_field TYPE zcl_alloc_return_advice=>ty_field.

    ls_field-name = iv_name.
    ls_field-value = iv_value.
    APPEND ls_field TO mt_fld.
  ENDMETHOD.

  METHOD joins_fields.
    add( iv_name = 'RMA' iv_value = 'R1' ).
    add( iv_name = 'QTY' iv_value = '5' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( mt_fld ) exp = 'RMA=R1; QTY=5' ).
  ENDMETHOD.

  METHOD skips_blank.
    add( iv_name = '' iv_value = 'X' ).
    add( iv_name = 'RMA' iv_value = 'R1' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( mt_fld ) exp = 'RMA=R1' ).
  ENDMETHOD.

  METHOD counts_fields.
    add( iv_name = 'RMA' iv_value = 'R1' ).
    add( iv_name = '' iv_value = 'X' ).
    add( iv_name = 'QTY' iv_value = '5' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->field_count( mt_fld ) exp = 2 ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( mt_fld ) exp = '' ).
  ENDMETHOD.

ENDCLASS.
