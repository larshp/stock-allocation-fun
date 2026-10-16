CLASS ltcl_alloc_absorb_compare DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_absorb_compare.

    METHODS setup.

    METHODS chooses_amount FOR TESTING.
    METHODS reads_closer   FOR TESTING.
    METHODS computes_delta FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_absorb_compare IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_absorb_compare( ).
  ENDMETHOD.

  METHOD chooses_amount.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->compare( iv_amount_a = 600 iv_amount_b = 900 )
      exp = 'A' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->compare( iv_amount_a = 900 iv_amount_b = 600 )
      exp = 'B' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->compare( iv_amount_a = 600 iv_amount_b = 600 )
      exp = 'SAME' ).
  ENDMETHOD.

  METHOD reads_closer.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->closer( iv_amount = 700 iv_target = 900 )
      exp = 200 ).
  ENDMETHOD.

  METHOD computes_delta.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->delta( iv_amount_a = 900 iv_amount_b = 600 )
      exp = 300 ).
  ENDMETHOD.

ENDCLASS.
