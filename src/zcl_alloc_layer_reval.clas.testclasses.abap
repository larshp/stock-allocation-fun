CLASS ltcl_alloc_layer_reval DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_layer_reval.
    DATA mt_layer TYPE zcl_alloc_layer_reval=>ty_layer_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_quantity TYPE i
        iv_price    TYPE i.

    METHODS revalues_layers FOR TESTING.
    METHODS computes_delta  FOR TESTING.
    METHODS up_rule         FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_layer_reval IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_layer_reval( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_layer TYPE zcl_alloc_layer_reval=>ty_layer.

    ls_layer-quantity = iv_quantity.
    ls_layer-price = iv_price.
    APPEND ls_layer TO mt_layer.
  ENDMETHOD.

  METHOD revalues_layers.
    DATA lt_new TYPE zcl_alloc_layer_reval=>ty_layer_tt.

    add( iv_quantity = 100 iv_price = 10 ).
    add( iv_quantity = 50 iv_price = 12 ).

    lt_new = mo_cut->revalue( it_layers = mt_layer iv_new_price = 15 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_new ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_new[ 1 ]-price exp = 15 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_new[ 1 ]-quantity exp = 100 ).
  ENDMETHOD.

  METHOD computes_delta.
    add( iv_quantity = 100 iv_price = 10 ).
    add( iv_quantity = 50 iv_price = 12 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->delta_value( it_layers = mt_layer iv_new_price = 15 )
      exp = 650 ).
  ENDMETHOD.

  METHOD up_rule.
    add( iv_quantity = 100 iv_price = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_up( it_layers = mt_layer iv_new_price = 15 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_up( it_layers = mt_layer iv_new_price = 5 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
