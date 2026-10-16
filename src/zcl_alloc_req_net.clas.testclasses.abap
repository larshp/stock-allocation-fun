CLASS ltcl_alloc_req_net DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_req_net.

    METHODS setup.

    METHODS requirement
      IMPORTING
        iv_id         TYPE zif_requirement_reader=>ty_requirement-id
        iv_qty        TYPE menge_d
        iv_date       TYPE d
      RETURNING
        VALUE(rs_row) TYPE zif_requirement_reader=>ty_requirement.

    METHODS full_coverage   FOR TESTING.
    METHODS partial_cover   FOR TESTING.
    METHODS exact_cover     FOR TESTING.
    METHODS empty_list      FOR TESTING.
    METHODS zero_stock      FOR TESTING.
    METHODS oldest_first    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_req_net IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_req_net( ).
  ENDMETHOD.

  METHOD requirement.
    rs_row-id = iv_id.
    rs_row-requested_qty = iv_qty.
    rs_row-requested_date = iv_date.
  ENDMETHOD.

  METHOD full_coverage.
    DATA lt_reqs TYPE zif_requirement_reader=>ty_requirement_tt.

    APPEND requirement( iv_id = 'REQ-1' iv_qty = '10' iv_date = '20260101' ) TO lt_reqs.

    DATA(rs_result) = mo_cut->net( it_requirements = lt_reqs
                                   iv_stock        = '100' ).

    cl_abap_unit_assert=>assert_initial( act = rs_result-requirements ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-covered_qty exp = '10' ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-remaining_stock
                                        exp = '90' ).
  ENDMETHOD.

  METHOD partial_cover.
    DATA lt_reqs TYPE zif_requirement_reader=>ty_requirement_tt.

    APPEND requirement( iv_id = 'REQ-1' iv_qty = '10' iv_date = '20260101' ) TO lt_reqs.

    DATA(rs_result) = mo_cut->net( it_requirements = lt_reqs
                                   iv_stock        = '4' ).

    cl_abap_unit_assert=>assert_equals( act = lines( rs_result-requirements )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = rs_result-requirements[ 1 ]-requested_qty exp = '6' ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-covered_qty exp = '4' ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-remaining_stock
                                        exp = '0' ).
  ENDMETHOD.

  METHOD exact_cover.
    DATA lt_reqs TYPE zif_requirement_reader=>ty_requirement_tt.

    APPEND requirement( iv_id = 'REQ-1' iv_qty = '10' iv_date = '20260101' ) TO lt_reqs.

    DATA(rs_result) = mo_cut->net( it_requirements = lt_reqs
                                   iv_stock        = '10' ).

    cl_abap_unit_assert=>assert_initial( act = rs_result-requirements ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-remaining_stock
                                        exp = '0' ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_reqs TYPE zif_requirement_reader=>ty_requirement_tt.

    DATA(rs_result) = mo_cut->net( it_requirements = lt_reqs
                                   iv_stock        = '7' ).

    cl_abap_unit_assert=>assert_initial( act = rs_result-requirements ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-remaining_stock
                                        exp = '7' ).
  ENDMETHOD.

  METHOD zero_stock.
    DATA lt_reqs TYPE zif_requirement_reader=>ty_requirement_tt.

    APPEND requirement( iv_id = 'REQ-1' iv_qty = '10' iv_date = '20260101' ) TO lt_reqs.

    DATA(rs_result) = mo_cut->net( it_requirements = lt_reqs
                                   iv_stock        = '0' ).

    cl_abap_unit_assert=>assert_equals( act = lines( rs_result-requirements )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = rs_result-requirements[ 1 ]-requested_qty exp = '10' ).
  ENDMETHOD.

  METHOD oldest_first.
    DATA lt_reqs TYPE zif_requirement_reader=>ty_requirement_tt.

    APPEND requirement( iv_id = 'REQ-2' iv_qty = '10' iv_date = '20260201' ) TO lt_reqs.
    APPEND requirement( iv_id = 'REQ-1' iv_qty = '10' iv_date = '20260101' ) TO lt_reqs.

    DATA(rs_result) = mo_cut->net( it_requirements = lt_reqs
                                   iv_stock        = '4' ).

    cl_abap_unit_assert=>assert_equals( act = lines( rs_result-requirements )
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = rs_result-requirements[ 1 ]-id exp = 'REQ-1' ).
    cl_abap_unit_assert=>assert_equals(
      act = rs_result-requirements[ 1 ]-requested_qty exp = '6' ).
    cl_abap_unit_assert=>assert_equals(
      act = rs_result-requirements[ 2 ]-id exp = 'REQ-2' ).
  ENDMETHOD.

ENDCLASS.
