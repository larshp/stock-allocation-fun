CLASS ltcl_alloc_cost_index DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cost_index.
    DATA mt_val TYPE zcl_alloc_cost_index=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS indexes_on_period FOR TESTING.
    METHODS rebases_series    FOR TESTING.
    METHODS computes_change   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cost_index IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cost_index( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_val.
  ENDMETHOD.

  METHOD indexes_on_period.
    DATA lt_index TYPE zcl_alloc_cost_index=>ty_values_tt.

    add( 50 ).
    add( 100 ).

    lt_index = mo_cut->index( it_values = mt_val iv_base_period = 2 ).

    cl_abap_unit_assert=>assert_equals( act = lt_index[ 1 ] exp = 50 ).
    cl_abap_unit_assert=>assert_equals( act = lt_index[ 2 ] exp = 100 ).
  ENDMETHOD.

  METHOD rebases_series.
    DATA lt_index TYPE zcl_alloc_cost_index=>ty_values_tt.

    add( 50 ).
    add( 100 ).

    lt_index = mo_cut->rebase( it_values = mt_val iv_base_value = 50 ).

    cl_abap_unit_assert=>assert_equals( act = lt_index[ 1 ] exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = lt_index[ 2 ] exp = 200 ).
  ENDMETHOD.

  METHOD computes_change.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->change_percent( iv_from = 100 iv_to = 110 ) exp = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->change_percent( iv_from = 0 iv_to = 110 ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
