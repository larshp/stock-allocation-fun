CLASS ltcl_alloc_qr_payload DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_qr_payload.
    DATA mt_fie TYPE zcl_alloc_qr_payload=>ty_field_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_key   TYPE string
        iv_value TYPE string.

    METHODS joins_pairs    FOR TESTING.
    METHODS empty_payload  FOR TESTING.
    METHODS skips_no_key   FOR TESTING.
    METHODS counts_keys    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_qr_payload IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_qr_payload( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_field TYPE zcl_alloc_qr_payload=>ty_field.

    ls_field-field_key = iv_key.
    ls_field-field_value = iv_value.
    APPEND ls_field TO mt_fie.
  ENDMETHOD.

  METHOD joins_pairs.
    add( iv_key = 'GTIN' iv_value = '003401234500000019' ).
    add( iv_key = 'BATCH' iv_value = 'B001' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( it_fields = mt_fie iv_separator = ';' )
      exp = 'GTIN=003401234500000019;BATCH=B001' ).
  ENDMETHOD.

  METHOD empty_payload.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( it_fields = mt_fie iv_separator = ';' )
      exp = '' ).
  ENDMETHOD.

  METHOD skips_no_key.
    add( iv_key = '' iv_value = 'ORPHAN' ).
    add( iv_key = 'A' iv_value = '1' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( it_fields = mt_fie iv_separator = '|' )
      exp = 'A=1' ).
  ENDMETHOD.

  METHOD counts_keys.
    add( iv_key = 'A' iv_value = '1' ).
    add( iv_key = '' iv_value = '2' ).
    add( iv_key = 'B' iv_value = '3' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count( mt_fie ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
