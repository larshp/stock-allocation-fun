CLASS ltcl_alloc_replen_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_replen_csv.

    METHODS setup.

    METHODS proposal
      IMPORTING
        iv_matnr      TYPE matnr
        iv_id         TYPE zcl_alloc_replenishment=>ty_proposal-requirement_id
        iv_shortage   TYPE menge_d
        iv_order      TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_replenishment=>ty_proposal.

    METHODS header_only FOR TESTING.
    METHODS row_values  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_replen_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_replen_csv( ).
  ENDMETHOD.

  METHOD proposal.
    rs_row-matnr = iv_matnr.
    rs_row-requirement_id = iv_id.
    rs_row-shortage_qty = iv_shortage.
    rs_row-order_qty = iv_order.
  ENDMETHOD.

  METHOD header_only.
    DATA ls_result TYPE zcl_alloc_replenishment=>ty_result.

    DATA(lt_lines) = mo_cut->build( ls_result ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ]
      exp = 'MATNR;REQUIREMENT_ID;SHORTAGE;ORDER_QTY' ).
  ENDMETHOD.

  METHOD row_values.
    DATA ls_result TYPE zcl_alloc_replenishment=>ty_result.

    APPEND proposal( iv_matnr    = 'MAT-1'
                     iv_id       = 'REQ-1'
                     iv_shortage = '4'
                     iv_order    = '5' ) TO ls_result-proposals.

    DATA(lt_lines) = mo_cut->build( ls_result ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines )
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 2 ]
      exp = 'MAT-1;REQ-1;4.000;5.000' ).
  ENDMETHOD.

ENDCLASS.
