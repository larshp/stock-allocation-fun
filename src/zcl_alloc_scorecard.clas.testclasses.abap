CLASS ltcl_alloc_scorecard DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_scorecard.
    DATA mt_met TYPE zcl_alloc_scorecard=>ty_metric_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_id     TYPE string
        iv_target TYPE menge_d
        iv_actual TYPE menge_d
        iv_weight TYPE i.

    METHODS empty_metrics FOR TESTING.
    METHODS above_target  FOR TESTING.
    METHODS below_target  FOR TESTING.
    METHODS exact_target  FOR TESTING.
    METHODS counts_met    FOR TESTING.
    METHODS keeps_order   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_scorecard IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_scorecard( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_metric TYPE zcl_alloc_scorecard=>ty_metric.

    ls_metric-metric_id = iv_id.
    ls_metric-target_value = iv_target.
    ls_metric-actual_value = iv_actual.
    ls_metric-weight = iv_weight.
    APPEND ls_metric TO mt_met.
  ENDMETHOD.

  METHOD empty_metrics.
    DATA(lt_rows) = mo_cut->build( mt_met ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_rows ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->met_count( lt_rows ) exp = 0 ).
  ENDMETHOD.

  METHOD above_target.
    add( iv_id = 'OTIF' iv_target = 100 iv_actual = 110 iv_weight = 3 ).

    DATA(lt_rows) = mo_cut->build( mt_met ).

    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 1 ]-met exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 1 ]-gap exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 1 ]-weight exp = 3 ).
  ENDMETHOD.

  METHOD below_target.
    add( iv_id = 'FILL' iv_target = 50 iv_actual = 40 iv_weight = 1 ).

    DATA(lt_rows) = mo_cut->build( mt_met ).

    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 1 ]-met exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 1 ]-gap exp = -10 ).
  ENDMETHOD.

  METHOD exact_target.
    add( iv_id = 'EXACT' iv_target = 90 iv_actual = 90 iv_weight = 2 ).

    DATA(lt_rows) = mo_cut->build( mt_met ).

    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 1 ]-met exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 1 ]-gap exp = 0 ).
  ENDMETHOD.

  METHOD counts_met.
    add( iv_id = 'A' iv_target = 100 iv_actual = 110 iv_weight = 3 ).
    add( iv_id = 'B' iv_target = 50 iv_actual = 40 iv_weight = 1 ).

    DATA(lt_rows) = mo_cut->build( mt_met ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_rows ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->met_count( lt_rows ) exp = 1 ).
  ENDMETHOD.

  METHOD keeps_order.
    add( iv_id = 'ZETA' iv_target = 1 iv_actual = 1 iv_weight = 1 ).
    add( iv_id = 'ALPHA' iv_target = 1 iv_actual = 1 iv_weight = 1 ).

    DATA(lt_rows) = mo_cut->build( mt_met ).

    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 1 ]-metric_id exp = 'ZETA' ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 2 ]-metric_id exp = 'ALPHA' ).
  ENDMETHOD.

ENDCLASS.
