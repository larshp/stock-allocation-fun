CLASS ltcl_alloc_restock_split DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_restock_split.

    METHODS setup.

    METHODS splits_normally FOR TESTING.
    METHODS clamps_high     FOR TESTING.
    METHODS clamps_negative FOR TESTING.
    METHODS zero_quantity   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_restock_split IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_restock_split( ).
  ENDMETHOD.

  METHOD splits_normally.
    DATA ls_split TYPE zcl_alloc_restock_split=>ty_split.

    ls_split = mo_cut->split( iv_quantity = 10 iv_blocked = 3 ).

    cl_abap_unit_assert=>assert_equals( act = ls_split-sellable exp = 7 ).
    cl_abap_unit_assert=>assert_equals( act = ls_split-blocked exp = 3 ).
  ENDMETHOD.

  METHOD clamps_high.
    DATA ls_split TYPE zcl_alloc_restock_split=>ty_split.

    ls_split = mo_cut->split( iv_quantity = 10 iv_blocked = 20 ).

    cl_abap_unit_assert=>assert_equals( act = ls_split-sellable exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_split-blocked exp = 10 ).
  ENDMETHOD.

  METHOD clamps_negative.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->blocked( iv_quantity = 10 iv_blocked = -2 ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->sellable( iv_quantity = 10 iv_blocked = -2 ) exp = 10 ).
  ENDMETHOD.

  METHOD zero_quantity.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->sellable( iv_quantity = 0 iv_blocked = 3 ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->blocked( iv_quantity = 0 iv_blocked = 3 ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
