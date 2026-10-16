CLASS ltcl_alloc_base_value DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_base_value.
    DATA mt_value TYPE zcl_alloc_base_value=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS computes_value FOR TESTING.
    METHODS sums_total     FOR TESTING.
    METHODS zero_rule      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_base_value IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_base_value( ).

    add( iv_value = 1000 ).
    add( iv_value = 500 ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_value.
  ENDMETHOD.

  METHOD computes_value.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( iv_quantity = 100 iv_price = 10 )
      exp = 1000 ).
  ENDMETHOD.

  METHOD sums_total.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_value ) exp = 1500 ).
  ENDMETHOD.

  METHOD zero_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 0 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 1000 ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
