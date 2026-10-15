CLASS ltcl_alloc_freight_rate DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_freight_rate.

    METHODS setup.

    METHODS per_unit_rounds  FOR TESTING.
    METHODS per_unit_exact   FOR TESTING.
    METHODS per_unit_zero    FOR TESTING.
    METHODS total_base_plus  FOR TESTING.
    METHODS surcharge_read   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_freight_rate IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_freight_rate( ).
  ENDMETHOD.

  METHOD per_unit_rounds.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_unit( iv_total_cents = 1000 iv_quantity = 3 )
      exp = 333 ).
  ENDMETHOD.

  METHOD per_unit_exact.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_unit( iv_total_cents = 1000 iv_quantity = 4 )
      exp = 250 ).
  ENDMETHOD.

  METHOD per_unit_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_unit( iv_total_cents = 1000 iv_quantity = 0 )
      exp = 0 ).
  ENDMETHOD.

  METHOD total_base_plus.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( iv_base_cents = 500 iv_per_unit_cents = 20
                           iv_quantity = 10 )
      exp = 700 ).
  ENDMETHOD.

  METHOD surcharge_read.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->surcharge( iv_cents = 1000 iv_percent = 5 )
      exp = 50 ).
  ENDMETHOD.

ENDCLASS.
