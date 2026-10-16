CLASS ltcl_alloc_policy_preset DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_policy_preset.

    METHODS setup.

    METHODS fefo_preset     FOR TESTING.
    METHODS whole_preset    FOR TESTING.
    METHODS safe_preset     FOR TESTING.
    METHODS limit_preset    FOR TESTING.
    METHODS tolerant_preset FOR TESTING.
    METHODS unknown_is_default FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_policy_preset IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_policy_preset( ).
  ENDMETHOD.

  METHOD fefo_preset.
    DATA(rs_policy) = mo_cut->preset( 'FEFO' ).

    cl_abap_unit_assert=>assert_equals( act = rs_policy-use_fefo
                                        exp = abap_true ).
  ENDMETHOD.

  METHOD whole_preset.
    DATA(rs_policy) = mo_cut->preset( 'WHOLE' ).

    cl_abap_unit_assert=>assert_equals( act = rs_policy-whole_sales_units
                                        exp = abap_true ).
  ENDMETHOD.

  METHOD safe_preset.
    DATA(rs_policy) = mo_cut->preset( 'SAFE' ).

    cl_abap_unit_assert=>assert_equals( act = rs_policy-include_quality
                                        exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = rs_policy-include_blocked
                                        exp = abap_true ).
  ENDMETHOD.

  METHOD limit_preset.
    DATA(rs_policy) = mo_cut->preset( 'LIMIT' ).

    cl_abap_unit_assert=>assert_equals( act = rs_policy-max_picks exp = 1 ).
  ENDMETHOD.

  METHOD tolerant_preset.
    DATA(rs_policy) = mo_cut->preset( 'TOLERANT' ).

    cl_abap_unit_assert=>assert_equals( act = rs_policy-under_tolerance
                                        exp = 10 ).
  ENDMETHOD.

  METHOD unknown_is_default.
    DATA(rs_policy) = mo_cut->preset( 'NOPE' ).

    cl_abap_unit_assert=>assert_equals( act = rs_policy-max_picks exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = rs_policy-use_fefo
                                        exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
