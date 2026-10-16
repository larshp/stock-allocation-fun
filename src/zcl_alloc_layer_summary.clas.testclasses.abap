CLASS ltcl_alloc_layer_summary DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_layer_summary.
    DATA mt_layer TYPE zcl_alloc_layer_summary=>ty_layer_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_quantity TYPE i
        iv_price    TYPE i.

    METHODS builds_summary FOR TESTING.
    METHODS sums_quantity  FOR TESTING.
    METHODS sums_value     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_layer_summary IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_layer_summary( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_layer TYPE zcl_alloc_layer_summary=>ty_layer.

    ls_layer-quantity = iv_quantity.
    ls_layer-price = iv_price.
    APPEND ls_layer TO mt_layer.
  ENDMETHOD.

  METHOD builds_summary.
    DATA ls_summary TYPE zcl_alloc_layer_summary=>ty_summary.

    add( iv_quantity = 100 iv_price = 10 ).
    add( iv_quantity = 50 iv_price = 12 ).

    ls_summary = mo_cut->build( mt_layer ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-layer_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-total_qty exp = 150 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-total_value exp = 1600 ).
  ENDMETHOD.

  METHOD sums_quantity.
    add( iv_quantity = 100 iv_price = 10 ).
    add( iv_quantity = 50 iv_price = 12 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_qty( mt_layer ) exp = 150 ).
  ENDMETHOD.

  METHOD sums_value.
    add( iv_quantity = 100 iv_price = 10 ).
    add( iv_quantity = 50 iv_price = 12 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_value( mt_layer ) exp = 1600 ).
  ENDMETHOD.

ENDCLASS.
