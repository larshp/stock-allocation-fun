CLASS ltcl_alloc_return_load DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_load.
    DATA mt_itm TYPE zcl_alloc_return_load=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_quantity TYPE i
        iv_volume   TYPE i.

    METHODS plans_volumes     FOR TESTING.
    METHODS skips_empty_lines FOR TESTING.
    METHODS sums_volume       FOR TESTING.
    METHODS feasibility_rule  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_load IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_load( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_return_load=>ty_item.

    ls_item-material = iv_material.
    ls_item-quantity = iv_quantity.
    ls_item-unit_volume = iv_volume.
    APPEND ls_item TO mt_itm.
  ENDMETHOD.

  METHOD plans_volumes.
    DATA lt_load TYPE zcl_alloc_return_load=>ty_load_tt.

    add( iv_material = 'M1' iv_quantity = 2 iv_volume = 3 ).
    add( iv_material = 'M2' iv_quantity = 5 iv_volume = 2 ).

    lt_load = mo_cut->plan( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_load ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_load[ 1 ]-volume exp = 6 ).
    cl_abap_unit_assert=>assert_equals( act = lt_load[ 2 ]-volume exp = 10 ).
  ENDMETHOD.

  METHOD skips_empty_lines.
    DATA lt_load TYPE zcl_alloc_return_load=>ty_load_tt.

    add( iv_material = 'M1' iv_quantity = 0 iv_volume = 3 ).
    add( iv_material = 'M2' iv_quantity = 5 iv_volume = 0 ).
    add( iv_material = 'M3' iv_quantity = 1 iv_volume = 1 ).

    lt_load = mo_cut->plan( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_load ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_load[ 1 ]-material exp = 'M3' ).
  ENDMETHOD.

  METHOD sums_volume.
    add( iv_material = 'M1' iv_quantity = 2 iv_volume = 3 ).
    add( iv_material = 'M2' iv_quantity = 5 iv_volume = 2 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_volume( mt_itm ) exp = 16 ).
  ENDMETHOD.

  METHOD feasibility_rule.
    add( iv_material = 'M1' iv_quantity = 2 iv_volume = 3 ).
    add( iv_material = 'M2' iv_quantity = 5 iv_volume = 2 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_feasible( it_items = mt_itm iv_capacity = 20 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_feasible( it_items = mt_itm iv_capacity = 15 )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_feasible( it_items = mt_itm iv_capacity = 0 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
