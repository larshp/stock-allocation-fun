CLASS ltcl_demand_source_sap DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS reads_demands_and_priority FOR TESTING.
    METHODS applies_cutoff_in_database FOR TESTING.
ENDCLASS.

CLASS ltcl_demand_source_sap IMPLEMENTATION.
  METHOD reads_demands_and_priority.
    DATA(lt_demands) = NEW zcl_demand_source_sap(
      )->zif_demand_source~get_open_demands(
        iv_material = 'ZUT-SOURCE'
        iv_plant = 'UT01'
        iv_storage_location = 'UT01' ).
    SORT lt_demands BY sales_order sales_item schedule_line.

    cl_abap_unit_assert=>assert_equals( act = lines( lt_demands ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-sales_order
      exp = '0099999901' ).
    cl_abap_unit_assert=>assert_equals( act = lt_demands[ 1 ]-requested_qty exp = '7' ).
    cl_abap_unit_assert=>assert_equals( act = lt_demands[ 1 ]-priority exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 2 ]-sales_order
      exp = '0099999902' ).
    cl_abap_unit_assert=>assert_equals( act = lt_demands[ 2 ]-sales_item exp = '000020' ).
    cl_abap_unit_assert=>assert_equals( act = lt_demands[ 2 ]-delivery_date exp = '20260802' ).
    cl_abap_unit_assert=>assert_equals( act = lt_demands[ 2 ]-requested_qty exp = '4.500' ).
    cl_abap_unit_assert=>assert_equals( act = lt_demands[ 2 ]-priority exp = 9 ).
  ENDMETHOD.

  METHOD applies_cutoff_in_database.
    DATA(lt_demands) = NEW zcl_demand_source_sap(
      )->zif_demand_source~get_open_demands(
        iv_material = 'ZUT-SOURCE'
        iv_plant = 'UT01'
        iv_storage_location = 'UT01'
        iv_cutoff_date = '20260801' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_demands ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-sales_order
      exp = '0099999901' ).
  ENDMETHOD.
ENDCLASS.
