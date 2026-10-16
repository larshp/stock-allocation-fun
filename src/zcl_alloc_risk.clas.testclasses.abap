CLASS ltcl_alloc_risk DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_risk.

    METHODS setup.

    METHODS add
      IMPORTING
        it_shortages        TYPE zcl_alloc_risk=>ty_shortage_tt
        iv_id               TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_shortage         TYPE menge_d
      RETURNING
        VALUE(rt_shortages) TYPE zcl_alloc_risk=>ty_shortage_tt.

    METHODS empty_list       FOR TESTING.
    METHODS low_risk         FOR TESTING.
    METHODS medium_risk      FOR TESTING.
    METHODS high_risk        FOR TESTING.
    METHODS totals_lines     FOR TESTING.
    METHODS zero_reference   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_risk IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_risk( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_row TYPE zcl_alloc_risk=>ty_shortage.

    rt_shortages = it_shortages.
    ls_row-requirement_id = iv_id.
    ls_row-shortage_qty = iv_shortage.
    APPEND ls_row TO rt_shortages.
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_shortages TYPE zcl_alloc_risk=>ty_shortage_tt.

    DATA(rs_risk) = mo_cut->assess( lt_shortages ).

    cl_abap_unit_assert=>assert_equals( act = rs_risk-lines exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = rs_risk-level exp = 'L' ).
  ENDMETHOD.

  METHOD low_risk.
    DATA lt_shortages TYPE zcl_alloc_risk=>ty_shortage_tt.

    lt_shortages = add( it_shortages = lt_shortages
                        iv_id        = 'REQ-1'
                        iv_shortage  = '10' ).

    DATA(rs_risk) = mo_cut->assess( it_shortages = lt_shortages
                                    iv_reference = '100' ).

    cl_abap_unit_assert=>assert_equals( act = rs_risk-risk_pct exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = rs_risk-level exp = 'L' ).
  ENDMETHOD.

  METHOD medium_risk.
    DATA lt_shortages TYPE zcl_alloc_risk=>ty_shortage_tt.

    lt_shortages = add( it_shortages = lt_shortages
                        iv_id        = 'REQ-1'
                        iv_shortage  = '30' ).

    DATA(rs_risk) = mo_cut->assess( it_shortages = lt_shortages
                                    iv_reference = '100' ).

    cl_abap_unit_assert=>assert_equals( act = rs_risk-risk_pct exp = 30 ).
    cl_abap_unit_assert=>assert_equals( act = rs_risk-level exp = 'M' ).
  ENDMETHOD.

  METHOD high_risk.
    DATA lt_shortages TYPE zcl_alloc_risk=>ty_shortage_tt.

    lt_shortages = add( it_shortages = lt_shortages
                        iv_id        = 'REQ-1'
                        iv_shortage  = '60' ).

    DATA(rs_risk) = mo_cut->assess( it_shortages = lt_shortages
                                    iv_reference = '100' ).

    cl_abap_unit_assert=>assert_equals( act = rs_risk-risk_pct exp = 60 ).
    cl_abap_unit_assert=>assert_equals( act = rs_risk-level exp = 'H' ).
  ENDMETHOD.

  METHOD totals_lines.
    DATA lt_shortages TYPE zcl_alloc_risk=>ty_shortage_tt.

    lt_shortages = add( it_shortages = lt_shortages
                        iv_id        = 'REQ-1'
                        iv_shortage  = '4' ).
    lt_shortages = add( it_shortages = lt_shortages
                        iv_id        = 'REQ-2'
                        iv_shortage  = '6' ).

    DATA(rs_risk) = mo_cut->assess( it_shortages = lt_shortages
                                    iv_reference = '100' ).

    cl_abap_unit_assert=>assert_equals( act = rs_risk-lines exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = rs_risk-shortage_qty exp = '10' ).
  ENDMETHOD.

  METHOD zero_reference.
    DATA lt_shortages TYPE zcl_alloc_risk=>ty_shortage_tt.

    lt_shortages = add( it_shortages = lt_shortages
                        iv_id        = 'REQ-1'
                        iv_shortage  = '60' ).

    DATA(rs_risk) = mo_cut->assess( lt_shortages ).

    cl_abap_unit_assert=>assert_equals( act = rs_risk-risk_pct exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = rs_risk-level exp = 'L' ).
  ENDMETHOD.

ENDCLASS.
