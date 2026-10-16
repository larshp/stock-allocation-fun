CLASS ltcl_alloc_count_freq DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_count_freq.

    METHODS setup.

    METHODS class_a_base  FOR TESTING.
    METHODS class_b_double FOR TESTING.
    METHODS class_c_quad  FOR TESTING.
    METHODS unknown_class FOR TESTING.
    METHODS per_year      FOR TESTING.
    METHODS validity      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_count_freq IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_count_freq( ).
  ENDMETHOD.

  METHOD class_a_base.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->frequency( iv_abc_class = 'A' iv_base_days = 30 )
      exp = 30 ).
  ENDMETHOD.

  METHOD class_b_double.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->frequency( iv_abc_class = 'B' iv_base_days = 30 )
      exp = 60 ).
  ENDMETHOD.

  METHOD class_c_quad.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->frequency( iv_abc_class = 'C' iv_base_days = 30 )
      exp = 120 ).
  ENDMETHOD.

  METHOD unknown_class.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->frequency( iv_abc_class = 'D' iv_base_days = 30 )
      exp = 0 ).
  ENDMETHOD.

  METHOD per_year.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->counts_per_year( iv_interval_days = 30 ) exp = 12 ).
  ENDMETHOD.

  METHOD validity.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid_class( iv_abc_class = 'B' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid_class( iv_abc_class = 'D' ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
