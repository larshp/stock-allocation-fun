CLASS ltcl_alloc_xyz DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_xyz.
    DATA mt_item TYPE zcl_alloc_xyz=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_mean     TYPE i
        iv_std_dev  TYPE i.

    METHODS classifies   FOR TESTING.
    METHODS reads_class  FOR TESTING.
    METHODS stable_rule  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_xyz IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_xyz( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_xyz=>ty_item.

    ls_item-material = iv_material.
    ls_item-mean = iv_mean.
    ls_item-std_dev = iv_std_dev.
    APPEND ls_item TO mt_item.
  ENDMETHOD.

  METHOD classifies.
    DATA ls_item TYPE zcl_alloc_xyz=>ty_item.

    ls_item-mean = 100.
    ls_item-std_dev = 10.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( ls_item ) exp = 'X' ).

    ls_item-std_dev = 30.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( ls_item ) exp = 'Y' ).

    ls_item-std_dev = 60.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( ls_item ) exp = 'Z' ).
  ENDMETHOD.

  METHOD reads_class.
    add( iv_material = 'M1' iv_mean = 100 iv_std_dev = 30 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->class_of( it_items = mt_item iv_material = 'M1' )
      exp = 'Y' ).
  ENDMETHOD.

  METHOD stable_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_stable( 'X' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_stable( 'Y' ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
