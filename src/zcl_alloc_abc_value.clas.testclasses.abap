CLASS ltcl_alloc_abc_value DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_abc_value.
    DATA mt_item TYPE zcl_alloc_abc_value=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_value    TYPE i.

    METHODS computes_share FOR TESTING.
    METHODS classifies     FOR TESTING.
    METHODS class_at       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_abc_value IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_abc_value( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_abc_value=>ty_item.

    ls_item-material = iv_material.
    ls_item-value = iv_value.
    APPEND ls_item TO mt_item.
  ENDMETHOD.

  METHOD computes_share.
    add( iv_material = 'M1' iv_value = 80 ).
    add( iv_material = 'M2' iv_value = 15 ).
    add( iv_material = 'M3' iv_value = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value_share( it_items = mt_item iv_material = 'M1' )
      exp = 80 ).
  ENDMETHOD.

  METHOD classifies.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( 80 ) exp = 'A' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( 15 ) exp = 'C' ).
  ENDMETHOD.

  METHOD class_at.
    add( iv_material = 'M1' iv_value = 80 ).
    add( iv_material = 'M2' iv_value = 15 ).
    add( iv_material = 'M3' iv_value = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->class_at( it_items = mt_item iv_material = 'M2' )
      exp = 'C' ).
  ENDMETHOD.

ENDCLASS.
