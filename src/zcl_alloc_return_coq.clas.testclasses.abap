CLASS ltcl_alloc_return_coq DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_coq.
    DATA mt_cst TYPE zcl_alloc_return_coq=>ty_cost_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_category TYPE string
        iv_amount   TYPE i.

    METHODS totals_all      FOR TESTING.
    METHODS computes_scrap  FOR TESTING.
    METHODS computes_rework FOR TESTING.
    METHODS guards_empty    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_coq IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_coq( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_cost TYPE zcl_alloc_return_coq=>ty_cost.

    ls_cost-category = iv_category.
    ls_cost-amount = iv_amount.
    APPEND ls_cost TO mt_cst.
  ENDMETHOD.

  METHOD totals_all.
    add( iv_category = 'SCRAP' iv_amount = 300 ).
    add( iv_category = 'REWORK' iv_amount = 100 ).
    add( iv_category = 'FREIGHT' iv_amount = 100 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_cst ) exp = 500 ).
  ENDMETHOD.

  METHOD computes_scrap.
    add( iv_category = 'SCRAP' iv_amount = 300 ).
    add( iv_category = 'REWORK' iv_amount = 100 ).
    add( iv_category = 'FREIGHT' iv_amount = 100 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->scrap_share( mt_cst ) exp = 60 ).
  ENDMETHOD.

  METHOD computes_rework.
    add( iv_category = 'SCRAP' iv_amount = 300 ).
    add( iv_category = 'REWORK' iv_amount = 100 ).
    add( iv_category = 'FREIGHT' iv_amount = 100 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rework_share( mt_cst ) exp = 20 ).
  ENDMETHOD.

  METHOD guards_empty.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->scrap_share( mt_cst ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rework_share( mt_cst ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
