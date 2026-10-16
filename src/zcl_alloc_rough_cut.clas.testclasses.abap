CLASS ltcl_alloc_rough_cut DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_rough_cut.
    DATA mt_dem TYPE zcl_alloc_rough_cut=>ty_demand_tt.
    DATA mt_cap TYPE zcl_alloc_rough_cut=>ty_capacity_tt.

    METHODS setup.

    METHODS add_demand
      IMPORTING
        iv_wc  TYPE string
        iv_req TYPE menge_d.

    METHODS add_capacity
      IMPORTING
        iv_wc    TYPE string
        iv_avail TYPE menge_d.

    METHODS empty_demand      FOR TESTING.
    METHODS marks_shortage    FOR TESTING.
    METHODS marks_covered     FOR TESTING.
    METHODS missing_capacity  FOR TESTING.
    METHODS feasibility_flag  FOR TESTING.
    METHODS totals_positive_gap FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_rough_cut IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_rough_cut( ).
  ENDMETHOD.

  METHOD add_demand.
    DATA ls_demand TYPE zcl_alloc_rough_cut=>ty_demand.

    ls_demand-work_centre = iv_wc.
    ls_demand-required = iv_req.
    APPEND ls_demand TO mt_dem.
  ENDMETHOD.

  METHOD add_capacity.
    DATA ls_cap TYPE zcl_alloc_rough_cut=>ty_capacity.

    ls_cap-work_centre = iv_wc.
    ls_cap-available = iv_avail.
    APPEND ls_cap TO mt_cap.
  ENDMETHOD.

  METHOD empty_demand.
    DATA(lt_lines) = mo_cut->check( it_demand   = mt_dem
                                    it_capacity = mt_cap ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_feasible( lt_lines ) exp = abap_true ).
  ENDMETHOD.

  METHOD marks_shortage.
    add_demand( iv_wc = 'WC1' iv_req = 10 ).
    add_capacity( iv_wc = 'WC1' iv_avail = 8 ).

    DATA(lt_lines) = mo_cut->check( it_demand   = mt_dem
                                    it_capacity = mt_cap ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-available exp = 8 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-gap exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-ok exp = abap_false ).
  ENDMETHOD.

  METHOD marks_covered.
    add_demand( iv_wc = 'WC1' iv_req = 5 ).
    add_capacity( iv_wc = 'WC1' iv_avail = 5 ).

    DATA(lt_lines) = mo_cut->check( it_demand   = mt_dem
                                    it_capacity = mt_cap ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-gap exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-ok exp = abap_true ).
  ENDMETHOD.

  METHOD missing_capacity.
    add_demand( iv_wc = 'WC9' iv_req = 4 ).

    DATA(lt_lines) = mo_cut->check( it_demand   = mt_dem
                                    it_capacity = mt_cap ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-available exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-gap exp = 4 ).
  ENDMETHOD.

  METHOD feasibility_flag.
    add_demand( iv_wc = 'WC1' iv_req = 10 ).
    add_demand( iv_wc = 'WC2' iv_req = 5 ).
    add_capacity( iv_wc = 'WC1' iv_avail = 8 ).
    add_capacity( iv_wc = 'WC2' iv_avail = 5 ).

    DATA(lt_lines) = mo_cut->check( it_demand   = mt_dem
                                    it_capacity = mt_cap ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_feasible( lt_lines ) exp = abap_false ).
  ENDMETHOD.

  METHOD totals_positive_gap.
    add_demand( iv_wc = 'WC1' iv_req = 10 ).
    add_demand( iv_wc = 'WC2' iv_req = 5 ).
    add_demand( iv_wc = 'WC9' iv_req = 4 ).
    add_capacity( iv_wc = 'WC1' iv_avail = 8 ).
    add_capacity( iv_wc = 'WC2' iv_avail = 5 ).

    DATA(lt_lines) = mo_cut->check( it_demand   = mt_dem
                                    it_capacity = mt_cap ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->gap_total( lt_lines ) exp = 6 ).
  ENDMETHOD.

ENDCLASS.
