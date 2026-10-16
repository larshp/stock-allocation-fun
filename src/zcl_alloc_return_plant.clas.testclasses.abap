CLASS ltcl_alloc_return_plant DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_plant.
    DATA mt_itm TYPE zcl_alloc_return_plant=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_plant    TYPE string
        iv_quantity TYPE i.

    METHODS groups_by_plant FOR TESTING.
    METHODS totals          FOR TESTING.
    METHODS tops_plant      FOR TESTING.
    METHODS empty_input     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_plant IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_plant( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_return_plant=>ty_item.

    ls_item-plant = iv_plant.
    ls_item-quantity = iv_quantity.
    APPEND ls_item TO mt_itm.
  ENDMETHOD.

  METHOD groups_by_plant.
    DATA lt_groups TYPE zcl_alloc_return_plant=>ty_group_tt.

    add( iv_plant = 'P1' iv_quantity = 5 ).
    add( iv_plant = 'P2' iv_quantity = 3 ).
    add( iv_plant = 'P1' iv_quantity = 2 ).

    lt_groups = mo_cut->group( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_groups ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_groups[ 1 ]-plant exp = 'P1' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_groups[ 1 ]-quantity exp = 7 ).
    cl_abap_unit_assert=>assert_equals( act = lt_groups[ 2 ]-plant exp = 'P2' ).
  ENDMETHOD.

  METHOD totals.
    add( iv_plant = 'P1' iv_quantity = 5 ).
    add( iv_plant = 'P2' iv_quantity = 3 ).
    add( iv_plant = 'P1' iv_quantity = 2 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_itm ) exp = 10 ).
  ENDMETHOD.

  METHOD tops_plant.
    add( iv_plant = 'P2' iv_quantity = 3 ).
    add( iv_plant = 'P1' iv_quantity = 7 ).
    add( iv_plant = 'P3' iv_quantity = 2 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->top_plant( mt_itm ) exp = 'P1' ).
  ENDMETHOD.

  METHOD empty_input.
    DATA lt_groups TYPE zcl_alloc_return_plant=>ty_group_tt.

    lt_groups = mo_cut->group( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_groups ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->top_plant( mt_itm ) exp = '' ).
  ENDMETHOD.

ENDCLASS.
