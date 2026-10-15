CLASS ltcl_alloc_replenish_alert DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_replenish_alert.
    DATA mt_item TYPE zcl_alloc_replenish_alert=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_rate     TYPE i.

    METHODS alert_rule   FOR TESTING.
    METHODS counts_alerts FOR TESTING.
    METHODS builds_alerts FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_replenish_alert IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_replenish_alert( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_replenish_alert=>ty_item.

    ls_item-material = iv_material.
    ls_item-rate = iv_rate.
    APPEND ls_item TO mt_item.
  ENDMETHOD.

  METHOD alert_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_alert( iv_rate = 80 iv_target = 90 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_alert( iv_rate = 95 iv_target = 90 ) exp = abap_false ).
  ENDMETHOD.

  METHOD counts_alerts.
    add( iv_material = 'M1' iv_rate = 80 ).
    add( iv_material = 'M2' iv_rate = 95 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->alert_count( it_items = mt_item iv_target = 90 )
      exp = 1 ).
  ENDMETHOD.

  METHOD builds_alerts.
    DATA lt_alert TYPE zcl_alloc_replenish_alert=>ty_alert_tt.

    add( iv_material = 'M1' iv_rate = 80 ).
    add( iv_material = 'M2' iv_rate = 95 ).

    lt_alert = mo_cut->build( it_items = mt_item iv_target = 90 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_alert ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_alert[ 1 ]-material exp = 'M1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_alert[ 1 ]-level exp = 'LOW' ).
  ENDMETHOD.

ENDCLASS.
