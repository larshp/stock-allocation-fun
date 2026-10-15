CLASS ltcl_alloc_abc_xyz DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_abc_xyz.
    DATA mt_item TYPE zcl_alloc_abc_xyz=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_abc      TYPE string
        iv_xyz      TYPE string.

    METHODS builds_matrix  FOR TESTING.
    METHODS reads_cell     FOR TESTING.
    METHODS counts_cell    FOR TESTING.
    METHODS empty_input    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_abc_xyz IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_abc_xyz( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_abc_xyz=>ty_item.

    ls_item-material = iv_material.
    ls_item-abc = iv_abc.
    ls_item-xyz = iv_xyz.
    APPEND ls_item TO mt_item.
  ENDMETHOD.

  METHOD builds_matrix.
    DATA lt_cells TYPE zcl_alloc_abc_xyz=>ty_cell_tt.

    add( iv_material = 'M1' iv_abc = 'A' iv_xyz = 'X' ).
    add( iv_material = 'M2' iv_abc = 'A' iv_xyz = 'X' ).
    add( iv_material = 'M3' iv_abc = 'B' iv_xyz = 'Y' ).

    lt_cells = mo_cut->matrix( mt_item ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_cells ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_cells[ 1 ]-cell exp = 'AX' ).
    cl_abap_unit_assert=>assert_equals( act = lt_cells[ 1 ]-count exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_cells[ 2 ]-cell exp = 'BY' ).
  ENDMETHOD.

  METHOD reads_cell.
    add( iv_material = 'M1' iv_abc = 'A' iv_xyz = 'X' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cell_of( it_items = mt_item iv_material = 'M1' )
      exp = 'AX' ).
  ENDMETHOD.

  METHOD counts_cell.
    add( iv_material = 'M1' iv_abc = 'A' iv_xyz = 'X' ).
    add( iv_material = 'M2' iv_abc = 'A' iv_xyz = 'X' ).
    add( iv_material = 'M3' iv_abc = 'B' iv_xyz = 'Y' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_in_cell( it_items = mt_item iv_cell = 'AX' )
      exp = 2 ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_cut->matrix( mt_item ) ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
