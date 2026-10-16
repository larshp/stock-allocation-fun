CLASS ltcl_alloc_local_search DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_local_search.
    DATA mt_opt TYPE zcl_alloc_local_search=>ty_option_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_slot TYPE string
        iv_opt  TYPE string
        iv_cost TYPE menge_d.

    METHODS cheapest_per_slot FOR TESTING.
    METHODS improves_by_swap   FOR TESTING.
    METHODS no_swap_possible   FOR TESTING.
    METHODS keeps_slot_order   FOR TESTING.
    METHODS zero_steps         FOR TESTING.
    METHODS empty_input        FOR TESTING.
    METHODS single_slot        FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_local_search IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_local_search( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_option TYPE zcl_alloc_local_search=>ty_option.

    ls_option-slot_id = iv_slot.
    ls_option-option_id = iv_opt.
    ls_option-cost = iv_cost.
    APPEND ls_option TO mt_opt.
  ENDMETHOD.

  METHOD cheapest_per_slot.
    add( iv_slot = 'S1' iv_opt = 'A' iv_cost = 5 ).
    add( iv_slot = 'S1' iv_opt = 'B' iv_cost = 2 ).
    add( iv_slot = 'S2' iv_opt = 'A' iv_cost = 7 ).

    DATA(ls_result) = mo_cut->improve( it_options   = mt_opt
                                       iv_max_steps = 3 ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-choices ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-choices[ 1 ]-option_id exp = 'B' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-choices[ 2 ]-option_id exp = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-total_cost exp = 9 ).
  ENDMETHOD.

  METHOD improves_by_swap.
    add( iv_slot = 'S1' iv_opt = 'A' iv_cost = 1 ).
    add( iv_slot = 'S1' iv_opt = 'B' iv_cost = 2 ).
    add( iv_slot = 'S2' iv_opt = 'A' iv_cost = 3 ).
    add( iv_slot = 'S2' iv_opt = 'B' iv_cost = 100 ).

    DATA(ls_result) = mo_cut->improve( it_options   = mt_opt
                                       iv_max_steps = 3 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-improved exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-swaps exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-choices[ 1 ]-option_id exp = 'B' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-choices[ 2 ]-option_id exp = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-total_cost exp = 5 ).
  ENDMETHOD.

  METHOD no_swap_possible.
    add( iv_slot = 'S1' iv_opt = 'A' iv_cost = 1 ).
    add( iv_slot = 'S2' iv_opt = 'B' iv_cost = 2 ).

    DATA(ls_result) = mo_cut->improve( it_options   = mt_opt
                                       iv_max_steps = 3 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-improved exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-swaps exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-total_cost exp = 3 ).
  ENDMETHOD.

  METHOD keeps_slot_order.
    add( iv_slot = 'ZETA' iv_opt = 'X' iv_cost = 4 ).
    add( iv_slot = 'ALPHA' iv_opt = 'Y' iv_cost = 1 ).

    DATA(ls_result) = mo_cut->improve( it_options   = mt_opt
                                       iv_max_steps = 2 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-choices[ 1 ]-slot_id exp = 'ZETA' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-choices[ 2 ]-slot_id exp = 'ALPHA' ).
  ENDMETHOD.

  METHOD zero_steps.
    add( iv_slot = 'S1' iv_opt = 'A' iv_cost = 5 ).
    add( iv_slot = 'S1' iv_opt = 'B' iv_cost = 3 ).

    DATA(ls_result) = mo_cut->improve( it_options   = mt_opt
                                       iv_max_steps = 0 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-steps exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-total_cost exp = 3 ).
  ENDMETHOD.

  METHOD empty_input.
    DATA(ls_result) = mo_cut->improve( it_options   = mt_opt
                                       iv_max_steps = 3 ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-choices ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-total_cost exp = 0 ).
  ENDMETHOD.

  METHOD single_slot.
    add( iv_slot = 'S1' iv_opt = 'A' iv_cost = 6 ).
    add( iv_slot = 'S1' iv_opt = 'B' iv_cost = 1 ).

    DATA(ls_result) = mo_cut->improve( it_options   = mt_opt
                                       iv_max_steps = 3 ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-choices ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-choices[ 1 ]-option_id exp = 'B' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-improved exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
