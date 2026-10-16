CLASS ltcl_alloc_val_wavg DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_val_wavg.
    DATA mt_layer TYPE zcl_alloc_val_wavg=>ty_layer_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_quantity TYPE i
        iv_price    TYPE i.

    METHODS computes_unit   FOR TESTING.
    METHODS values_quantity FOR TESTING.
    METHODS zero_rule       FOR TESTING.
    METHODS empty_input     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_val_wavg IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_val_wavg( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_layer TYPE zcl_alloc_val_wavg=>ty_layer.

    ls_layer-quantity = iv_quantity.
    ls_layer-price = iv_price.
    APPEND ls_layer TO mt_layer.
  ENDMETHOD.

  METHOD computes_unit.
    add( iv_quantity = 100 iv_price = 10 ).
    add( iv_quantity = 50 iv_price = 12 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->unit_cost( mt_layer ) exp = 10 ).
  ENDMETHOD.

  METHOD values_quantity.
    add( iv_quantity = 100 iv_price = 10 ).
    add( iv_quantity = 50 iv_price = 12 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( it_layers = mt_layer iv_quantity = 30 )
      exp = 300 ).
  ENDMETHOD.

  METHOD zero_rule.
    add( iv_quantity = 100 iv_price = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( mt_layer ) exp = abap_true ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->unit_cost( mt_layer ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( mt_layer ) exp = abap_true ).
  ENDMETHOD.

ENDCLASS.
