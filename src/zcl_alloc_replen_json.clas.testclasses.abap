CLASS ltcl_alloc_replen_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_replen_json.

    METHODS setup.

    METHODS proposal
      IMPORTING
        iv_matnr      TYPE matnr
        iv_id         TYPE zcl_alloc_replenishment=>ty_proposal-requirement_id
        iv_shortage   TYPE menge_d
        iv_order      TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_replenishment=>ty_proposal.

    METHODS empty_result   FOR TESTING.
    METHODS proposal_row   FOR TESTING.
    METHODS summary_fields FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_replen_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_replen_json( ).
  ENDMETHOD.

  METHOD proposal.
    rs_row-matnr = iv_matnr.
    rs_row-requirement_id = iv_id.
    rs_row-shortage_qty = iv_shortage.
    rs_row-order_qty = iv_order.
  ENDMETHOD.

  METHOD empty_result.
    DATA ls_result TYPE zcl_alloc_replenishment=>ty_result.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( ls_result )
      exp = '{"proposals":[],"summary":{"proposals":0,"shortage_qty":0.000,"order_qty":0.000}}' ).
  ENDMETHOD.

  METHOD proposal_row.
    DATA ls_result TYPE zcl_alloc_replenishment=>ty_result.

    APPEND proposal( iv_matnr    = 'MAT-1'
                     iv_id       = 'REQ-1'
                     iv_shortage = '4'
                     iv_order    = '5' ) TO ls_result-proposals.

    DATA(lv_json) = mo_cut->build( ls_result ).

    cl_abap_unit_assert=>assert_differs(
      act = find( val = lv_json sub = '"matnr":"MAT-1"' )
      exp = -1 ).
    cl_abap_unit_assert=>assert_differs(
      act = find( val = lv_json sub = '"order_qty":5.000' )
      exp = -1 ).
  ENDMETHOD.

  METHOD summary_fields.
    DATA ls_result TYPE zcl_alloc_replenishment=>ty_result.

    ls_result-summary-proposals = 1.
    ls_result-summary-shortage_qty = '4'.
    ls_result-summary-order_qty = '5'.

    DATA(lv_json) = mo_cut->build( ls_result ).

    cl_abap_unit_assert=>assert_differs(
      act = find( val = lv_json sub = '{"proposals":1,"shortage_qty":4.000,"order_qty":5.000}' )
      exp = -1 ).
  ENDMETHOD.

ENDCLASS.
