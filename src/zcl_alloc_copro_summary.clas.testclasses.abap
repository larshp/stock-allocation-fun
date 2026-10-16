CLASS ltcl_alloc_copro_summary DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_copro_summary.
    DATA mt_line TYPE zcl_alloc_copro_summary=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_product TYPE string
        iv_value   TYPE i.

    METHODS builds_summary FOR TESTING.
    METHODS counts_products FOR TESTING.
    METHODS sums_total     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_copro_summary IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_copro_summary( ).

    add( iv_product = 'P1' iv_value = 60 ).
    add( iv_product = 'P2' iv_value = 30 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_copro_summary=>ty_line.

    ls_line-product = iv_product.
    ls_line-value = iv_value.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_summary.
    DATA ls_summary TYPE zcl_alloc_copro_summary=>ty_summary.

    ls_summary = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-product_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-total exp = 90 ).
  ENDMETHOD.

  METHOD counts_products.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->product_count( mt_line ) exp = 2 ).
  ENDMETHOD.

  METHOD sums_total.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_line ) exp = 90 ).
  ENDMETHOD.

ENDCLASS.
