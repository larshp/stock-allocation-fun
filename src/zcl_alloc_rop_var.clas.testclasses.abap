CLASS ltcl_alloc_rop_var DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_rop_var.

    METHODS setup.

    METHODS make_input
      IMPORTING
        iv_avg          TYPE menge_d
        iv_lead         TYPE i
        iv_sig          TYPE menge_d
        iv_z            TYPE i
      RETURNING
        VALUE(rs_input) TYPE zcl_alloc_rop_var=>ty_input.

    METHODS cycle_plus_safety FOR TESTING.
    METHODS no_variation     FOR TESTING.
    METHODS zero_lead_time   FOR TESTING.
    METHODS zero_demand      FOR TESTING.
    METHODS parts_reported   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_rop_var IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_rop_var( ).
  ENDMETHOD.

  METHOD make_input.
    rs_input-avg_demand = iv_avg.
    rs_input-lead_time = iv_lead.
    rs_input-sigma = iv_sig.
    rs_input-z_x100 = iv_z.
  ENDMETHOD.

  METHOD cycle_plus_safety.
    DATA(ls_input) = make_input( iv_avg = 10 iv_lead = 4
                                 iv_sig = 2 iv_z = 165 ).
    DATA(ls_result) = mo_cut->calculate( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-cycle_stock exp = 40 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-safety exp = 6 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-rop exp = 46 ).
  ENDMETHOD.

  METHOD no_variation.
    DATA(ls_input) = make_input( iv_avg = 20 iv_lead = 5
                                 iv_sig = 0 iv_z = 165 ).
    DATA(ls_result) = mo_cut->calculate( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-safety exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-rop exp = 100 ).
  ENDMETHOD.

  METHOD zero_lead_time.
    DATA(ls_input) = make_input( iv_avg = 20 iv_lead = 0
                                 iv_sig = 5 iv_z = 165 ).
    DATA(ls_result) = mo_cut->calculate( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-cycle_stock exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-rop exp = 0 ).
  ENDMETHOD.

  METHOD zero_demand.
    DATA(ls_input) = make_input( iv_avg = 0 iv_lead = 10
                                 iv_sig = 5 iv_z = 165 ).
    DATA(ls_result) = mo_cut->calculate( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-cycle_stock exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-safety exp = 24 ).
  ENDMETHOD.

  METHOD parts_reported.
    DATA(ls_input) = make_input( iv_avg = 4 iv_lead = 3
                                 iv_sig = 4 iv_z = 100 ).
    DATA(ls_result) = mo_cut->calculate( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-cycle_stock exp = 12 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-rop exp = ls_result-cycle_stock + ls_result-safety ).
  ENDMETHOD.

ENDCLASS.
