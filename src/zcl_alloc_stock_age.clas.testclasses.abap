CLASS ltcl_alloc_stock_age DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_stock_age.

    METHODS setup.

    METHODS input
      IMPORTING
        iv_gr         TYPE d
        iv_reference  TYPE d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_stock_age=>ty_input.

    METHODS ten_days        FOR TESTING.
    METHODS same_day        FOR TESTING.
    METHODS future_receipt  FOR TESTING.
    METHODS empty_receipt   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_stock_age IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_stock_age( ).
  ENDMETHOD.

  METHOD input.
    rs_row-gr_date = iv_gr.
    rs_row-reference_date = iv_reference.
  ENDMETHOD.

  METHOD ten_days.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( input( iv_gr        = '20260101'
                                      iv_reference = '20260111' ) )
      exp = 10 ).
  ENDMETHOD.

  METHOD same_day.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( input( iv_gr        = '20260101'
                                      iv_reference = '20260101' ) )
      exp = 0 ).
  ENDMETHOD.

  METHOD future_receipt.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( input( iv_gr        = '20260110'
                                      iv_reference = '20260101' ) )
      exp = 0 ).
  ENDMETHOD.

  METHOD empty_receipt.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( input( iv_gr        = '00000000'
                                      iv_reference = '20260101' ) )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
