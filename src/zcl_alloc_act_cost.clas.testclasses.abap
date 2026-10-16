CLASS ltcl_alloc_act_cost DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_act_cost.
    DATA mt_cost TYPE zcl_alloc_act_cost=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_cost TYPE i.

    METHODS computes_cost     FOR TESTING.
    METHODS computes_per_unit FOR TESTING.
    METHODS sums_total        FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_act_cost IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_act_cost( ).

    add( iv_cost = 600 ).
    add( iv_cost = 300 ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_cost TO mt_cost.
  ENDMETHOD.

  METHOD computes_cost.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cost( iv_rate = 2 iv_quantity = 300 )
      exp = 600 ).
  ENDMETHOD.

  METHOD computes_per_unit.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_unit( iv_cost = 600 iv_quantity = 300 )
      exp = 2 ).
  ENDMETHOD.

  METHOD sums_total.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_cost ) exp = 900 ).
  ENDMETHOD.

ENDCLASS.
