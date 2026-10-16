CLASS ltcl_alloc_layer_age DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_layer_age.
    DATA mt_layer TYPE zcl_alloc_layer_age=>ty_layer_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_receipt_day TYPE d
        iv_quantity    TYPE i.

    METHODS computes_age FOR TESTING.
    METHODS old_rule     FOR TESTING.
    METHODS reads_oldest FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_layer_age IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_layer_age( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_layer TYPE zcl_alloc_layer_age=>ty_layer.

    ls_layer-receipt_day = iv_receipt_day.
    ls_layer-quantity = iv_quantity.
    APPEND ls_layer TO mt_layer.
  ENDMETHOD.

  METHOD computes_age.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->age_days( iv_receipt_day = '20260101'
                              iv_today       = '20260111' )
      exp = 10 ).
  ENDMETHOD.

  METHOD old_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_old( iv_age_days = 100 iv_threshold = 90 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_old( iv_age_days = 30 iv_threshold = 90 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD reads_oldest.
    add( iv_receipt_day = '20260101' iv_quantity = 100 ).
    add( iv_receipt_day = '20260401' iv_quantity = 50 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->oldest( it_layers = mt_layer iv_today = '20260501' )
      exp = 120 ).
  ENDMETHOD.

ENDCLASS.
