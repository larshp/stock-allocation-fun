CLASS ltcl_alloc_abc_total DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_abc_total.
    DATA mt_value TYPE zcl_alloc_abc_total=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS sums_total    FOR TESTING.
    METHODS reads_average FOR TESTING.
    METHODS zero_rule     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_abc_total IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_abc_total( ).

    add( iv_value = 600 ).
    add( iv_value = 300 ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_value.
  ENDMETHOD.

  METHOD sums_total.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_value ) exp = 900 ).
  ENDMETHOD.

  METHOD reads_average.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->average( mt_value ) exp = 450 ).
  ENDMETHOD.

  METHOD zero_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 0 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 900 ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
