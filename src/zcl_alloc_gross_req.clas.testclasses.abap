CLASS ltcl_alloc_gross_req DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_gross_req.
    DATA mt_req TYPE zcl_alloc_gross_req=>ty_req_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_period   TYPE i
        iv_quantity TYPE i.

    METHODS sums_total   FOR TESTING.
    METHODS sums_period  FOR TESTING.
    METHODS counts_lines FOR TESTING.
    METHODS empty_input  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_gross_req IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_gross_req( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_req TYPE zcl_alloc_gross_req=>ty_req.

    ls_req-material = iv_material.
    ls_req-period = iv_period.
    ls_req-quantity = iv_quantity.
    APPEND ls_req TO mt_req.
  ENDMETHOD.

  METHOD sums_total.
    add( iv_material = 'M1' iv_period = 1 iv_quantity = 10 ).
    add( iv_material = 'M1' iv_period = 2 iv_quantity = 20 ).
    add( iv_material = 'M2' iv_period = 1 iv_quantity = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_req ) exp = 35 ).
  ENDMETHOD.

  METHOD sums_period.
    add( iv_material = 'M1' iv_period = 1 iv_quantity = 10 ).
    add( iv_material = 'M2' iv_period = 1 iv_quantity = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->period( it_reqs = mt_req iv_period = 1 ) exp = 15 ).
  ENDMETHOD.

  METHOD counts_lines.
    add( iv_material = 'M1' iv_period = 1 iv_quantity = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->line_count( mt_req ) exp = 1 ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_req ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->line_count( mt_req ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
