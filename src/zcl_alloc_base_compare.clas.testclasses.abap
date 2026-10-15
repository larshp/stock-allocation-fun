CLASS ltcl_alloc_base_compare DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_base_compare.

    METHODS setup.

    METHODS chooses_closer FOR TESTING.
    METHODS reads_closer   FOR TESTING.
    METHODS computes_delta FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_base_compare IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_base_compare( ).
  ENDMETHOD.

  METHOD chooses_closer.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->compare( iv_base_a = 100 iv_base_b = 200 )
      exp = 'A' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->compare( iv_base_a = 200 iv_base_b = 100 )
      exp = 'B' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->compare( iv_base_a = 100 iv_base_b = 100 )
      exp = 'SAME' ).
  ENDMETHOD.

  METHOD reads_closer.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->closer( iv_base = 120 iv_target = 100 )
      exp = 20 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->closer( iv_base = 80 iv_target = 100 )
      exp = 20 ).
  ENDMETHOD.

  METHOD computes_delta.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->delta( iv_base_a = 200 iv_base_b = 100 )
      exp = 100 ).
  ENDMETHOD.

ENDCLASS.
