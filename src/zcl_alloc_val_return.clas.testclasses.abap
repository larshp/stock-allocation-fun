CLASS ltcl_alloc_val_return DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_val_return.

    METHODS setup.

    METHODS values_return     FOR TESTING.
    METHODS reduced_rule      FOR TESTING.
    METHODS computes_reduction FOR TESTING.
    METHODS full_reduction    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_val_return IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_val_return( ).
  ENDMETHOD.

  METHOD values_return.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( iv_original_value    = 1000
                           iv_reduction_percent = 20 )
      exp = 800 ).
  ENDMETHOD.

  METHOD reduced_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_reduced( 20 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_reduced( 0 ) exp = abap_false ).
  ENDMETHOD.

  METHOD computes_reduction.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reduction_percent( iv_original_value = 1000
                                       iv_return_value   = 800 )
      exp = 20 ).
  ENDMETHOD.

  METHOD full_reduction.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( iv_original_value    = 1000
                           iv_reduction_percent = 100 )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( iv_original_value    = 1000
                           iv_reduction_percent = 0 )
      exp = 1000 ).
  ENDMETHOD.

ENDCLASS.
