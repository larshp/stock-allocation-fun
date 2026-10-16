CLASS ltcl_alloc_align DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_align.

    METHODS setup.

    METHODS spaces
      IMPORTING
        iv_count       TYPE i
      RETURNING
        VALUE(rv_text) TYPE string.

    METHODS left_pads          FOR TESTING.
    METHODS left_truncates     FOR TESTING.
    METHODS left_zero_width    FOR TESTING.
    METHODS right_pads         FOR TESTING.
    METHODS center_pads        FOR TESTING.
    METHODS center_odd_extra   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_align IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_align( ).
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

  METHOD left_pads.
    DATA lv_exp TYPE string.

    lv_exp = 'AB'.
    lv_exp = lv_exp && spaces( 2 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->left_value( iv_value = 'AB' iv_width = 4 )
      exp = lv_exp ).
  ENDMETHOD.

  METHOD left_truncates.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->left_value( iv_value = 'ABCDE' iv_width = 3 )
      exp = 'ABC' ).
  ENDMETHOD.

  METHOD left_zero_width.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->left_value( iv_value = 'AB' iv_width = 0 )
      exp = 'AB' ).
  ENDMETHOD.

  METHOD right_pads.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->right_value( iv_value = 'AB' iv_width = 4 )
      exp = '  AB' ).
  ENDMETHOD.

  METHOD center_pads.
    DATA lv_exp TYPE string.

    lv_exp = spaces( 2 ).
    lv_exp = lv_exp && 'AB'.
    lv_exp = lv_exp && spaces( 2 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->center_value( iv_value = 'AB' iv_width = 6 )
      exp = lv_exp ).
  ENDMETHOD.

  METHOD center_odd_extra.
    DATA lv_exp TYPE string.

    lv_exp = spaces( 1 ).
    lv_exp = lv_exp && 'AB'.
    lv_exp = lv_exp && spaces( 2 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->center_value( iv_value = 'AB' iv_width = 5 )
      exp = lv_exp ).
  ENDMETHOD.

ENDCLASS.
