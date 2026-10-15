CLASS ltcl_alloc_return_charge DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_charge.
    DATA mt_lin TYPE zcl_alloc_return_charge=>ty_line_tt.

    METHODS setup.

    METHODS computes_charge FOR TESTING.
    METHODS guards_charge   FOR TESTING.
    METHODS waives_fault    FOR TESTING.
    METHODS waives_value    FOR TESTING.
    METHODS totals          FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_charge IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_charge( ).
  ENDMETHOD.

  METHOD computes_charge.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->charge( iv_base = 5 iv_per_unit = 2 iv_quantity = 3 )
      exp = 11 ).
  ENDMETHOD.

  METHOD guards_charge.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->charge( iv_base = 5 iv_per_unit = 2 iv_quantity = 0 )
      exp = 0 ).
  ENDMETHOD.

  METHOD waives_fault.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_waived( iv_reason_class = 'QUALITY' iv_value = 10 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_waived( iv_reason_class = 'COMMERCIAL' iv_value = 10 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD waives_value.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_waived( iv_reason_class = 'COMMERCIAL' iv_value = 1000 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD totals.
    DATA ls_line TYPE zcl_alloc_return_charge=>ty_line.

    ls_line-charge = 11.
    APPEND ls_line TO mt_lin.
    ls_line-charge = 20.
    APPEND ls_line TO mt_lin.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_lin ) exp = 31 ).
  ENDMETHOD.

ENDCLASS.
