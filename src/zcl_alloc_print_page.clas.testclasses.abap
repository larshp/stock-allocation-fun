CLASS ltcl_alloc_print_page DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_print_page.

    METHODS setup.

    METHODS make_input
      IMPORTING
        iv_lines        TYPE i
        iv_size         TYPE i
        iv_header       TYPE i
        iv_footer       TYPE i
      RETURNING
        VALUE(rs_input) TYPE zcl_alloc_print_page=>ty_input.

    METHODS capacity_plain FOR TESTING.
    METHODS capacity_small FOR TESTING.
    METHODS empty_result    FOR TESTING.
    METHODS three_pages     FOR TESTING.
    METHODS last_page_short FOR TESTING.
    METHODS no_page_size    FOR TESTING.
    METHODS huge_furniture  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_print_page IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_print_page( ).
  ENDMETHOD.

  METHOD make_input.
    rs_input-line_count = iv_lines.
    rs_input-page_size = iv_size.
    rs_input-header_lines = iv_header.
    rs_input-footer_lines = iv_footer.
  ENDMETHOD.

  METHOD capacity_plain.
    DATA(ls_input) = make_input( iv_lines = 10 iv_size = 6
                                 iv_header = 1 iv_footer = 1 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->capacity_of( ls_input ) exp = 4 ).
  ENDMETHOD.

  METHOD capacity_small.
    DATA(ls_input) = make_input( iv_lines = 10 iv_size = 10
                                 iv_header = 5 iv_footer = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->capacity_of( ls_input ) exp = 1 ).
  ENDMETHOD.

  METHOD empty_result.
    DATA(ls_input) = make_input( iv_lines = 0 iv_size = 6
                                 iv_header = 0 iv_footer = 0 ).

    DATA(lt_pages) = mo_cut->paginate( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_pages ) exp = 0 ).
  ENDMETHOD.

  METHOD three_pages.
    DATA(ls_input) = make_input( iv_lines = 10 iv_size = 6
                                 iv_header = 1 iv_footer = 1 ).

    DATA(lt_pages) = mo_cut->paginate( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_pages ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_pages[ 1 ]-page_no exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_pages[ 1 ]-from_line exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_pages[ 1 ]-to_line exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = lt_pages[ 1 ]-lines exp = 4 ).
  ENDMETHOD.

  METHOD last_page_short.
    DATA(ls_input) = make_input( iv_lines = 10 iv_size = 6
                                 iv_header = 1 iv_footer = 1 ).

    DATA(lt_pages) = mo_cut->paginate( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lt_pages[ 3 ]-from_line exp = 9 ).
    cl_abap_unit_assert=>assert_equals( act = lt_pages[ 3 ]-to_line exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = lt_pages[ 3 ]-lines exp = 2 ).
  ENDMETHOD.

  METHOD no_page_size.
    DATA(ls_input) = make_input( iv_lines = 10 iv_size = 0
                                 iv_header = 1 iv_footer = 1 ).

    DATA(lt_pages) = mo_cut->paginate( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_pages ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_pages[ 1 ]-to_line exp = 10 ).
  ENDMETHOD.

  METHOD huge_furniture.
    DATA(ls_input) = make_input( iv_lines = 3 iv_size = 10
                                 iv_header = 40 iv_footer = 0 ).

    DATA(lt_pages) = mo_cut->paginate( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_pages ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_pages[ 1 ]-lines exp = 1 ).
  ENDMETHOD.

ENDCLASS.
