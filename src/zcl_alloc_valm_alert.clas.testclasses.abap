CLASS ltcl_alloc_valm_alert DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_valm_alert.
    DATA mt_line TYPE zcl_alloc_valm_alert=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_value    TYPE i
        iv_limit    TYPE i.

    METHODS raises_alerts FOR TESTING.
    METHODS counts_alerts FOR TESTING.
    METHODS alerting_rule FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_valm_alert IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_valm_alert( ).

    add( iv_material = 'M1' iv_value = 1500 iv_limit = 1000 ).
    add( iv_material = 'M2' iv_value = 800 iv_limit = 1000 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_valm_alert=>ty_line.

    ls_line-material = iv_material.
    ls_line-value = iv_value.
    ls_line-limit = iv_limit.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD raises_alerts.
    DATA lt_alerts TYPE zcl_alloc_valm_alert=>ty_alert_tt.

    lt_alerts = mo_cut->alerts( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_alerts ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_alerts[ 1 ]-material exp = 'M1' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_alerts[ 1 ]-message exp = 'value over limit' ).
  ENDMETHOD.

  METHOD counts_alerts.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->alert_count( mt_line ) exp = 1 ).
  ENDMETHOD.

  METHOD alerting_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_alerting( iv_value = 1500 iv_limit = 1000 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_alerting( iv_value = 800 iv_limit = 1000 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
