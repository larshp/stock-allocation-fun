CLASS ltcl_alloc_replenish_priority DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_replenish_priority.
    DATA mt_item TYPE zcl_alloc_replenish_priority=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_urgency  TYPE i.

    METHODS ranks_by_urgency FOR TESTING.
    METHODS keeps_top        FOR TESTING.
    METHODS counts_items     FOR TESTING.
    METHODS empty_input      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_replenish_priority IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_replenish_priority( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_replenish_priority=>ty_item.

    ls_item-material = iv_material.
    ls_item-urgency = iv_urgency.
    APPEND ls_item TO mt_item.
  ENDMETHOD.

  METHOD ranks_by_urgency.
    DATA lt_rank TYPE zcl_alloc_replenish_priority=>ty_rank_tt.

    add( iv_material = 'M1' iv_urgency = 1 ).
    add( iv_material = 'M2' iv_urgency = 3 ).
    add( iv_material = 'M3' iv_urgency = 2 ).

    lt_rank = mo_cut->rank( mt_item ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_rank ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_rank[ 1 ]-material exp = 'M2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_rank[ 1 ]-rank exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_rank[ 2 ]-material exp = 'M3' ).
    cl_abap_unit_assert=>assert_equals( act = lt_rank[ 3 ]-material exp = 'M1' ).
  ENDMETHOD.

  METHOD keeps_top.
    DATA lt_top TYPE zcl_alloc_replenish_priority=>ty_rank_tt.

    add( iv_material = 'M1' iv_urgency = 1 ).
    add( iv_material = 'M2' iv_urgency = 3 ).
    add( iv_material = 'M3' iv_urgency = 2 ).

    lt_top = mo_cut->top( it_items = mt_item iv_limit = 2 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_top ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_top[ 1 ]-material exp = 'M2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_top[ 2 ]-material exp = 'M3' ).
  ENDMETHOD.

  METHOD counts_items.
    add( iv_material = 'M1' iv_urgency = 1 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count( mt_item ) exp = 1 ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_cut->top( it_items = mt_item iv_limit = 2 ) )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
