CLASS ltcl_alloc_return_reason_dist DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_reason_dist.
    DATA mt_itm TYPE zcl_alloc_return_reason_dist=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_reason TYPE string
        iv_count  TYPE i.

    METHODS shares_by_reason FOR TESTING.
    METHODS percent_helper   FOR TESTING.
    METHODS percent_guard    FOR TESTING.
    METHODS top_reason       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_reason_dist IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_reason_dist( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_return_reason_dist=>ty_item.

    ls_item-reason = iv_reason.
    ls_item-count = iv_count.
    APPEND ls_item TO mt_itm.
  ENDMETHOD.

  METHOD shares_by_reason.
    DATA lt_shares TYPE zcl_alloc_return_reason_dist=>ty_share_tt.

    add( iv_reason = 'DAMAGED' iv_count = 3 ).
    add( iv_reason = 'WRONG_ITEM' iv_count = 1 ).
    add( iv_reason = 'DAMAGED' iv_count = 0 ).

    lt_shares = mo_cut->share( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_shares ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_shares[ 1 ]-reason exp = 'DAMAGED' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_shares[ 1 ]-share_percent exp = 75 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_shares[ 2 ]-share_percent exp = 25 ).
  ENDMETHOD.

  METHOD percent_helper.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->share_percent( iv_count = 3 iv_total = 4 )
      exp = 75 ).
  ENDMETHOD.

  METHOD percent_guard.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->share_percent( iv_count = 3 iv_total = 0 )
      exp = 0 ).
  ENDMETHOD.

  METHOD top_reason.
    DATA lt_shares TYPE zcl_alloc_return_reason_dist=>ty_share_tt.

    add( iv_reason = 'DAMAGED' iv_count = 3 ).
    add( iv_reason = 'WRONG_ITEM' iv_count = 1 ).

    lt_shares = mo_cut->share( mt_itm ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->top_reason( lt_shares ) exp = 'DAMAGED' ).
  ENDMETHOD.

ENDCLASS.
