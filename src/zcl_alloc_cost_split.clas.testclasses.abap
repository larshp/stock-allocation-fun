CLASS ltcl_alloc_cost_split DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cost_split.
    DATA mt_weight TYPE zcl_alloc_cost_split=>ty_weight_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_name   TYPE string
        iv_weight TYPE i.

    METHODS splits_total  FOR TESTING.
    METHODS reads_share   FOR TESTING.
    METHODS counts_parts  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cost_split IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cost_split( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_weight TYPE zcl_alloc_cost_split=>ty_weight.

    ls_weight-name = iv_name.
    ls_weight-weight = iv_weight.
    APPEND ls_weight TO mt_weight.
  ENDMETHOD.

  METHOD splits_total.
    DATA lt_components TYPE zcl_alloc_cost_split=>ty_component_tt.

    add( iv_name = 'BASE' iv_weight = 50 ).
    add( iv_name = 'FREIGHT' iv_weight = 30 ).
    add( iv_name = 'DUTY' iv_weight = 20 ).

    lt_components = mo_cut->split( iv_total = 1000 it_weights = mt_weight ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_components[ 1 ]-amount exp = 500 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_components[ 2 ]-amount exp = 300 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_components[ 3 ]-amount exp = 200 ).
  ENDMETHOD.

  METHOD reads_share.
    DATA lt_components TYPE zcl_alloc_cost_split=>ty_component_tt.

    add( iv_name = 'BASE' iv_weight = 50 ).
    add( iv_name = 'FREIGHT' iv_weight = 30 ).

    lt_components = mo_cut->split( iv_total = 1000 it_weights = mt_weight ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->share_of( it_components = lt_components
                              iv_name       = 'FREIGHT' )
      exp = 375 ).
  ENDMETHOD.

  METHOD counts_parts.
    DATA lt_components TYPE zcl_alloc_cost_split=>ty_component_tt.

    add( iv_name = 'BASE' iv_weight = 50 ).
    add( iv_name = 'FREIGHT' iv_weight = 30 ).

    lt_components = mo_cut->split( iv_total = 1000 it_weights = mt_weight ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->component_count( lt_components ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
