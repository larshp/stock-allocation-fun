CLASS ltcl_alloc_restock_decision DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_restock_decision.

    METHODS setup.

    METHODS restocks_good    FOR TESTING.
    METHODS rejects_below    FOR TESTING.
    METHODS rejects_no_qty   FOR TESTING.
    METHODS threshold_test   FOR TESTING.
    METHODS reason_text      FOR TESTING.
    METHODS unknown_grade    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_restock_decision IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_restock_decision( ).
  ENDMETHOD.

  METHOD restocks_good.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->decide( iv_grade = 'B' iv_quantity = 5
                            iv_min_grade = 'C' )
      exp = 'RESTOCK' ).
  ENDMETHOD.

  METHOD rejects_below.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->decide( iv_grade = 'D' iv_quantity = 5
                            iv_min_grade = 'C' )
      exp = 'REJECT' ).
  ENDMETHOD.

  METHOD rejects_no_qty.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->decide( iv_grade = 'A' iv_quantity = 0
                            iv_min_grade = 'C' )
      exp = 'REJECT' ).
  ENDMETHOD.

  METHOD threshold_test.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_restock( iv_grade = 'C' iv_min_grade = 'C' )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_restock( iv_grade = 'D' iv_min_grade = 'C' )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_restock( iv_grade = 'B' iv_min_grade = 'C' )
      exp = abap_true ).
  ENDMETHOD.

  METHOD reason_text.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( iv_grade = 'A' iv_quantity = 5 )
      exp = 'SELLABLE' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( iv_grade = 'D' iv_quantity = 5 )
      exp = 'REPAIRABLE' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( iv_grade = 'F' iv_quantity = 5 )
      exp = 'SCRAP' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( iv_grade = 'A' iv_quantity = 0 )
      exp = 'NO_QUANTITY' ).
  ENDMETHOD.

  METHOD unknown_grade.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_restock( iv_grade = 'Z' iv_min_grade = 'C' )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( iv_grade = 'Z' iv_quantity = 5 )
      exp = '' ).
  ENDMETHOD.

ENDCLASS.
