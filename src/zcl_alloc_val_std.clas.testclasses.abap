CLASS ltcl_alloc_val_std DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_val_std.
    DATA mt_layer TYPE zcl_alloc_val_std=>ty_layer_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_quantity TYPE i
        iv_price    TYPE i.

    METHODS values_standard FOR TESTING.
    METHODS computes_unit   FOR TESTING.
    METHODS computes_variance FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_val_std IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_val_std( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_layer TYPE zcl_alloc_val_std=>ty_layer.

    ls_layer-quantity = iv_quantity.
    ls_layer-price = iv_price.
    APPEND ls_layer TO mt_layer.
  ENDMETHOD.

  METHOD values_standard.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( iv_quantity = 150 iv_standard_price = 11 )
      exp = 1650 ).
  ENDMETHOD.

  METHOD computes_unit.
    add( iv_quantity = 100 iv_price = 10 ).
    add( iv_quantity = 50 iv_price = 12 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->unit_cost( mt_layer ) exp = 10 ).
  ENDMETHOD.

  METHOD computes_variance.
    add( iv_quantity = 100 iv_price = 10 ).
    add( iv_quantity = 50 iv_price = 12 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->variance( it_layers = mt_layer iv_standard_price = 11 )
      exp = -50 ).
  ENDMETHOD.

ENDCLASS.
