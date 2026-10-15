CLASS ltcl_alloc_rout_cost DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_rout_cost.
    DATA mt_value TYPE zcl_alloc_rout_cost=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS computes_cost  FOR TESTING.
    METHODS computes_unit  FOR TESTING.
    METHODS sums_total     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_rout_cost IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_rout_cost( ).

    add( iv_value = 100 ).
    add( iv_value = 200 ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_value.
  ENDMETHOD.

  METHOD computes_cost.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cost( iv_setup_cost = 100 iv_run_cost = 20 iv_qty = 5 )
      exp = 200 ).
  ENDMETHOD.

  METHOD computes_unit.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_unit( iv_cost = 200 iv_qty = 5 ) exp = 40 ).
  ENDMETHOD.

  METHOD sums_total.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_value ) exp = 300 ).
  ENDMETHOD.

ENDCLASS.
