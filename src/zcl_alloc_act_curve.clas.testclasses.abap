CLASS ltcl_alloc_act_curve DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_act_curve.
    DATA mt_values TYPE zcl_alloc_act_curve=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS improving_rule FOR TESTING.
    METHODS reads_change   FOR TESTING.
    METHODS counts_values  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_act_curve IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_act_curve( ).

    add( iv_value = 3 ).
    add( iv_value = 2 ).
    add( iv_value = 1 ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_values.
  ENDMETHOD.

  METHOD improving_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_improving( mt_values ) exp = abap_true ).
  ENDMETHOD.

  METHOD reads_change.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->change( mt_values ) exp = -2 ).
  ENDMETHOD.

  METHOD counts_values.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count( mt_values ) exp = 3 ).
  ENDMETHOD.

ENDCLASS.
