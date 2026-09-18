CLASS ltcl_alloc_text_trunc DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_text_trunc.

    METHODS setup.

    METHODS short_text_kept FOR TESTING.
    METHODS exact_width     FOR TESTING.
    METHODS truncates_middle FOR TESTING.
    METHODS marker_only     FOR TESTING.
    METHODS partial_marker  FOR TESTING.
    METHODS zero_width      FOR TESTING.
    METHODS fits_flag       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_text_trunc IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_text_trunc( ).
  ENDMETHOD.

  METHOD short_text_kept.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->truncate( iv_text   = 'Stock Allocation'
                              iv_width  = 20
                              iv_marker = '...' )
      exp = 'Stock Allocation' ).
  ENDMETHOD.

  METHOD exact_width.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->truncate( iv_text   = 'abc'
                              iv_width  = 3
                              iv_marker = '...' )
      exp = 'abc' ).
  ENDMETHOD.

  METHOD truncates_middle.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->truncate( iv_text   = 'Stock Allocation'
                              iv_width  = 10
                              iv_marker = '...' )
      exp = 'Stock A...' ).
  ENDMETHOD.

  METHOD marker_only.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->truncate( iv_text   = 'Stock Allocation'
                              iv_width  = 3
                              iv_marker = '...' )
      exp = '...' ).
  ENDMETHOD.

  METHOD partial_marker.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->truncate( iv_text   = 'Stock Allocation'
                              iv_width  = 2
                              iv_marker = '...' )
      exp = '..' ).
  ENDMETHOD.

  METHOD zero_width.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->truncate( iv_text   = 'Stock Allocation'
                              iv_width  = 0
                              iv_marker = '...' )
      exp = '' ).
  ENDMETHOD.

  METHOD fits_flag.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->fits( iv_text = 'abc' iv_width = 3 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->fits( iv_text = 'abcd' iv_width = 3 ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->fits( iv_text = 'abc' iv_width = 0 ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
