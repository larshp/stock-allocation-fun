CLASS ltcl_alloc_copro_rank DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_copro_rank.
    DATA mt_line TYPE zcl_alloc_copro_rank=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_product TYPE string
        iv_value   TYPE i.

    METHODS ranks_products FOR TESTING.
    METHODS picks_largest  FOR TESTING.
    METHODS counts_products FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_copro_rank IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_copro_rank( ).

    add( iv_product = 'P1' iv_value = 60 ).
    add( iv_product = 'P2' iv_value = 90 ).
    add( iv_product = 'P3' iv_value = 30 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_copro_rank=>ty_line.

    ls_line-product = iv_product.
    ls_line-value = iv_value.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD ranks_products.
    DATA lt_ranked TYPE zcl_alloc_copro_rank=>ty_line_tt.

    lt_ranked = mo_cut->rank( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lt_ranked[ 1 ]-value exp = 90 ).
    cl_abap_unit_assert=>assert_equals( act = lt_ranked[ 3 ]-value exp = 30 ).
  ENDMETHOD.

  METHOD picks_largest.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->largest( mt_line ) exp = 90 ).
  ENDMETHOD.

  METHOD counts_products.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count( mt_line ) exp = 3 ).
  ENDMETHOD.

ENDCLASS.
