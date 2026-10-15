CLASS ltcl_alloc_base_weight DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_base_weight.
    DATA mt_weight TYPE zcl_alloc_base_weight=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_weight TYPE i.

    METHODS computes_weight FOR TESTING.
    METHODS sums_total      FOR TESTING.
    METHODS zero_rule       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_base_weight IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_base_weight( ).

    add( iv_weight = 50 ).
    add( iv_weight = 25 ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_weight TO mt_weight.
  ENDMETHOD.

  METHOD computes_weight.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->weight_of( iv_base = 100 iv_total = 400 )
      exp = 25 ).
  ENDMETHOD.

  METHOD sums_total.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_weight ) exp = 75 ).
  ENDMETHOD.

  METHOD zero_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 0 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 50 ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
