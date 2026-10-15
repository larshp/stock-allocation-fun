CLASS ltcl_alloc_replace_priority DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_replace_priority.
    DATA mt_itm TYPE zcl_alloc_replace_priority=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_item_id   TYPE string
        iv_tier      TYPE i
        iv_wait_days TYPE i
        iv_value     TYPE i.

    METHODS scores        FOR TESTING.
    METHODS clamps_input  FOR TESTING.
    METHODS urgency       FOR TESTING.
    METHODS ranks_by_score FOR TESTING.
    METHODS stable_tie    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_replace_priority IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_replace_priority( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_replace_priority=>ty_item.

    ls_item-item_id = iv_item_id.
    ls_item-tier = iv_tier.
    ls_item-wait_days = iv_wait_days.
    ls_item-value = iv_value.
    APPEND ls_item TO mt_itm.
  ENDMETHOD.

  METHOD scores.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( iv_tier = 3 iv_wait_days = 5 iv_value = 1000 )
      exp = 50 ).
  ENDMETHOD.

  METHOD clamps_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( iv_tier = -1 iv_wait_days = 5 iv_value = 1000 )
      exp = 20 ).
  ENDMETHOD.

  METHOD urgency.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_urgent( 50 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_urgent( 49 ) exp = abap_false ).
  ENDMETHOD.

  METHOD ranks_by_score.
    DATA lt_ranked TYPE zcl_alloc_replace_priority=>ty_ranked_tt.

    add( iv_item_id = 'A' iv_tier = 2 iv_wait_days = 5 iv_value = 0 ).
    add( iv_item_id = 'B' iv_tier = 4 iv_wait_days = 0 iv_value = 0 ).

    lt_ranked = mo_cut->rank( mt_itm ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_ranked[ 1 ]-item_id exp = 'B' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_ranked[ 1 ]-score exp = 40 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_ranked[ 2 ]-item_id exp = 'A' ).
  ENDMETHOD.

  METHOD stable_tie.
    DATA lt_ranked TYPE zcl_alloc_replace_priority=>ty_ranked_tt.

    add( iv_item_id = 'A' iv_tier = 2 iv_wait_days = 0 iv_value = 0 ).
    add( iv_item_id = 'B' iv_tier = 2 iv_wait_days = 0 iv_value = 0 ).

    lt_ranked = mo_cut->rank( mt_itm ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_ranked[ 1 ]-item_id exp = 'A' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_ranked[ 2 ]-item_id exp = 'B' ).
  ENDMETHOD.

ENDCLASS.
