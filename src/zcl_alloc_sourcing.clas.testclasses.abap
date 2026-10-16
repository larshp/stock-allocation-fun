CLASS ltcl_alloc_sourcing DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_sourcing.
    DATA mt_rul TYPE zcl_alloc_sourcing=>ty_rule_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_matnr TYPE matnr
        iv_werks TYPE werks_d
        iv_src   TYPE string
        iv_prio  TYPE i
        iv_quota TYPE i.

    METHODS empty_rules       FOR TESTING.
    METHODS single_rule       FOR TESTING.
    METHODS lower_priority    FOR TESTING.
    METHODS quota_breaks_tie  FOR TESTING.
    METHODS counts_shares     FOR TESTING.
    METHODS splits_by_plant   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_sourcing IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_sourcing( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_rule TYPE zcl_alloc_sourcing=>ty_rule.

    ls_rule-matnr = iv_matnr.
    ls_rule-werks = iv_werks.
    ls_rule-source_node = iv_src.
    ls_rule-priority = iv_prio.
    ls_rule-quota_pct = iv_quota.
    APPEND ls_rule TO mt_rul.
  ENDMETHOD.

  METHOD empty_rules.
    DATA(lt_results) = mo_cut->evaluate( mt_rul ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_results ) exp = 0 ).
  ENDMETHOD.

  METHOD single_rule.
    add( iv_matnr = 'M1' iv_werks = '1000' iv_src = 'PLANT_A'
         iv_prio = 1 iv_quota = 100 ).

    DATA(lt_results) = mo_cut->evaluate( mt_rul ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_results ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_results[ 1 ]-source_node exp = 'PLANT_A' ).
    cl_abap_unit_assert=>assert_equals( act = lt_results[ 1 ]-shares exp = 1 ).
  ENDMETHOD.

  METHOD lower_priority.
    add( iv_matnr = 'M1' iv_werks = '1000' iv_src = 'SLOW'
         iv_prio = 2 iv_quota = 100 ).
    add( iv_matnr = 'M1' iv_werks = '1000' iv_src = 'FAST'
         iv_prio = 1 iv_quota = 10 ).

    DATA(lt_results) = mo_cut->evaluate( mt_rul ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_results ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_results[ 1 ]-source_node exp = 'FAST' ).
    cl_abap_unit_assert=>assert_equals( act = lt_results[ 1 ]-priority exp = 1 ).
  ENDMETHOD.

  METHOD quota_breaks_tie.
    add( iv_matnr = 'M1' iv_werks = '1000' iv_src = 'SMALL'
         iv_prio = 1 iv_quota = 40 ).
    add( iv_matnr = 'M1' iv_werks = '1000' iv_src = 'BIG'
         iv_prio = 1 iv_quota = 70 ).

    DATA(lt_results) = mo_cut->evaluate( mt_rul ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_results ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_results[ 1 ]-source_node exp = 'BIG' ).
    cl_abap_unit_assert=>assert_equals( act = lt_results[ 1 ]-quota_pct exp = 70 ).
  ENDMETHOD.

  METHOD counts_shares.
    add( iv_matnr = 'M1' iv_werks = '1000' iv_src = 'A' iv_prio = 1 iv_quota = 50 ).
    add( iv_matnr = 'M1' iv_werks = '1000' iv_src = 'B' iv_prio = 2 iv_quota = 30 ).
    add( iv_matnr = 'M1' iv_werks = '1000' iv_src = 'C' iv_prio = 3 iv_quota = 20 ).

    DATA(lt_results) = mo_cut->evaluate( mt_rul ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_results ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_results[ 1 ]-shares exp = 3 ).
  ENDMETHOD.

  METHOD splits_by_plant.
    add( iv_matnr = 'M1' iv_werks = '1000' iv_src = 'P1' iv_prio = 1 iv_quota = 100 ).
    add( iv_matnr = 'M1' iv_werks = '2000' iv_src = 'P2' iv_prio = 1 iv_quota = 100 ).

    DATA(lt_results) = mo_cut->evaluate( mt_rul ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_results ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_results[ 1 ]-source_node exp = 'P1' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_results[ 2 ]-source_node exp = 'P2' ).
  ENDMETHOD.

ENDCLASS.
