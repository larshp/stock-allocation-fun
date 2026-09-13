CLASS ltcl_alloc_subst_chain DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_subst_chain.

    METHODS setup.

    METHODS rule
      IMPORTING
        iv_from       TYPE matnr
        iv_to         TYPE matnr
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_subst_chain=>ty_rule.

    METHODS input
      IMPORTING
        it_rules      TYPE zcl_alloc_subst_chain=>ty_rule_tt
        iv_start      TYPE matnr
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_subst_chain=>ty_input.

    METHODS no_rule       FOR TESTING.
    METHODS single_hop    FOR TESTING.
    METHODS two_hops      FOR TESTING.
    METHODS loop_is_capped FOR TESTING.
    METHODS empty_rules   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_subst_chain IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_subst_chain( ).
  ENDMETHOD.

  METHOD rule.
    rs_row-from_matnr = iv_from.
    rs_row-to_matnr = iv_to.
  ENDMETHOD.

  METHOD input.
    rs_row-rules = it_rules.
    rs_row-start_matnr = iv_start.
  ENDMETHOD.

  METHOD no_rule.
    DATA lt_rules TYPE zcl_alloc_subst_chain=>ty_rule_tt.

    APPEND rule( iv_from = 'MAT-B' iv_to = 'MAT-C' ) TO lt_rules.

    DATA(rs_result) = mo_cut->resolve( input( it_rules = lt_rules
                                              iv_start = 'MAT-A' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-final_matnr
                                        exp = 'MAT-A' ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-steps exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lines( rs_result-path )
                                        exp = 1 ).
  ENDMETHOD.

  METHOD single_hop.
    DATA lt_rules TYPE zcl_alloc_subst_chain=>ty_rule_tt.

    APPEND rule( iv_from = 'MAT-A' iv_to = 'MAT-B' ) TO lt_rules.

    DATA(rs_result) = mo_cut->resolve( input( it_rules = lt_rules
                                              iv_start = 'MAT-A' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-final_matnr
                                        exp = 'MAT-B' ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-steps exp = 1 ).
  ENDMETHOD.

  METHOD two_hops.
    DATA lt_rules TYPE zcl_alloc_subst_chain=>ty_rule_tt.

    APPEND rule( iv_from = 'MAT-A' iv_to = 'MAT-B' ) TO lt_rules.
    APPEND rule( iv_from = 'MAT-B' iv_to = 'MAT-C' ) TO lt_rules.

    DATA(rs_result) = mo_cut->resolve( input( it_rules = lt_rules
                                              iv_start = 'MAT-A' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-final_matnr
                                        exp = 'MAT-C' ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-steps exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lines( rs_result-path )
                                        exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-path[ 2 ]
                                        exp = 'MAT-B' ).
  ENDMETHOD.

  METHOD loop_is_capped.
    DATA lt_rules TYPE zcl_alloc_subst_chain=>ty_rule_tt.

    APPEND rule( iv_from = 'MAT-A' iv_to = 'MAT-B' ) TO lt_rules.
    APPEND rule( iv_from = 'MAT-B' iv_to = 'MAT-A' ) TO lt_rules.

    DATA(rs_result) = mo_cut->resolve( input( it_rules = lt_rules
                                              iv_start = 'MAT-A' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-steps
                                        exp = lines( lt_rules ) ).
  ENDMETHOD.

  METHOD empty_rules.
    DATA lt_rules TYPE zcl_alloc_subst_chain=>ty_rule_tt.

    DATA(rs_result) = mo_cut->resolve( input( it_rules = lt_rules
                                              iv_start = 'MAT-A' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-steps exp = 0 ).
  ENDMETHOD.

ENDCLASS.
