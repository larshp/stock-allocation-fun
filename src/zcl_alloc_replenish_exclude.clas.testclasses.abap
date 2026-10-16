CLASS ltcl_alloc_replenish_exclude DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_replenish_exclude.
    DATA mt_item TYPE zcl_alloc_replenish_exclude=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material     TYPE matnr
        iv_blocked      TYPE abap_bool
        iv_discontinued TYPE abap_bool.

    METHODS exclusion_rule FOR TESTING.
    METHODS reason_text    FOR TESTING.
    METHODS counts_excluded FOR TESTING.
    METHODS empty_input    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_replenish_exclude IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_replenish_exclude( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_replenish_exclude=>ty_item.

    ls_item-material = iv_material.
    ls_item-blocked = iv_blocked.
    ls_item-discontinued = iv_discontinued.
    APPEND ls_item TO mt_item.
  ENDMETHOD.

  METHOD exclusion_rule.
    DATA ls_item TYPE zcl_alloc_replenish_exclude=>ty_item.

    ls_item-material = 'M1'.
    ls_item-blocked = abap_false.
    ls_item-discontinued = abap_false.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->should_exclude( ls_item ) exp = abap_false ).

    ls_item-blocked = abap_true.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->should_exclude( ls_item ) exp = abap_true ).
  ENDMETHOD.

  METHOD reason_text.
    DATA ls_item TYPE zcl_alloc_replenish_exclude=>ty_item.

    ls_item-blocked = abap_true.
    ls_item-discontinued = abap_true.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( ls_item ) exp = 'BLOCKED' ).

    ls_item-blocked = abap_false.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( ls_item ) exp = 'DISCONTINUED' ).

    ls_item-discontinued = abap_false.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( ls_item ) exp = 'OK' ).
  ENDMETHOD.

  METHOD counts_excluded.
    add( iv_material = 'M1' iv_blocked = abap_false iv_discontinued = abap_false ).
    add( iv_material = 'M2' iv_blocked = abap_true iv_discontinued = abap_false ).
    add( iv_material = 'M3' iv_blocked = abap_false iv_discontinued = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->excluded_count( mt_item ) exp = 2 ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->excluded_count( mt_item ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
