CLASS ltcl_alloc_knapsack DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_knapsack.
    DATA mt_item TYPE zcl_alloc_knapsack=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_id     TYPE string
        iv_weight TYPE i
        iv_value  TYPE i.

    METHODS empty_items      FOR TESTING.
    METHODS zero_capacity    FOR TESTING.
    METHODS picks_best_value FOR TESTING.
    METHODS skips_heavy      FOR TESTING.
    METHODS respects_weights FOR TESTING.
    METHODS free_value_item  FOR TESTING.
    METHODS negative_weight  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_knapsack IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_knapsack( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_knapsack=>ty_item.

    ls_item-item_id = iv_id.
    ls_item-weight = iv_weight.
    ls_item-value = iv_value.
    APPEND ls_item TO mt_item.
  ENDMETHOD.

  METHOD empty_items.
    DATA(ls_result) = mo_cut->solve( it_items    = mt_item
                                     iv_capacity = 10 ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-chosen_ids ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-total_value exp = 0 ).
  ENDMETHOD.

  METHOD zero_capacity.
    add( iv_id = 'A' iv_weight = 3 iv_value = 8 ).

    DATA(ls_result) = mo_cut->solve( it_items    = mt_item
                                     iv_capacity = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-chosen_ids ) exp = 0 ).
  ENDMETHOD.

  METHOD picks_best_value.
    add( iv_id = 'LIGHT' iv_weight = 1 iv_value = 1 ).
    add( iv_id = 'HEAVY' iv_weight = 5 iv_value = 10 ).

    DATA(ls_result) = mo_cut->solve( it_items    = mt_item
                                     iv_capacity = 5 ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-chosen_ids ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-chosen_ids[ 1 ] exp = 'HEAVY' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-total_value exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-total_weight exp = 5 ).
  ENDMETHOD.

  METHOD skips_heavy.
    add( iv_id = 'A' iv_weight = 9 iv_value = 100 ).
    add( iv_id = 'B' iv_weight = 4 iv_value = 5 ).
    add( iv_id = 'C' iv_weight = 4 iv_value = 5 ).

    DATA(ls_result) = mo_cut->solve( it_items    = mt_item
                                     iv_capacity = 8 ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-chosen_ids ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-total_value exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-total_weight exp = 8 ).
  ENDMETHOD.

  METHOD respects_weights.
    add( iv_id = 'TINY' iv_weight = 1 iv_value = 3 ).
    add( iv_id = 'SMALL' iv_weight = 2 iv_value = 6 ).

    DATA(ls_result) = mo_cut->solve( it_items    = mt_item
                                     iv_capacity = 3 ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-chosen_ids ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-chosen_ids[ 1 ] exp = 'TINY' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-total_value exp = 9 ).
  ENDMETHOD.

  METHOD free_value_item.
    add( iv_id = 'FREE' iv_weight = 0 iv_value = 7 ).

    DATA(ls_result) = mo_cut->solve( it_items    = mt_item
                                     iv_capacity = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-chosen_ids ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-total_value exp = 7 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-total_weight exp = 0 ).
  ENDMETHOD.

  METHOD negative_weight.
    add( iv_id = 'BAD' iv_weight = -3 iv_value = 50 ).
    add( iv_id = 'OK'  iv_weight = 2 iv_value = 4 ).

    DATA(ls_result) = mo_cut->solve( it_items    = mt_item
                                     iv_capacity = 2 ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-chosen_ids ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-chosen_ids[ 1 ] exp = 'OK' ).
  ENDMETHOD.

ENDCLASS.
