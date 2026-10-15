CLASS ltcl_alloc_val_browse DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_val_browse.
    DATA mt_line TYPE zcl_alloc_val_browse=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_value    TYPE i.

    METHODS browses_page   FOR TESTING.
    METHODS counts_pages   FOR TESTING.
    METHODS more_rule      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_val_browse IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_val_browse( ).

    add( iv_material = 'M1' iv_value = 100 ).
    add( iv_material = 'M2' iv_value = 200 ).
    add( iv_material = 'M3' iv_value = 300 ).
    add( iv_material = 'M4' iv_value = 400 ).
    add( iv_material = 'M5' iv_value = 500 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_val_browse=>ty_line.

    ls_line-material = iv_material.
    ls_line-value = iv_value.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD browses_page.
    DATA lt_page TYPE zcl_alloc_val_browse=>ty_line_tt.

    lt_page = mo_cut->browse( it_lines = mt_line iv_page = 2
                              iv_page_size = 2 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_page ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_page[ 1 ]-material exp = 'M3' ).

    lt_page = mo_cut->browse( it_lines = mt_line iv_page = 3
                              iv_page_size = 2 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_page ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_page[ 1 ]-material exp = 'M5' ).
  ENDMETHOD.

  METHOD counts_pages.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->page_count( iv_total_lines = 5 iv_page_size = 2 )
      exp = 3 ).
  ENDMETHOD.

  METHOD more_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->has_more( iv_page = 1 iv_page_size = 2 iv_total_lines = 5 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->has_more( iv_page = 3 iv_page_size = 2 iv_total_lines = 5 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
