CLASS ltcl_alloc_defect_rate DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_defect_rate.

    METHODS setup.

    METHODS percent_read     FOR TESTING.
    METHODS percent_rounds   FOR TESTING.
    METHODS per_thousand_sub FOR TESTING.
    METHODS zero_inspected   FOR TESTING.
    METHODS zero_defects     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_defect_rate IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_defect_rate( ).
  ENDMETHOD.

  METHOD percent_read.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->percent( iv_defects = 5 iv_inspected = 100 )
      exp = 5 ).
  ENDMETHOD.

  METHOD percent_rounds.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->percent( iv_defects = 1 iv_inspected = 1000 )
      exp = 0 ).
  ENDMETHOD.

  METHOD per_thousand_sub.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_thousand( iv_defects = 1 iv_inspected = 1000 )
      exp = 1 ).
  ENDMETHOD.

  METHOD zero_inspected.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->percent( iv_defects = 5 iv_inspected = 0 )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_thousand( iv_defects = 5 iv_inspected = 0 )
      exp = 0 ).
  ENDMETHOD.

  METHOD zero_defects.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_thousand( iv_defects = 0 iv_inspected = 100 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
