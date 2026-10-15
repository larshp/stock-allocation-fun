CLASS ltcl_alloc_layer_merge DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_layer_merge.
    DATA mt_layer TYPE zcl_alloc_layer_merge=>ty_layer_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_quantity TYPE i
        iv_price    TYPE i.

    METHODS merges_same_price FOR TESTING.
    METHODS counts_groups    FOR TESTING.
    METHODS picks_largest    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_layer_merge IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_layer_merge( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_layer TYPE zcl_alloc_layer_merge=>ty_layer.

    ls_layer-quantity = iv_quantity.
    ls_layer-price = iv_price.
    APPEND ls_layer TO mt_layer.
  ENDMETHOD.

  METHOD merges_same_price.
    DATA lt_merged TYPE zcl_alloc_layer_merge=>ty_layer_tt.

    add( iv_quantity = 100 iv_price = 10 ).
    add( iv_quantity = 50 iv_price = 12 ).
    add( iv_quantity = 30 iv_price = 10 ).

    lt_merged = mo_cut->merge( mt_layer ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_merged ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_merged[ 1 ]-price exp = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_merged[ 1 ]-quantity exp = 130 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_merged[ 2 ]-quantity exp = 50 ).
  ENDMETHOD.

  METHOD counts_groups.
    add( iv_quantity = 100 iv_price = 10 ).
    add( iv_quantity = 50 iv_price = 12 ).
    add( iv_quantity = 30 iv_price = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->group_count( mt_layer ) exp = 2 ).
  ENDMETHOD.

  METHOD picks_largest.
    add( iv_quantity = 100 iv_price = 10 ).
    add( iv_quantity = 50 iv_price = 12 ).
    add( iv_quantity = 30 iv_price = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->largest( mt_layer ) exp = 130 ).
  ENDMETHOD.

ENDCLASS.
