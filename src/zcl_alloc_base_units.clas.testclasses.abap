CLASS ltcl_alloc_base_units DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_base_units.
    DATA mt_value TYPE zcl_alloc_base_units=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS sums_units  FOR TESTING.
    METHODS unit_rate   FOR TESTING.
    METHODS sums_totals FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_base_units IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_base_units( ).

    add( iv_value = 100 ).
    add( iv_value = 200 ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_value.
  ENDMETHOD.

  METHOD sums_units.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->units( mt_value ) exp = 300 ).
  ENDMETHOD.

  METHOD unit_rate.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_unit( iv_total = 600 iv_units = 300 )
      exp = 2 ).
  ENDMETHOD.

  METHOD sums_totals.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_value ) exp = 300 ).
  ENDMETHOD.

ENDCLASS.
