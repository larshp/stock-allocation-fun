CLASS ltcl_alloc_lead_buffer DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_lead_buffer.

    METHODS setup.

    METHODS plans_lead  FOR TESTING.
    METHODS buffers     FOR TESTING.
    METHODS safe_rule   FOR TESTING.
    METHODS guards_input FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_lead_buffer IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_lead_buffer( ).
  ENDMETHOD.

  METHOD plans_lead.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->planned_lead( iv_supplier_lead = 10 iv_buffer_percent = 20 )
      exp = 12 ).
  ENDMETHOD.

  METHOD buffers.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->buffer( iv_supplier_lead = 10 iv_buffer_percent = 20 )
      exp = 2 ).
  ENDMETHOD.

  METHOD safe_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_safe( iv_planned_lead = 12 iv_actual_lead = 11 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_safe( iv_planned_lead = 12 iv_actual_lead = 15 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD guards_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->planned_lead( iv_supplier_lead = 0 iv_buffer_percent = 20 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
