CLASS ltcl_alloc_slow_mover DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_slow_mover.
    DATA mt_item TYPE zcl_alloc_slow_mover=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material  TYPE matnr
        iv_movements TYPE i.

    METHODS slow_rule     FOR TESTING.
    METHODS movement_class FOR TESTING.
    METHODS counts_slow   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_slow_mover IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_slow_mover( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_slow_mover=>ty_item.

    ls_item-material = iv_material.
    ls_item-movements = iv_movements.
    APPEND ls_item TO mt_item.
  ENDMETHOD.

  METHOD slow_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_slow( iv_movements = 1 iv_threshold = 3 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_slow( iv_movements = 5 iv_threshold = 3 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD movement_class.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->movement_class( 1 ) exp = 'SLOW' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->movement_class( 5 ) exp = 'MEDIUM' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->movement_class( 20 ) exp = 'FAST' ).
  ENDMETHOD.

  METHOD counts_slow.
    add( iv_material = 'M1' iv_movements = 1 ).
    add( iv_material = 'M2' iv_movements = 5 ).
    add( iv_material = 'M3' iv_movements = 2 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_slow( it_items = mt_item iv_threshold = 3 )
      exp = 2 ).
  ENDMETHOD.

ENDCLASS.
