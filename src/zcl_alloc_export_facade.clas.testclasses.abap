CLASS ltcl_alloc_export_facade DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_export_facade.

    METHODS setup.

    METHODS request_with
      IMPORTING
        iv_kind       TYPE zcl_alloc_export_facade=>ty_kind
        iv_matnr      TYPE matnr
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_export_facade=>ty_request.

    METHODS csv_dispatch   FOR TESTING.
    METHODS json_dispatch  FOR TESTING.
    METHODS unknown_kind   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_export_facade IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_export_facade( ).
  ENDMETHOD.

  METHOD request_with.
    DATA ls_result TYPE zcl_stock_allocator=>ty_result.
    DATA ls_alloc  TYPE zcl_stock_allocator=>ty_allocation.

    rs_row-kind = iv_kind.
    ls_result-requirement_id = 'REQ-1'.
    ls_alloc-matnr = iv_matnr.
    ls_alloc-lgort = '0001'.
    ls_alloc-charg = 'B1'.
    ls_alloc-quantity = '5'.
    APPEND ls_alloc TO ls_result-allocations.
    APPEND ls_result TO rs_row-result.
  ENDMETHOD.

  METHOD csv_dispatch.
    DATA(lt_lines) = mo_cut->as_csv(
      request_with( iv_kind = 'ALLOC' iv_matnr = 'MAT-1' ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ]
      exp = 'REQUIREMENT_ID;MATNR;LGORT;CHARG;QUANTITY' ).
  ENDMETHOD.

  METHOD json_dispatch.
    DATA(lv_json) = mo_cut->as_json(
      request_with( iv_kind = 'MAT' iv_matnr = 'MAT-1' ) ).

    cl_abap_unit_assert=>assert_differs(
      act = find( val = lv_json sub = '"matnr":"MAT-1"' )
      exp = -1 ).
  ENDMETHOD.

  METHOD unknown_kind.
    DATA(lt_lines) = mo_cut->as_csv(
      request_with( iv_kind = 'NOPE' iv_matnr = 'MAT-1' ) ).

    cl_abap_unit_assert=>assert_initial( act = lt_lines ).

    DATA(lv_json) = mo_cut->as_json(
      request_with( iv_kind = 'NOPE' iv_matnr = 'MAT-1' ) ).

    cl_abap_unit_assert=>assert_equals( act = lv_json exp = '[]' ).
  ENDMETHOD.

ENDCLASS.
