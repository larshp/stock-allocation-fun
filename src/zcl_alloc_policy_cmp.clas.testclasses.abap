CLASS ltcl_alloc_policy_cmp DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_policy_cmp.
    DATA mt_pol TYPE zcl_alloc_policy_cmp=>ty_policy_tt.
    DATA mt_dem TYPE zcl_alloc_fill_sim=>ty_series_tt.

    METHODS setup.

    METHODS add_demand
      IMPORTING
        iv_value TYPE menge_d.

    METHODS add_policy
      IMPORTING
        iv_id     TYPE string
        iv_stock1 TYPE menge_d
        iv_stock2 TYPE menge_d.

    METHODS empty_policies FOR TESTING.
    METHODS marks_best     FOR TESTING.
    METHODS reports_fill   FOR TESTING.
    METHODS first_wins_tie FOR TESTING.
    METHODS keeps_order    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_policy_cmp IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_policy_cmp( ).
  ENDMETHOD.

  METHOD add_demand.
    APPEND iv_value TO mt_dem.
  ENDMETHOD.

  METHOD add_policy.
    DATA ls_policy TYPE zcl_alloc_policy_cmp=>ty_policy.

    ls_policy-policy_id = iv_id.
    APPEND iv_stock1 TO ls_policy-stock.
    APPEND iv_stock2 TO ls_policy-stock.
    APPEND ls_policy TO mt_pol.
  ENDMETHOD.

  METHOD empty_policies.
    add_demand( iv_value = 10 ).

    DATA(lt_rows) = mo_cut->compare( it_policies = mt_pol
                                     it_demand   = mt_dem ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_rows ) exp = 0 ).
  ENDMETHOD.

  METHOD marks_best.
    add_demand( iv_value = 10 ).
    add_demand( iv_value = 10 ).
    add_policy( iv_id = 'LEAN' iv_stock1 = 5 iv_stock2 = 5 ).
    add_policy( iv_id = 'SAFE' iv_stock1 = 10 iv_stock2 = 10 ).

    DATA(lt_rows) = mo_cut->compare( it_policies = mt_pol
                                     it_demand   = mt_dem ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_rows ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 1 ]-best exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 2 ]-best exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 2 ]-policy_id exp = 'SAFE' ).
  ENDMETHOD.

  METHOD reports_fill.
    add_demand( iv_value = 10 ).
    add_demand( iv_value = 10 ).
    add_policy( iv_id = 'LEAN' iv_stock1 = 5 iv_stock2 = 5 ).

    DATA(lt_rows) = mo_cut->compare( it_policies = mt_pol
                                     it_demand   = mt_dem ).

    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 1 ]-fill_x100 exp = 50 ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 1 ]-served exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 1 ]-stockouts exp = 2 ).
  ENDMETHOD.

  METHOD first_wins_tie.
    add_demand( iv_value = 10 ).
    add_policy( iv_id = 'FIRST' iv_stock1 = 10 iv_stock2 = 0 ).
    add_policy( iv_id = 'SECOND' iv_stock1 = 10 iv_stock2 = 0 ).

    DATA(lt_rows) = mo_cut->compare( it_policies = mt_pol
                                     it_demand   = mt_dem ).

    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 1 ]-best exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 2 ]-best exp = abap_false ).
  ENDMETHOD.

  METHOD keeps_order.
    add_demand( iv_value = 10 ).
    add_policy( iv_id = 'ZETA' iv_stock1 = 10 iv_stock2 = 0 ).
    add_policy( iv_id = 'ALPHA' iv_stock1 = 10 iv_stock2 = 0 ).

    DATA(lt_rows) = mo_cut->compare( it_policies = mt_pol
                                     it_demand   = mt_dem ).

    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 1 ]-policy_id exp = 'ZETA' ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 2 ]-policy_id exp = 'ALPHA' ).
  ENDMETHOD.

ENDCLASS.
