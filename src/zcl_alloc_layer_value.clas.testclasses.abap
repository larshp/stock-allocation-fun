CLASS ltcl_alloc_layer_value DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_layer_value.
    DATA mt_layer TYPE zcl_alloc_layer_value=>ty_layer_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_quantity TYPE i
        iv_price    TYPE i.

    METHODS values_layer  FOR TESTING.
    METHODS reads_layer   FOR TESTING.
    METHODS sums_value    FOR TESTING.
    METHODS guards_index  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_layer_value IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_layer_value( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_layer TYPE zcl_alloc_layer_value=>ty_layer.

    ls_layer-quantity = iv_quantity.
    ls_layer-price = iv_price.
    APPEND ls_layer TO mt_layer.
  ENDMETHOD.

  METHOD values_layer.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( iv_quantity = 100 iv_price = 10 ) exp = 1000 ).
  ENDMETHOD.

  METHOD reads_layer.
    add( iv_quantity = 100 iv_price = 10 ).
    add( iv_quantity = 50 iv_price = 12 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->layer_value( it_layers = mt_layer iv_index = 2 )
      exp = 600 ).
  ENDMETHOD.

  METHOD sums_value.
    add( iv_quantity = 100 iv_price = 10 ).
    add( iv_quantity = 50 iv_price = 12 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_value( mt_layer ) exp = 1600 ).
  ENDMETHOD.

  METHOD guards_index.
    add( iv_quantity = 100 iv_price = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->layer_value( it_layers = mt_layer iv_index = 5 ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
