CLASS ltcl_alloc_drv_total DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_drv_total.
    DATA mt_values TYPE zcl_alloc_drv_total=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS totals_values FOR TESTING.
    METHODS counts_values FOR TESTING.
    METHODS empty_rule    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_drv_total IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_drv_total( ).

    add( iv_value = 100 ).
    add( iv_value = 200 ).
    add( iv_value = 300 ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_values.
  ENDMETHOD.

  METHOD totals_values.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_values ) exp = 600 ).
  ENDMETHOD.

  METHOD counts_values.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count( mt_values ) exp = 3 ).
  ENDMETHOD.

  METHOD empty_rule.
    DATA lt_empty TYPE zcl_alloc_drv_total=>ty_values_tt.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_empty( lt_empty ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_empty( mt_values ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
