CLASS ltcl_alloc_daily_report DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_daily_report.

    METHODS setup.

    METHODS item
      IMPORTING
        iv_date       TYPE d
        iv_requested  TYPE menge_d
        iv_allocated  TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_daily_report=>ty_item.

    METHODS empty_list     FOR TESTING.
    METHODS groups_by_day  FOR TESTING.
    METHODS sums_quantities FOR TESTING.
    METHODS coverage_pct   FOR TESTING.
    METHODS sorted_by_date FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_daily_report IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_daily_report( ).
  ENDMETHOD.

  METHOD item.
    rs_row-run_date = iv_date.
    rs_row-requested_qty = iv_requested.
    rs_row-allocated_qty = iv_allocated.
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_items TYPE zcl_alloc_daily_report=>ty_item_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->summarize( lt_items ) ).
  ENDMETHOD.

  METHOD groups_by_day.
    DATA lt_items TYPE zcl_alloc_daily_report=>ty_item_tt.

    APPEND item( iv_date = '20260101' iv_requested = '10' iv_allocated = '10' )
      TO lt_items.
    APPEND item( iv_date = '20260102' iv_requested = '10' iv_allocated = '5' )
      TO lt_items.

    DATA(lt_lines) = mo_cut->summarize( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-run_date
                                        exp = '20260101' ).
  ENDMETHOD.

  METHOD sums_quantities.
    DATA lt_items TYPE zcl_alloc_daily_report=>ty_item_tt.

    APPEND item( iv_date = '20260101' iv_requested = '10' iv_allocated = '4' )
      TO lt_items.
    APPEND item( iv_date = '20260101' iv_requested = '10' iv_allocated = '6' )
      TO lt_items.

    DATA(lt_lines) = mo_cut->summarize( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-lines exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-requested_qty
                                        exp = '20' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-allocated_qty
                                        exp = '10' ).
  ENDMETHOD.

  METHOD coverage_pct.
    DATA lt_items TYPE zcl_alloc_daily_report=>ty_item_tt.

    APPEND item( iv_date = '20260101' iv_requested = '8' iv_allocated = '6' )
      TO lt_items.

    DATA(lt_lines) = mo_cut->summarize( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-coverage_pct
                                        exp = 75 ).
  ENDMETHOD.

  METHOD sorted_by_date.
    DATA lt_items TYPE zcl_alloc_daily_report=>ty_item_tt.

    APPEND item( iv_date = '20260102' iv_requested = '1' iv_allocated = '1' )
      TO lt_items.
    APPEND item( iv_date = '20260101' iv_requested = '1' iv_allocated = '1' )
      TO lt_items.

    DATA(lt_lines) = mo_cut->summarize( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-run_date
                                        exp = '20260101' ).
  ENDMETHOD.

ENDCLASS.
