CLASS ltcl_alloc_return_reason_grp DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_reason_grp.
    DATA mt_item TYPE zcl_alloc_return_reason_grp=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_reason   TYPE string
        iv_quantity TYPE menge_d.

    METHODS groups_by_reason FOR TESTING.
    METHODS sorted_output    FOR TESTING.
    METHODS totals           FOR TESTING.
    METHODS empty_input      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_reason_grp IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_reason_grp( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_return_reason_grp=>ty_item.

    ls_item-reason = iv_reason.
    ls_item-quantity = iv_quantity.
    APPEND ls_item TO mt_item.
  ENDMETHOD.

  METHOD groups_by_reason.
    DATA lt_group TYPE zcl_alloc_return_reason_grp=>ty_group_tt.

    add( iv_reason = 'DAMAGED' iv_quantity = 2 ).
    add( iv_reason = 'WRONG_ITEM' iv_quantity = 1 ).
    add( iv_reason = 'DAMAGED' iv_quantity = 3 ).

    lt_group = mo_cut->group( mt_item ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_group ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_group[ 1 ]-reason exp = 'DAMAGED' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_group[ 1 ]-quantity exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_group[ 1 ]-line_count exp = 2 ).
  ENDMETHOD.

  METHOD sorted_output.
    DATA lt_group TYPE zcl_alloc_return_reason_grp=>ty_group_tt.

    add( iv_reason = 'WRONG_ITEM' iv_quantity = 1 ).
    add( iv_reason = 'DAMAGED' iv_quantity = 3 ).

    lt_group = mo_cut->group( mt_item ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_group[ 1 ]-reason exp = 'DAMAGED' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_group[ 2 ]-reason exp = 'WRONG_ITEM' ).
  ENDMETHOD.

  METHOD totals.
    add( iv_reason = 'DAMAGED' iv_quantity = 2 ).
    add( iv_reason = 'WRONG_ITEM' iv_quantity = 1 ).
    add( iv_reason = 'DAMAGED' iv_quantity = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_item ) exp = 6 ).
  ENDMETHOD.

  METHOD empty_input.
    DATA lt_group TYPE zcl_alloc_return_reason_grp=>ty_group_tt.

    lt_group = mo_cut->group( mt_item ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_group ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_item ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
