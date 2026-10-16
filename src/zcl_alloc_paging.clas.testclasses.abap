CLASS ltcl_alloc_paging DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_paging.

    METHODS setup.

    METHODS input
      IMPORTING
        iv_total      TYPE i
        iv_size       TYPE i
        iv_page       TYPE i
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_paging=>ty_input.

    METHODS first_page   FOR TESTING.
    METHODS last_page    FOR TESTING.
    METHODS out_of_range FOR TESTING.
    METHODS single_page  FOR TESTING.
    METHODS empty_total  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_paging IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_paging( ).
  ENDMETHOD.

  METHOD input.
    rs_row-total = iv_total.
    rs_row-page_size = iv_size.
    rs_row-page = iv_page.
  ENDMETHOD.

  METHOD first_page.
    DATA(rs_page) = mo_cut->page( input( iv_total = 25
                                         iv_size  = 10
                                         iv_page  = 1 ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_page-total_pages exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = rs_page-from_index exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = rs_page-to_index exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = rs_page-count exp = 10 ).
  ENDMETHOD.

  METHOD last_page.
    DATA(rs_page) = mo_cut->page( input( iv_total = 25
                                         iv_size  = 10
                                         iv_page  = 3 ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_page-from_index exp = 21 ).
    cl_abap_unit_assert=>assert_equals( act = rs_page-to_index exp = 25 ).
    cl_abap_unit_assert=>assert_equals( act = rs_page-count exp = 5 ).
  ENDMETHOD.

  METHOD out_of_range.
    DATA(rs_page) = mo_cut->page( input( iv_total = 25
                                         iv_size  = 10
                                         iv_page  = 4 ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_page-count exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = rs_page-total_pages exp = 3 ).
  ENDMETHOD.

  METHOD single_page.
    DATA(rs_page) = mo_cut->page( input( iv_total = 25
                                         iv_size  = 0
                                         iv_page  = 1 ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_page-total_pages exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = rs_page-from_index exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = rs_page-to_index exp = 25 ).
    cl_abap_unit_assert=>assert_equals( act = rs_page-count exp = 25 ).
  ENDMETHOD.

  METHOD empty_total.
    DATA(rs_page) = mo_cut->page( input( iv_total = 0
                                         iv_size  = 10
                                         iv_page  = 1 ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_page-total_pages exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = rs_page-count exp = 0 ).
  ENDMETHOD.

ENDCLASS.
