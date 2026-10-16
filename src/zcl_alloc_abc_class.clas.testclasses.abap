CLASS ltcl_alloc_abc_class DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_abc_class.
    DATA mt_item TYPE zcl_alloc_abc_class=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_value    TYPE i.

    METHODS classifies     FOR TESTING.
    METHODS reads_class    FOR TESTING.
    METHODS counts_class   FOR TESTING.
    METHODS empty_input    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_abc_class IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_abc_class( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_abc_class=>ty_item.

    ls_item-material = iv_material.
    ls_item-value = iv_value.
    APPEND ls_item TO mt_item.
  ENDMETHOD.

  METHOD classifies.
    DATA lt_class TYPE zcl_alloc_abc_class=>ty_item_tt.

    add( iv_material = 'M1' iv_value = 80 ).
    add( iv_material = 'M2' iv_value = 15 ).
    add( iv_material = 'M3' iv_value = 5 ).

    lt_class = mo_cut->classify( mt_item ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_class ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_class[ 1 ]-material exp = 'M1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_class[ 1 ]-class exp = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = lt_class[ 3 ]-class exp = 'C' ).
  ENDMETHOD.

  METHOD reads_class.
    DATA lt_class TYPE zcl_alloc_abc_class=>ty_item_tt.

    add( iv_material = 'M1' iv_value = 80 ).
    add( iv_material = 'M2' iv_value = 15 ).
    add( iv_material = 'M3' iv_value = 5 ).

    lt_class = mo_cut->classify( mt_item ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->class_of( it_items = lt_class iv_material = 'M2' )
      exp = 'B' ).
  ENDMETHOD.

  METHOD counts_class.
    DATA lt_class TYPE zcl_alloc_abc_class=>ty_item_tt.

    add( iv_material = 'M1' iv_value = 80 ).
    add( iv_material = 'M2' iv_value = 15 ).
    add( iv_material = 'M3' iv_value = 5 ).

    lt_class = mo_cut->classify( mt_item ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_in( it_items = lt_class iv_class = 'A' ) exp = 1 ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_cut->classify( mt_item ) ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
