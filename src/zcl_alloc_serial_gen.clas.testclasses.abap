CLASS ltcl_alloc_serial_gen DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_serial_gen.

    METHODS setup.

    METHODS pads_to_width  FOR TESTING.
    METHODS longer_than_w  FOR TESTING.
    METHODS with_prefix    FOR TESTING.
    METHODS range_numbers   FOR TESTING.
    METHODS range_empty     FOR TESTING.
    METHODS counter_advances FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_serial_gen IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_serial_gen( ).
  ENDMETHOD.

  METHOD pads_to_width.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->generate( iv_number = 7 iv_width = 4 iv_prefix = '' )
      exp = '0007' ).
  ENDMETHOD.

  METHOD longer_than_w.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->generate( iv_number = 12345 iv_width = 4 iv_prefix = '' )
      exp = '12345' ).
  ENDMETHOD.

  METHOD with_prefix.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->generate( iv_number = 7 iv_width = 4 iv_prefix = 'SN' )
      exp = 'SN0007' ).
  ENDMETHOD.

  METHOD range_numbers.
    DATA lt_serials TYPE zcl_alloc_serial_gen=>ty_text_tt.

    lt_serials = mo_cut->generate_range( iv_from = 5 iv_count = 3
                                         iv_width = 3 iv_prefix = 'S' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_serials ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_serials[ 1 ] exp = 'S005' ).
    cl_abap_unit_assert=>assert_equals( act = lt_serials[ 3 ] exp = 'S007' ).
  ENDMETHOD.

  METHOD range_empty.
    DATA lt_serials TYPE zcl_alloc_serial_gen=>ty_text_tt.

    lt_serials = mo_cut->generate_range( iv_from = 5 iv_count = 0
                                         iv_width = 3 iv_prefix = 'S' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_serials ) exp = 0 ).
  ENDMETHOD.

  METHOD counter_advances.
    mo_cut->set_next( iv_number = 9 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->next_serial( iv_width = 2 iv_prefix = '' )
      exp = '09' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->next_serial( iv_width = 2 iv_prefix = '' )
      exp = '10' ).
  ENDMETHOD.

ENDCLASS.
