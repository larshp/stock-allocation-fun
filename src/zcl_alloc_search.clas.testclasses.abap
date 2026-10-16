CLASS ltcl_alloc_search DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_search.

    METHODS setup.

    METHODS item
      IMPORTING
        iv_key        TYPE c
        iv_text       TYPE c
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_search=>ty_item.

    METHODS input
      IMPORTING
        it_items      TYPE zcl_alloc_search=>ty_item_tt
        iv_term       TYPE c
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_search=>ty_input.

    METHODS empty_list      FOR TESTING.
    METHODS matches_substring FOR TESTING.
    METHODS case_insensitive FOR TESTING.
    METHODS no_match        FOR TESTING.
    METHODS keeps_order     FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_search IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_search( ).
  ENDMETHOD.

  METHOD item.
    rs_row-key = iv_key.
    rs_row-text = iv_text.
  ENDMETHOD.

  METHOD input.
    rs_row-items = it_items.
    rs_row-term = iv_term.
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_items TYPE zcl_alloc_search=>ty_item_tt.

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->filter( input( it_items = lt_items iv_term = 'X' ) ) ).
  ENDMETHOD.

  METHOD matches_substring.
    DATA lt_items TYPE zcl_alloc_search=>ty_item_tt.

    APPEND item( iv_key = 'R1' iv_text = 'MAT-1 SHORTAGE' ) TO lt_items.
    APPEND item( iv_key = 'R2' iv_text = 'MAT-2 FULL' ) TO lt_items.

    DATA(lt_hits) = mo_cut->filter( input( it_items = lt_items
                                           iv_term  = 'SHORT' ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_hits ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_hits[ 1 ]-key exp = 'R1' ).
  ENDMETHOD.

  METHOD case_insensitive.
    DATA lt_items TYPE zcl_alloc_search=>ty_item_tt.

    APPEND item( iv_key = 'R1' iv_text = 'mat-1 shortage' ) TO lt_items.

    DATA(lt_hits) = mo_cut->filter( input( it_items = lt_items
                                           iv_term  = 'SHORT' ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_hits ) exp = 1 ).
  ENDMETHOD.

  METHOD no_match.
    DATA lt_items TYPE zcl_alloc_search=>ty_item_tt.

    APPEND item( iv_key = 'R1' iv_text = 'MAT-1' ) TO lt_items.

    DATA(lt_hits) = mo_cut->filter( input( it_items = lt_items
                                           iv_term  = 'ZZZ' ) ).

    cl_abap_unit_assert=>assert_initial( act = lt_hits ).
  ENDMETHOD.

  METHOD keeps_order.
    DATA lt_items TYPE zcl_alloc_search=>ty_item_tt.

    APPEND item( iv_key = 'R2' iv_text = 'MAT-2' ) TO lt_items.
    APPEND item( iv_key = 'R1' iv_text = 'MAT-1' ) TO lt_items.

    DATA(lt_hits) = mo_cut->filter( input( it_items = lt_items
                                           iv_term  = 'MAT' ) ).

    cl_abap_unit_assert=>assert_equals( act = lt_hits[ 1 ]-key exp = 'R2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_hits[ 2 ]-key exp = 'R1' ).
  ENDMETHOD.

ENDCLASS.
