CLASS ltcl_alloc_base_machine DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_base_machine.
    DATA mt_hours TYPE zcl_alloc_base_machine=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_hours TYPE i.

    METHODS sums_hours FOR TESTING.
    METHODS hour_rate  FOR TESTING.
    METHODS sums_totals FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_base_machine IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_base_machine( ).

    add( iv_hours = 10 ).
    add( iv_hours = 30 ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_hours TO mt_hours.
  ENDMETHOD.

  METHOD sums_hours.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->hours( mt_hours ) exp = 40 ).
  ENDMETHOD.

  METHOD hour_rate.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_hour( iv_cost = 800 iv_hours = 40 )
      exp = 20 ).
  ENDMETHOD.

  METHOD sums_totals.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_hours ) exp = 40 ).
  ENDMETHOD.

ENDCLASS.
