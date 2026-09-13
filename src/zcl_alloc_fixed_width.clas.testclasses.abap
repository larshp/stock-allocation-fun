CLASS ltcl_alloc_fixed_width DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_fixed_width.

    METHODS setup.

    METHODS spaces
      IMPORTING
        iv_count       TYPE i
      RETURNING
        VALUE(rv_text) TYPE string.

    METHODS short_value_is_padded  FOR TESTING.
    METHODS long_value_is_cut     FOR TESTING.
    METHODS exact_width_kept      FOR TESTING.
    METHODS zero_width_kept       FOR TESTING.
    METHODS line_uses_widths      FOR TESTING.
    METHODS missing_width_kept    FOR TESTING.
    METHODS empty_fields_line     FOR TESTING.
    METHODS trailing_blank_probe  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_fixed_width IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_fixed_width( ).
  ENDMETHOD.

  METHOD spaces.
    DATA lv_count TYPE i.

    CLEAR rv_text.
    lv_count = iv_count.
    WHILE lv_count > 0.
      rv_text = rv_text && ` `.
      lv_count = lv_count - 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD short_value_is_padded.
    DATA lv_expected TYPE string.
    DATA lv_padding  TYPE string.

    lv_padding = spaces( 3 ).
    lv_expected = 'AB'.
    lv_expected = lv_expected && lv_padding.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->pad( iv_value = 'AB' iv_width = 5 )
      exp = lv_expected ).
  ENDMETHOD.

  METHOD long_value_is_cut.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->pad( iv_value = 'ABCDEF' iv_width = 3 )
      exp = 'ABC' ).
  ENDMETHOD.

  METHOD exact_width_kept.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->pad( iv_value = 'ABCD' iv_width = 4 )
      exp = 'ABCD' ).
  ENDMETHOD.

  METHOD zero_width_kept.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->pad( iv_value = 'ABCD' iv_width = 0 )
      exp = 'ABCD' ).
  ENDMETHOD.

  METHOD line_uses_widths.
    DATA lt_fields   TYPE zcl_alloc_fixed_width=>ty_field_tt.
    DATA lt_widths   TYPE zcl_alloc_fixed_width=>ty_width_tt.
    DATA lv_padding  TYPE string.
    DATA lv_expected TYPE string.

    APPEND 'AB' TO lt_fields.
    APPEND 'CDEF' TO lt_fields.
    APPEND 4 TO lt_widths.
    APPEND 2 TO lt_widths.

    lv_padding = spaces( 2 ).
    lv_expected = 'AB'.
    lv_expected = lv_expected && lv_padding.
    lv_expected = lv_expected && 'CD'.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build_line( it_fields = lt_fields
                                it_widths = lt_widths )
      exp = lv_expected ).
  ENDMETHOD.

  METHOD missing_width_kept.
    DATA lt_fields   TYPE zcl_alloc_fixed_width=>ty_field_tt.
    DATA lt_widths   TYPE zcl_alloc_fixed_width=>ty_width_tt.
    DATA lv_padding  TYPE string.
    DATA lv_expected TYPE string.

    APPEND 'AB' TO lt_fields.
    APPEND 'CD' TO lt_fields.
    APPEND 3 TO lt_widths.

    lv_padding = spaces( 1 ).
    lv_expected = 'AB'.
    lv_expected = lv_expected && lv_padding.
    lv_expected = lv_expected && 'CD'.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build_line( it_fields = lt_fields
                                it_widths = lt_widths )
      exp = lv_expected ).
  ENDMETHOD.

  METHOD empty_fields_line.
    DATA lt_fields TYPE zcl_alloc_fixed_width=>ty_field_tt.
    DATA lt_widths TYPE zcl_alloc_fixed_width=>ty_width_tt.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build_line( it_fields = lt_fields
                                it_widths = lt_widths )
      exp = '' ).
  ENDMETHOD.

  METHOD trailing_blank_probe.
    DATA lv_text  TYPE string.
    DATA lv_blank TYPE string.

    " internal blanks survive; only trailing blanks of a literal are trimmed,
    " which is why padded expectations are built at runtime (see ANOMALIES.md A18)
    lv_text = 'A  B'.
    cl_abap_unit_assert=>assert_equals( act = strlen( lv_text )
                                        exp = 4 ).

    lv_blank = spaces( 2 ).
    lv_text = 'AB'.
    lv_text = lv_text && lv_blank.
    cl_abap_unit_assert=>assert_equals( act = strlen( lv_text )
                                        exp = 4 ).
  ENDMETHOD.

ENDCLASS.
