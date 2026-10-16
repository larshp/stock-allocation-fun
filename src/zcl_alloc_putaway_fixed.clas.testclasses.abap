CLASS ltcl_alloc_putaway_fixed DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_putaway_fixed.
    DATA mt_fix TYPE zcl_alloc_putaway_fixed=>ty_fixed_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_bin      TYPE string.

    METHODS finds_bin   FOR TESTING.
    METHODS unknown_bin FOR TESTING.
    METHODS empty_rules FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_putaway_fixed IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_putaway_fixed( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_fixed TYPE zcl_alloc_putaway_fixed=>ty_fixed.

    ls_fixed-material = iv_material.
    ls_fixed-bin_id = iv_bin.
    APPEND ls_fixed TO mt_fix.
  ENDMETHOD.

  METHOD finds_bin.
    add( iv_material = 'M1' iv_bin = 'A-01' ).
    add( iv_material = 'M2' iv_bin = 'B-02' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->assign( it_fixed = mt_fix iv_material = 'M2' )
      exp = 'B-02' ).
  ENDMETHOD.

  METHOD unknown_bin.
    add( iv_material = 'M1' iv_bin = 'A-01' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->assign( it_fixed = mt_fix iv_material = 'M9' )
      exp = '' ).
  ENDMETHOD.

  METHOD empty_rules.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->assign( it_fixed = mt_fix iv_material = 'M1' )
      exp = '' ).
  ENDMETHOD.

ENDCLASS.
