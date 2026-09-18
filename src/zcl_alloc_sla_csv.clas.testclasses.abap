CLASS ltcl_alloc_sla_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_sla_csv.

    METHODS setup.

    METHODS assess
      IMPORTING
        iv_lead          TYPE i
        iv_target        TYPE i
      RETURNING
        VALUE(rs_result) TYPE zcl_alloc_sla=>ty_result.

    METHODS header_and_summary FOR TESTING.
    METHODS on_time_flag        FOR TESTING.
    METHODS breached_flag       FOR TESTING.
    METHODS summary_values      FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_sla_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_sla_csv( ).
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

  METHOD header_and_summary.
    DATA ls_result TYPE zcl_alloc_sla=>ty_result.

    DATA(lt_lines) = mo_cut->build( ls_result ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]
                                        exp = 'REQUIREMENT_ID;LEAD_DAYS;TARGET_DAYS;ON_TIME' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = 'SUMMARY;0;0;0' ).
  ENDMETHOD.

  METHOD on_time_flag.
    DATA(ls_result) = assess( iv_lead = 2 iv_target = 5 ).

    DATA(lt_lines) = mo_cut->build( ls_result ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = 'REQ-1;2;5;Y' ).
  ENDMETHOD.

  METHOD breached_flag.
    DATA(ls_result) = assess( iv_lead = 9 iv_target = 5 ).

    DATA(lt_lines) = mo_cut->build( ls_result ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = 'REQ-1;9;5;N' ).
  ENDMETHOD.

  METHOD summary_values.
    DATA(ls_result) = assess( iv_lead = 2 iv_target = 5 ).

    DATA(lt_lines) = mo_cut->build( ls_result ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ]
                                        exp = 'SUMMARY;1;1;100' ).
  ENDMETHOD.

ENDCLASS.
