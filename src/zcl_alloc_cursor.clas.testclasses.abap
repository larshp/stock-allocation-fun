CLASS ltcl_alloc_cursor DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cursor.

    METHODS setup.

    METHODS opens_at_zero      FOR TESTING.
    METHODS next_advances      FOR TESTING.
    METHODS next_clamps        FOR TESTING.
    METHODS last_on_final_page FOR TESTING.
    METHODS empty_is_last      FOR TESTING.
    METHODS zero_page_is_last  FOR TESTING.
    METHODS remaining_counts   FOR TESTING.
    METHODS remaining_zero     FOR TESTING.

    METHODS make_cursor
      IMPORTING
        iv_total        TYPE i
        iv_page_size    TYPE i
      RETURNING
        VALUE(rs_input) TYPE zcl_alloc_cursor=>ty_input.

ENDCLASS.


CLASS ltcl_alloc_cursor IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cursor( ).
  ENDMETHOD.

  METHOD make_cursor.
    rs_input-total = iv_total.
    rs_input-page_size = iv_page_size.
  ENDMETHOD.

  METHOD opens_at_zero.
    DATA(ls_input) = make_cursor( iv_total = 10 iv_page_size = 4 ).
    DATA(ls_cursor) = mo_cut->open( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_cursor-offset exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_cursor-page_size exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = ls_cursor-total exp = 10 ).
  ENDMETHOD.

  METHOD next_advances.
    DATA(ls_input) = make_cursor( iv_total = 10 iv_page_size = 4 ).
    DATA(ls_first) = mo_cut->open( ls_input ).
    DATA(ls_second) = mo_cut->next( ls_first ).

    cl_abap_unit_assert=>assert_equals( act = ls_second-offset exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = ls_second-page_size exp = 4 ).
  ENDMETHOD.

  METHOD next_clamps.
    DATA(ls_input) = make_cursor( iv_total = 10 iv_page_size = 4 ).
    DATA(ls_first) = mo_cut->open( ls_input ).
    DATA(ls_second) = mo_cut->next( ls_first ).
    DATA(ls_third) = mo_cut->next( ls_second ).
    DATA(ls_fourth) = mo_cut->next( ls_third ).

    cl_abap_unit_assert=>assert_equals( act = ls_third-offset exp = 8 ).
    cl_abap_unit_assert=>assert_equals( act = ls_fourth-offset exp = 10 ).
  ENDMETHOD.

  METHOD last_on_final_page.
    DATA(ls_input) = make_cursor( iv_total = 10 iv_page_size = 4 ).
    DATA(ls_first) = mo_cut->open( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_last( ls_first ) exp = abap_false ).

    DATA(ls_second) = mo_cut->next( ls_first ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_last( ls_second ) exp = abap_false ).

    DATA(ls_third) = mo_cut->next( ls_second ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_last( ls_third ) exp = abap_true ).
  ENDMETHOD.

  METHOD empty_is_last.
    DATA(ls_input) = make_cursor( iv_total = 0 iv_page_size = 5 ).
    DATA(ls_cursor) = mo_cut->open( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_last( ls_cursor ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->remaining( ls_cursor ) exp = 0 ).
  ENDMETHOD.

  METHOD zero_page_is_last.
    DATA(ls_input) = make_cursor( iv_total = 7 iv_page_size = 0 ).
    DATA(ls_cursor) = mo_cut->open( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_cursor-page_size exp = 7 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_last( ls_cursor ) exp = abap_true ).

    DATA(ls_next) = mo_cut->next( ls_cursor ).
    cl_abap_unit_assert=>assert_equals( act = ls_next-offset exp = 7 ).
  ENDMETHOD.

  METHOD remaining_counts.
    DATA(ls_input) = make_cursor( iv_total = 10 iv_page_size = 4 ).
    DATA(ls_cursor) = mo_cut->open( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->remaining( ls_cursor ) exp = 10 ).

    ls_cursor = mo_cut->next( ls_cursor ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->remaining( ls_cursor ) exp = 6 ).

    ls_cursor = mo_cut->next( ls_cursor ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->remaining( ls_cursor ) exp = 2 ).
  ENDMETHOD.

  METHOD remaining_zero.
    DATA(ls_input) = make_cursor( iv_total = 4 iv_page_size = 4 ).
    DATA(ls_cursor) = mo_cut->open( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->remaining( ls_cursor ) exp = 4 ).

    ls_cursor = mo_cut->next( ls_cursor ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->remaining( ls_cursor ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
