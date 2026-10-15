CLASS ltcl_alloc_core_return DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_core_return.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_quantity TYPE i
        iv_returned TYPE i.

    METHODS sums_outstanding FOR TESTING.
    METHODS completion       FOR TESTING.
    METHODS unknown_material FOR TESTING.
    METHODS clears           FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_core_return IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_core_return( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_core TYPE zcl_alloc_core_return=>ty_core.

    ls_core-material = iv_material.
    ls_core-quantity = iv_quantity.
    ls_core-returned = iv_returned.
    mo_cut->add( ls_core ).
  ENDMETHOD.

  METHOD sums_outstanding.
    add( iv_material = 'M1' iv_quantity = 2 iv_returned = 2 ).
    add( iv_material = 'M1' iv_quantity = 3 iv_returned = 1 ).
    add( iv_material = 'M2' iv_quantity = 1 iv_returned = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->outstanding( 'M1' ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->outstanding( 'M2' ) exp = 1 ).
  ENDMETHOD.

  METHOD completion.
    add( iv_material = 'M1' iv_quantity = 2 iv_returned = 2 ).
    add( iv_material = 'M1' iv_quantity = 3 iv_returned = 1 ).
    add( iv_material = 'M3' iv_quantity = 1 iv_returned = 1 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_returned( 'M1' ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_returned( 'M3' ) exp = abap_true ).
  ENDMETHOD.

  METHOD unknown_material.
    add( iv_material = 'M1' iv_quantity = 2 iv_returned = 2 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->outstanding( 'M9' ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_returned( 'M9' ) exp = abap_false ).
  ENDMETHOD.

  METHOD clears.
    add( iv_material = 'M1' iv_quantity = 2 iv_returned = 2 ).
    mo_cut->clear( ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->outstanding( 'M1' ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
