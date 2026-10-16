CLASS ltcl_alloc_plant_report DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_plant_report.

    METHODS setup.

    METHODS item
      IMPORTING
        iv_werks      TYPE werks_d
        iv_requested  TYPE menge_d
        iv_allocated  TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_plant_report=>ty_item.

    METHODS empty_list      FOR TESTING.
    METHODS groups_by_plant FOR TESTING.
    METHODS sums_quantities FOR TESTING.
    METHODS coverage_pct    FOR TESTING.
    METHODS sorted_by_plant FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_plant_report IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_plant_report( ).
  ENDMETHOD.

  METHOD item.
    rs_row-werks = iv_werks.
    rs_row-requested_qty = iv_requested.
    rs_row-allocated_qty = iv_allocated.
    rs_row-shortage_qty = iv_requested - iv_allocated.
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_items TYPE zcl_alloc_plant_report=>ty_item_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->summarize( lt_items ) ).
  ENDMETHOD.

  METHOD groups_by_plant.
    DATA lt_items TYPE zcl_alloc_plant_report=>ty_item_tt.

    APPEND item( iv_werks = '1000' iv_requested = '10' iv_allocated = '10' )
      TO lt_items.
    APPEND item( iv_werks = '2000' iv_requested = '10' iv_allocated = '5' )
      TO lt_items.

    DATA(lt_lines) = mo_cut->summarize( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-werks exp = '1000' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-werks exp = '2000' ).
  ENDMETHOD.

  METHOD sums_quantities.
    DATA lt_items TYPE zcl_alloc_plant_report=>ty_item_tt.

    APPEND item( iv_werks = '1000' iv_requested = '10' iv_allocated = '10' )
      TO lt_items.
    APPEND item( iv_werks = '1000' iv_requested = '10' iv_allocated = '5' )
      TO lt_items.

    DATA(lt_lines) = mo_cut->summarize( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-lines exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-requested_qty
                                        exp = '20' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-allocated_qty
                                        exp = '15' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-shortage_qty
                                        exp = '5' ).
  ENDMETHOD.

  METHOD coverage_pct.
    DATA lt_items TYPE zcl_alloc_plant_report=>ty_item_tt.

    APPEND item( iv_werks = '1000' iv_requested = '20' iv_allocated = '15' )
      TO lt_items.

    DATA(lt_lines) = mo_cut->summarize( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-coverage_pct
                                        exp = 75 ).
  ENDMETHOD.

  METHOD sorted_by_plant.
    DATA lt_items TYPE zcl_alloc_plant_report=>ty_item_tt.

    APPEND item( iv_werks = '2000' iv_requested = '10' iv_allocated = '10' )
      TO lt_items.
    APPEND item( iv_werks = '1000' iv_requested = '10' iv_allocated = '10' )
      TO lt_items.

    DATA(lt_lines) = mo_cut->summarize( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-werks exp = '1000' ).
  ENDMETHOD.

ENDCLASS.
