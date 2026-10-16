CLASS ltcl_alloc_copro_weight DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_copro_weight.
    DATA mt_line TYPE zcl_alloc_copro_weight=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_product     TYPE string
        iv_qty         TYPE i
        iv_unit_weight TYPE i.

    METHODS computes_weighted FOR TESTING.
    METHODS computes_weight   FOR TESTING.
    METHODS sums_weight       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_copro_weight IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_copro_weight( ).

    add( iv_product = 'P1' iv_qty = 2 iv_unit_weight = 3 ).
    add( iv_product = 'P2' iv_qty = 1 iv_unit_weight = 4 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_copro_weight=>ty_line.

    ls_line-product = iv_product.
    ls_line-qty = iv_qty.
    ls_line-unit_weight = iv_unit_weight.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD computes_weighted.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->weighted( iv_value = 10 iv_weight = 3 ) exp = 30 ).
  ENDMETHOD.

  METHOD computes_weight.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->weight_of( iv_qty = 2 iv_unit_weight = 5 ) exp = 10 ).
  ENDMETHOD.

  METHOD sums_weight.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_weight( mt_line ) exp = 10 ).
  ENDMETHOD.

ENDCLASS.
