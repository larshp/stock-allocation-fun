CLASS ltcl_alloc_dim_weight DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_dim_weight.

    METHODS setup.

    METHODS rounds_up      FOR TESTING.
    METHODS exact_division FOR TESTING.
    METHODS zero_divisor   FOR TESTING.
    METHODS charge_actual  FOR TESTING.
    METHODS charge_dim     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_dim_weight IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_dim_weight( ).
  ENDMETHOD.

  METHOD rounds_up.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->dim_weight( iv_volume = 5001 iv_divisor = 5000 )
      exp = 2 ).
  ENDMETHOD.

  METHOD exact_division.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->dim_weight( iv_volume = 5000 iv_divisor = 5000 )
      exp = 1 ).
  ENDMETHOD.

  METHOD zero_divisor.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->dim_weight( iv_volume = 5000 iv_divisor = 0 )
      exp = 0 ).
  ENDMETHOD.

  METHOD charge_actual.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->chargeable( iv_actual = 10 iv_dim = 3 ) exp = 10 ).
  ENDMETHOD.

  METHOD charge_dim.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->chargeable( iv_actual = 3 iv_dim = 10 ) exp = 10 ).
  ENDMETHOD.

ENDCLASS.
