CLASS ltcl_alloc_fill_sim DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_fill_sim.
    DATA mt_in  TYPE zcl_alloc_fill_sim=>ty_input.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_demand TYPE menge_d
        iv_stock  TYPE menge_d.

    METHODS empty_inputs    FOR TESTING.
    METHODS full_service    FOR TESTING.
    METHODS partial_service FOR TESTING.
    METHODS counts_stockouts FOR TESTING.
    METHODS rows_without_stock FOR TESTING.
    METHODS zero_demand     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_fill_sim IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_fill_sim( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_demand TO mt_in-demand.
    APPEND iv_stock TO mt_in-stock.
  ENDMETHOD.

  METHOD empty_inputs.
    DATA(ls_result) = mo_cut->simulate( mt_in ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-periods exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-fill_x100 exp = 0 ).
  ENDMETHOD.

  METHOD full_service.
    add( iv_demand = 10 iv_stock = 10 ).
    add( iv_demand = 20 iv_stock = 50 ).

    DATA(ls_result) = mo_cut->simulate( mt_in ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-served exp = 30 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-fill_x100 exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-stockouts exp = 0 ).
  ENDMETHOD.

  METHOD partial_service.
    add( iv_demand = 10 iv_stock = 10 ).
    add( iv_demand = 20 iv_stock = 10 ).
    add( iv_demand = 30 iv_stock = 100 ).

    DATA(ls_result) = mo_cut->simulate( mt_in ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-demand_sum exp = 60 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-served exp = 50 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-fill_x100 exp = 83 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-periods exp = 3 ).
  ENDMETHOD.

  METHOD counts_stockouts.
    add( iv_demand = 10 iv_stock = 10 ).
    add( iv_demand = 20 iv_stock = 10 ).
    add( iv_demand = 30 iv_stock = 100 ).

    DATA(ls_result) = mo_cut->simulate( mt_in ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-stockouts exp = 1 ).
  ENDMETHOD.

  METHOD rows_without_stock.
    add( iv_demand = 10 iv_stock = 10 ).
    APPEND 20 TO mt_in-demand.

    DATA(ls_result) = mo_cut->simulate( mt_in ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-periods exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-fill_x100 exp = 100 ).
  ENDMETHOD.

  METHOD zero_demand.
    add( iv_demand = 0 iv_stock = 10 ).

    DATA(ls_result) = mo_cut->simulate( mt_in ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-fill_x100 exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-served exp = 0 ).
  ENDMETHOD.

ENDCLASS.
