CLASS ltcl_alloc_inventory_risk DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_inventory_risk.
    DATA mt_val TYPE zcl_alloc_inventory_risk=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS computes_risk FOR TESTING.
    METHODS high_rule     FOR TESTING.
    METHODS counts_high   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_inventory_risk IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_inventory_risk( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_val.
  ENDMETHOD.

  METHOD computes_risk.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->risk( iv_age_days = 100 iv_excess_percent = 20
                          iv_service_percent = 90 )
      exp = 45 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->risk( iv_age_days = 400 iv_excess_percent = 30
                          iv_service_percent = 90 )
      exp = 75 ).
  ENDMETHOD.

  METHOD high_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_high( iv_risk = 45 iv_threshold = 50 )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_high( iv_risk = 75 iv_threshold = 50 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD counts_high.
    add( 45 ).
    add( 75 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_high( it_values = mt_val iv_threshold = 50 )
      exp = 1 ).
  ENDMETHOD.

ENDCLASS.
