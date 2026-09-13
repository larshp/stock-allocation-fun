CLASS ltcl_alloc_sla_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_sla_json.

    METHODS setup.

    METHODS assess
      IMPORTING
        iv_lead          TYPE i
        iv_target        TYPE i
      RETURNING
        VALUE(rs_result) TYPE zcl_alloc_sla=>ty_result.

    METHODS empty_lines FOR TESTING.
    METHODS one_line    FOR TESTING.
    METHODS breached    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_sla_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_sla_json( ).
  ENDMETHOD.

  METHOD assess.
    DATA lt_items TYPE zcl_alloc_sla=>ty_item_tt.
    DATA ls_item  TYPE zcl_alloc_sla=>ty_item.

    ls_item-requirement_id = 'REQ-1'.
    ls_item-lead_days = iv_lead.
    ls_item-target_days = iv_target.
    APPEND ls_item TO lt_items.

    DATA(lo_sla) = NEW zcl_alloc_sla( ).
    rs_result = lo_sla->assess( lt_items ).
  ENDMETHOD.

  METHOD empty_lines.
    DATA ls_result TYPE zcl_alloc_sla=>ty_result.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( ls_result )
      exp = '{"total":0,"on_time":0,"breached":0,"compliance_pct":0,"lines":[]}' ).
  ENDMETHOD.

  METHOD one_line.
    DATA(ls_result) = assess( iv_lead = 2 iv_target = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( ls_result )
      exp = '{"total":1,"on_time":1,"breached":0,"compliance_pct":100,' &&
            '"lines":[{"requirement_id":"REQ-1","lead_days":2,' &&
            '"target_days":5,"on_time":true}]}' ).
  ENDMETHOD.

  METHOD breached.
    DATA(ls_result) = assess( iv_lead = 9 iv_target = 5 ).

    DATA(lv_json) = mo_cut->build( ls_result ).

    cl_abap_unit_assert=>assert_differs(
      act = find( val = lv_json sub = '"breached":1' )
      exp = -1 ).
  ENDMETHOD.

ENDCLASS.
