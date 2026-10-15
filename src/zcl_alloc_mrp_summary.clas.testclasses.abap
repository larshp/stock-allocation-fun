CLASS ltcl_alloc_mrp_summary DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_mrp_summary.
    DATA mt_req TYPE zcl_alloc_mrp_summary=>ty_req_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_shortage TYPE i
        iv_code     TYPE string.

    METHODS counts_exceptions FOR TESTING.
    METHODS sums_shortage     FOR TESTING.
    METHODS builds_summary    FOR TESTING.
    METHODS empty_input       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_mrp_summary IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_mrp_summary( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_req TYPE zcl_alloc_mrp_summary=>ty_req.

    ls_req-material = iv_material.
    ls_req-shortage = iv_shortage.
    ls_req-code = iv_code.
    APPEND ls_req TO mt_req.
  ENDMETHOD.

  METHOD counts_exceptions.
    add( iv_material = 'M1' iv_shortage = 10 iv_code = 'NEW' ).
    add( iv_material = 'M2' iv_shortage = 0 iv_code = 'NONE' ).
    add( iv_material = 'M3' iv_shortage = 5 iv_code = 'RESCHEDULE' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->exception_count( mt_req ) exp = 2 ).
  ENDMETHOD.

  METHOD sums_shortage.
    add( iv_material = 'M1' iv_shortage = 10 iv_code = 'NEW' ).
    add( iv_material = 'M2' iv_shortage = 0 iv_code = 'NONE' ).
    add( iv_material = 'M3' iv_shortage = 5 iv_code = 'RESCHEDULE' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_shortage( mt_req ) exp = 15 ).
  ENDMETHOD.

  METHOD builds_summary.
    DATA ls_summary TYPE zcl_alloc_mrp_summary=>ty_summary.

    add( iv_material = 'M1' iv_shortage = 10 iv_code = 'NEW' ).
    add( iv_material = 'M2' iv_shortage = 0 iv_code = 'NONE' ).
    add( iv_material = 'M3' iv_shortage = 5 iv_code = 'RESCHEDULE' ).

    ls_summary = mo_cut->build( mt_req ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-exception_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-total_shortage exp = 15 ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->exception_count( mt_req ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
