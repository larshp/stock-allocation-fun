CLASS ltcl_alloc_cost_total DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cost_total.
    DATA mt_component TYPE zcl_alloc_cost_total=>ty_component_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_name   TYPE string
        iv_amount TYPE i.

    METHODS sums_components FOR TESTING.
    METHODS complete_rule   FOR TESTING.
    METHODS reads_share     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cost_total IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cost_total( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_component TYPE zcl_alloc_cost_total=>ty_component.

    ls_component-name = iv_name.
    ls_component-amount = iv_amount.
    APPEND ls_component TO mt_component.
  ENDMETHOD.

  METHOD sums_components.
    add( iv_name = 'BASE' iv_amount = 500 ).
    add( iv_name = 'FREIGHT' iv_amount = 300 ).
    add( iv_name = 'DUTY' iv_amount = 200 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_component ) exp = 1000 ).
  ENDMETHOD.

  METHOD complete_rule.
    add( iv_name = 'BASE' iv_amount = 500 ).
    add( iv_name = 'FREIGHT' iv_amount = 300 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_complete( it_components = mt_component iv_total = 800 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_complete( it_components = mt_component iv_total = 900 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD reads_share.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->share( iv_amount = 300 iv_total = 1000 ) exp = 30 ).
  ENDMETHOD.

ENDCLASS.
