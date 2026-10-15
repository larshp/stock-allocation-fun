CLASS ltcl_alloc_return_consolidate DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_consolidate.
    DATA mt_itm TYPE zcl_alloc_return_consolidate=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_group    TYPE string
        iv_quantity TYPE i.

    METHODS merges_by_key   FOR TESTING.
    METHODS counts_groups   FOR TESTING.
    METHODS largest         FOR TESTING.
    METHODS empty_input     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_consolidate IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_consolidate( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_return_consolidate=>ty_item.

    ls_item-group_key = iv_group.
    ls_item-quantity = iv_quantity.
    APPEND ls_item TO mt_itm.
  ENDMETHOD.

  METHOD merges_by_key.
    DATA lt_groups TYPE zcl_alloc_return_consolidate=>ty_group_tt.

    add( iv_group = 'G1' iv_quantity = 2 ).
    add( iv_group = 'G2' iv_quantity = 3 ).
    add( iv_group = 'G1' iv_quantity = 4 ).

    lt_groups = mo_cut->merge( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_groups ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_groups[ 1 ]-group_key exp = 'G1' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_groups[ 1 ]-quantity exp = 6 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_groups[ 2 ]-quantity exp = 3 ).
  ENDMETHOD.

  METHOD counts_groups.
    DATA lt_groups TYPE zcl_alloc_return_consolidate=>ty_group_tt.

    add( iv_group = 'G1' iv_quantity = 2 ).
    add( iv_group = 'G2' iv_quantity = 3 ).
    add( iv_group = 'G1' iv_quantity = 4 ).

    lt_groups = mo_cut->merge( mt_itm ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->groups( lt_groups ) exp = 2 ).
  ENDMETHOD.

  METHOD largest.
    DATA lt_groups TYPE zcl_alloc_return_consolidate=>ty_group_tt.

    add( iv_group = 'G1' iv_quantity = 2 ).
    add( iv_group = 'G2' iv_quantity = 3 ).
    add( iv_group = 'G1' iv_quantity = 4 ).

    lt_groups = mo_cut->merge( mt_itm ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->largest_group( lt_groups ) exp = 'G1' ).
  ENDMETHOD.

  METHOD empty_input.
    DATA lt_groups TYPE zcl_alloc_return_consolidate=>ty_group_tt.

    lt_groups = mo_cut->merge( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_groups ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->largest_group( lt_groups ) exp = '' ).
  ENDMETHOD.

ENDCLASS.
