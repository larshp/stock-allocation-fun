CLASS ltcl_alloc_text_wrap DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_text_wrap.

    METHODS setup.

    METHODS empty_text    FOR TESTING.
    METHODS single_line   FOR TESTING.
    METHODS wraps_at_word FOR TESTING.
    METHODS narrow_width  FOR TESTING.
    METHODS skips_double_spaces FOR TESTING.
    METHODS long_word_alone FOR TESTING.
    METHODS zero_width    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_text_wrap IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_text_wrap( ).
  ENDMETHOD.

  METHOD empty_text.
    DATA(lt_lines) = mo_cut->wrap( iv_text = '' iv_width = 10 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 0 ).
  ENDMETHOD.

  METHOD single_line.
    DATA(lt_lines) = mo_cut->wrap( iv_text  = 'alpha beta gamma'
                                   iv_width = 20 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ] exp = 'alpha beta gamma' ).
  ENDMETHOD.

  METHOD wraps_at_word.
    DATA(lt_lines) = mo_cut->wrap( iv_text  = 'alpha beta gamma'
                                   iv_width = 10 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ] exp = 'alpha beta' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ] exp = 'gamma' ).
  ENDMETHOD.

  METHOD narrow_width.
    DATA(lt_lines) = mo_cut->wrap( iv_text  = 'alpha beta gamma'
                                   iv_width = 5 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ] exp = 'alpha' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ] exp = 'gamma' ).
  ENDMETHOD.

  METHOD skips_double_spaces.
    DATA(lt_lines) = mo_cut->wrap( iv_text  = 'alpha  beta'
                                   iv_width = 20 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ] exp = 'alpha beta' ).
  ENDMETHOD.

  METHOD long_word_alone.
    DATA(lt_lines) = mo_cut->wrap( iv_text  = 'extraordinarily long'
                                   iv_width = 5 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ] exp = 'extraordinarily' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ] exp = 'long' ).
  ENDMETHOD.

  METHOD zero_width.
    DATA(lt_lines) = mo_cut->wrap( iv_text  = 'alpha beta'
                                   iv_width = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ] exp = 'alpha' ).
  ENDMETHOD.

ENDCLASS.
