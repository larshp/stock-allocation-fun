CLASS ltcl_alloc_req_date DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_req_date.

    METHODS setup.

    METHODS plans_date   FOR TESTING.
    METHODS offsets_date FOR TESTING.
    METHODS late_rule    FOR TESTING.
    METHODS guards_input FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_req_date IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_req_date( ).
  ENDMETHOD.

  METHOD plans_date.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->date_of( iv_requirement_date = '20260110' iv_lead_days = 5 )
      exp = '20260105' ).
  ENDMETHOD.

  METHOD offsets_date.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->offset_date( iv_date = '20260110' iv_days = 3 )
      exp = '20260113' ).
  ENDMETHOD.

  METHOD late_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_late( iv_order_date       = '20260112'
                             iv_requirement_date = '20260110' )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_late( iv_order_date       = '20260108'
                             iv_requirement_date = '20260110' )
      exp = abap_false ).
  ENDMETHOD.

  METHOD guards_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->date_of( iv_requirement_date = '20260110' iv_lead_days = 0 )
      exp = '20260110' ).
  ENDMETHOD.

ENDCLASS.
