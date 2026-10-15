CLASS ltcl_alloc_recycle_split DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_recycle_split.
    DATA mt_itm TYPE zcl_alloc_recycle_split=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_quantity TYPE i
        iv_percent  TYPE i.

    METHODS splits         FOR TESTING.
    METHODS clamps_percent FOR TESTING.
    METHODS sums_recycled  FOR TESTING.
    METHODS recovery       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_recycle_split IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_recycle_split( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_recycle_split=>ty_item.

    ls_item-material = iv_material.
    ls_item-quantity = iv_quantity.
    ls_item-recyclable_percent = iv_percent.
    APPEND ls_item TO mt_itm.
  ENDMETHOD.

  METHOD splits.
    DATA lt_lines TYPE zcl_alloc_recycle_split=>ty_line_tt.

    add( iv_material = 'M1' iv_quantity = 10 iv_percent = 80 ).
    add( iv_material = 'M2' iv_quantity = 10 iv_percent = 50 ).

    lt_lines = mo_cut->split( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ]-recyclable exp = 8 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-waste exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 2 ]-recyclable exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-waste exp = 5 ).
  ENDMETHOD.

  METHOD clamps_percent.
    DATA lt_lines TYPE zcl_alloc_recycle_split=>ty_line_tt.

    add( iv_material = 'M1' iv_quantity = 10 iv_percent = 150 ).

    lt_lines = mo_cut->split( mt_itm ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ]-recyclable exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-waste exp = 0 ).
  ENDMETHOD.

  METHOD sums_recycled.
    DATA lt_lines TYPE zcl_alloc_recycle_split=>ty_line_tt.

    add( iv_material = 'M1' iv_quantity = 10 iv_percent = 80 ).
    add( iv_material = 'M2' iv_quantity = 10 iv_percent = 50 ).

    lt_lines = mo_cut->split( mt_itm ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->recycled( lt_lines ) exp = 13 ).
  ENDMETHOD.

  METHOD recovery.
    DATA lt_lines TYPE zcl_alloc_recycle_split=>ty_line_tt.

    add( iv_material = 'M1' iv_quantity = 10 iv_percent = 80 ).
    add( iv_material = 'M2' iv_quantity = 10 iv_percent = 50 ).

    lt_lines = mo_cut->split( mt_itm ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->recovery_percent( lt_lines ) exp = 65 ).
  ENDMETHOD.

ENDCLASS.
