CLASS ltcl_alloc_sla DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_sla.

    METHODS setup.

    METHODS item
      IMPORTING
        iv_id         TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_lead       TYPE i
        iv_target     TYPE i
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_sla=>ty_item.

    METHODS empty_list   FOR TESTING.
    METHODS on_time_line FOR TESTING.
    METHODS breached_line FOR TESTING.
    METHODS summary_pct  FOR TESTING.
    METHODS exact_target FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_sla IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_sla( ).
  ENDMETHOD.

  METHOD item.
    rs_row-requirement_id = iv_id.
    rs_row-lead_days = iv_lead.
    rs_row-target_days = iv_target.
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_items TYPE zcl_alloc_sla=>ty_item_tt.

    DATA(rs_result) = mo_cut->assess( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-total exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-compliance_pct exp = 0 ).
  ENDMETHOD.

  METHOD on_time_line.
    DATA lt_items TYPE zcl_alloc_sla=>ty_item_tt.

    APPEND item( iv_id = 'REQ-1' iv_lead = 2 iv_target = 5 ) TO lt_items.

    DATA(rs_result) = mo_cut->assess( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-lines[ 1 ]-on_time
                                        exp = abap_true ).
  ENDMETHOD.

  METHOD breached_line.
    DATA lt_items TYPE zcl_alloc_sla=>ty_item_tt.

    APPEND item( iv_id = 'REQ-1' iv_lead = 9 iv_target = 5 ) TO lt_items.

    DATA(rs_result) = mo_cut->assess( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-lines[ 1 ]-on_time
                                        exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-breached exp = 1 ).
  ENDMETHOD.

  METHOD summary_pct.
    DATA lt_items TYPE zcl_alloc_sla=>ty_item_tt.

    APPEND item( iv_id = 'REQ-1' iv_lead = 2 iv_target = 5 ) TO lt_items.
    APPEND item( iv_id = 'REQ-2' iv_lead = 3 iv_target = 5 ) TO lt_items.
    APPEND item( iv_id = 'REQ-3' iv_lead = 9 iv_target = 5 ) TO lt_items.

    DATA(rs_result) = mo_cut->assess( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-total exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-on_time exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-compliance_pct exp = 66 ).
  ENDMETHOD.

  METHOD exact_target.
    DATA lt_items TYPE zcl_alloc_sla=>ty_item_tt.

    APPEND item( iv_id = 'REQ-1' iv_lead = 5 iv_target = 5 ) TO lt_items.

    DATA(rs_result) = mo_cut->assess( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-lines[ 1 ]-on_time
                                        exp = abap_true ).
  ENDMETHOD.

ENDCLASS.
