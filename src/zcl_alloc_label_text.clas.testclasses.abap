CLASS ltcl_alloc_label_text DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_label_text.

    METHODS setup.

    METHODS fits_one_line  FOR TESTING.
    METHODS wraps_on_space FOR TESTING.
    METHODS collapses_blanks FOR TESTING.
    METHODS long_word_kept FOR TESTING.
    METHODS empty_text     FOR TESTING.
    METHODS joins_lines    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_label_text IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_label_text( ).
  ENDMETHOD.

  METHOD fits_one_line.
    DATA lt_lines TYPE zcl_alloc_label_text=>ty_text_tt.

    lt_lines = mo_cut->wrap( iv_text = 'AB CD' iv_width = 10 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ] exp = 'AB CD' ).
  ENDMETHOD.

  METHOD wraps_on_space.
    DATA lt_lines TYPE zcl_alloc_label_text=>ty_text_tt.

    lt_lines = mo_cut->wrap( iv_text = 'AAAA BBBB CCCC' iv_width = 9 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ] exp = 'AAAA BBBB' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ] exp = 'CCCC' ).
  ENDMETHOD.

  METHOD collapses_blanks.
    DATA lt_lines TYPE zcl_alloc_label_text=>ty_text_tt.

    lt_lines = mo_cut->wrap( iv_text = 'A   B' iv_width = 10 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ] exp = 'A B' ).
  ENDMETHOD.

  METHOD long_word_kept.
    DATA lt_lines TYPE zcl_alloc_label_text=>ty_text_tt.

    lt_lines = mo_cut->wrap( iv_text = 'LONGWORD AB' iv_width = 4 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ] exp = 'LONGWORD' ).
  ENDMETHOD.

  METHOD empty_text.
    DATA lt_lines TYPE zcl_alloc_label_text=>ty_text_tt.

    lt_lines = mo_cut->wrap( iv_text = '' iv_width = 10 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 0 ).
  ENDMETHOD.

  METHOD joins_lines.
    DATA lt_lines TYPE zcl_alloc_label_text=>ty_text_tt.

    APPEND 'A' TO lt_lines.
    APPEND 'B' TO lt_lines.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->join( it_lines = lt_lines iv_separator = '/' )
      exp = 'A/B' ).
  ENDMETHOD.

ENDCLASS.
