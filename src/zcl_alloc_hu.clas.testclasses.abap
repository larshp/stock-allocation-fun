CLASS ltcl_alloc_hu DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_hu.

    METHODS setup.

    METHODS empty_unit        FOR TESTING.
    METHODS totals_quantities FOR TESTING.
    METHODS counts_items      FOR TESTING.
    METHODS counts_materials  FOR TESTING.
    METHODS returns_items     FOR TESTING.
    METHODS clear_resets      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_hu IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_hu( ).
  ENDMETHOD.

  METHOD empty_unit.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->total( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->item_count( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->material_count( ) exp = 0 ).
  ENDMETHOD.

  METHOD totals_quantities.
    mo_cut->add( is_item = VALUE #( material = 'M1' quantity = 10 ) ).
    mo_cut->add( is_item = VALUE #( material = 'M2' quantity = 5 ) ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->total( ) exp = 15 ).
  ENDMETHOD.

  METHOD counts_items.
    mo_cut->add( is_item = VALUE #( material = 'M1' quantity = 10 ) ).
    mo_cut->add( is_item = VALUE #( material = 'M1' quantity = 4 ) ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->item_count( ) exp = 2 ).
  ENDMETHOD.

  METHOD counts_materials.
    mo_cut->add( is_item = VALUE #( material = 'M1' quantity = 10 ) ).
    mo_cut->add( is_item = VALUE #( material = 'M1' quantity = 4 ) ).
    mo_cut->add( is_item = VALUE #( material = 'M2' quantity = 1 ) ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->material_count( ) exp = 2 ).
  ENDMETHOD.

  METHOD returns_items.
    DATA lt_items TYPE zcl_alloc_hu=>ty_item_tt.

    mo_cut->add( is_item = VALUE #( material = 'M1' quantity = 10 ) ).
    mo_cut->add( is_item = VALUE #( material = 'M2' quantity = 5 ) ).

    lt_items = mo_cut->items( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_items ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_items[ 1 ]-material exp = 'M1' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_items[ 2 ]-quantity exp = 5 ).
  ENDMETHOD.

  METHOD clear_resets.
    mo_cut->add( is_item = VALUE #( material = 'M1' quantity = 10 ) ).
    mo_cut->clear( ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->item_count( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->total( ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
