CLASS ltcl_alloc_layer_fifo DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_layer_fifo.
    DATA mt_layer TYPE zcl_alloc_layer_fifo=>ty_layer_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_quantity TYPE i
        iv_price    TYPE i.

    METHODS consumes_layers FOR TESTING.
    METHODS leaves_rest     FOR TESTING.
    METHODS counts_used     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_layer_fifo IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_layer_fifo( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_layer TYPE zcl_alloc_layer_fifo=>ty_layer.

    ls_layer-quantity = iv_quantity.
    ls_layer-price = iv_price.
    APPEND ls_layer TO mt_layer.
  ENDMETHOD.

  METHOD consumes_layers.
    DATA lt_left TYPE zcl_alloc_layer_fifo=>ty_layer_tt.

    add( iv_quantity = 100 iv_price = 10 ).
    add( iv_quantity = 50 iv_price = 12 ).

    lt_left = mo_cut->consume( it_layers = mt_layer iv_qty = 120 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_left ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_left[ 1 ]-quantity exp = 30 ).
    cl_abap_unit_assert=>assert_equals( act = lt_left[ 1 ]-price exp = 12 ).
  ENDMETHOD.

  METHOD leaves_rest.
    DATA lt_left TYPE zcl_alloc_layer_fifo=>ty_layer_tt.

    add( iv_quantity = 100 iv_price = 10 ).
    add( iv_quantity = 50 iv_price = 12 ).

    lt_left = mo_cut->consume( it_layers = mt_layer iv_qty = 50 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_left ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->remaining( lt_left ) exp = 100 ).
  ENDMETHOD.

  METHOD counts_used.
    add( iv_quantity = 100 iv_price = 10 ).
    add( iv_quantity = 50 iv_price = 12 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->layers_used( it_layers = mt_layer iv_qty = 120 )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->layers_used( it_layers = mt_layer iv_qty = 50 )
      exp = 1 ).
  ENDMETHOD.

ENDCLASS.
