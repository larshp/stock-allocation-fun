CLASS ltcl_alloc_policy_merge DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_policy_merge.

    METHODS setup.

    METHODS input
      IMPORTING
        is_base       TYPE zcl_stock_allocator=>ty_policy
        is_override   TYPE zcl_stock_allocator=>ty_policy
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_policy_merge=>ty_input.

    METHODS override_flag     FOR TESTING.
    METHODS bool_false_keeps  FOR TESTING.
    METHODS override_scalar   FOR TESTING.
    METHODS zero_keeps_base   FOR TESTING.
    METHODS empty_override    FOR TESTING.
    METHODS table_replaces    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_policy_merge IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_policy_merge( ).
  ENDMETHOD.

  METHOD input.
    rs_row-base = is_base.
    rs_row-override = is_override.
  ENDMETHOD.

  METHOD override_flag.
    DATA ls_base     TYPE zcl_stock_allocator=>ty_policy.
    DATA ls_override TYPE zcl_stock_allocator=>ty_policy.

    ls_override-use_fefo = abap_true.

    DATA ls_input TYPE zcl_alloc_policy_merge=>ty_input.
    ls_input-base = ls_base.
    ls_input-override = ls_override.
    DATA(rs_policy) = mo_cut->merge( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = rs_policy-use_fefo
                                        exp = abap_true ).
  ENDMETHOD.

  METHOD bool_false_keeps.
    DATA ls_base     TYPE zcl_stock_allocator=>ty_policy.
    DATA ls_override TYPE zcl_stock_allocator=>ty_policy.

    ls_base-use_fefo = abap_true.
    ls_override-use_fefo = abap_false.

    DATA ls_input TYPE zcl_alloc_policy_merge=>ty_input.
    ls_input-base = ls_base.
    ls_input-override = ls_override.
    DATA(rs_policy) = mo_cut->merge( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = rs_policy-use_fefo
                                        exp = abap_true ).
  ENDMETHOD.

  METHOD override_scalar.
    DATA ls_base     TYPE zcl_stock_allocator=>ty_policy.
    DATA ls_override TYPE zcl_stock_allocator=>ty_policy.

    ls_base-max_picks = 2.
    ls_override-max_picks = 5.

    DATA ls_input TYPE zcl_alloc_policy_merge=>ty_input.
    ls_input-base = ls_base.
    ls_input-override = ls_override.
    DATA(rs_policy) = mo_cut->merge( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = rs_policy-max_picks exp = 5 ).
  ENDMETHOD.

  METHOD zero_keeps_base.
    DATA ls_base     TYPE zcl_stock_allocator=>ty_policy.
    DATA ls_override TYPE zcl_stock_allocator=>ty_policy.

    ls_base-under_tolerance = 7.

    DATA ls_input TYPE zcl_alloc_policy_merge=>ty_input.
    ls_input-base = ls_base.
    ls_input-override = ls_override.
    DATA(rs_policy) = mo_cut->merge( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = rs_policy-under_tolerance
                                        exp = 7 ).
  ENDMETHOD.

  METHOD empty_override.
    DATA ls_base     TYPE zcl_stock_allocator=>ty_policy.
    DATA ls_override TYPE zcl_stock_allocator=>ty_policy.

    ls_base-safety_stock = '5'.

    DATA ls_input TYPE zcl_alloc_policy_merge=>ty_input.
    ls_input-base = ls_base.
    ls_input-override = ls_override.
    DATA(rs_policy) = mo_cut->merge( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = rs_policy-safety_stock
                                        exp = '5' ).
  ENDMETHOD.

  METHOD table_replaces.
    DATA ls_base     TYPE zcl_stock_allocator=>ty_policy.
    DATA ls_override TYPE zcl_stock_allocator=>ty_policy.

    APPEND '0001' TO ls_base-allowed_lgorts.
    APPEND '0002' TO ls_override-allowed_lgorts.

    DATA ls_input TYPE zcl_alloc_policy_merge=>ty_input.
    ls_input-base = ls_base.
    ls_input-override = ls_override.
    DATA(rs_policy) = mo_cut->merge( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( rs_policy-allowed_lgorts )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = rs_policy-allowed_lgorts[ 1 ] exp = '0002' ).
  ENDMETHOD.

ENDCLASS.
