CLASS ltcl_alloc_turn_rate DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_turn_rate.

    METHODS setup.

    METHODS input
      IMPORTING
        iv_consumption TYPE menge_d
        iv_stock       TYPE menge_d
      RETURNING
        VALUE(rs_row)  TYPE zcl_alloc_turn_rate=>ty_input.

    METHODS ten_turns      FOR TESTING.
    METHODS two_turns      FOR TESTING.
    METHODS floored_turns  FOR TESTING.
    METHODS zero_stock     FOR TESTING.
    METHODS zero_consumption FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_turn_rate IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_turn_rate( ).
  ENDMETHOD.

  METHOD input.
    rs_row-consumption = iv_consumption.
    rs_row-average_stock = iv_stock.
  ENDMETHOD.

  METHOD ten_turns.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( input( iv_consumption = '1000'
                                      iv_stock       = '100' ) )
      exp = 10 ).
  ENDMETHOD.

  METHOD two_turns.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( input( iv_consumption = '500'
                                      iv_stock       = '200' ) )
      exp = 2 ).
  ENDMETHOD.

  METHOD floored_turns.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( input( iv_consumption = '150'
                                      iv_stock       = '100' ) )
      exp = 1 ).
  ENDMETHOD.

  METHOD zero_stock.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( input( iv_consumption = '150'
                                      iv_stock       = '0' ) )
      exp = 0 ).
  ENDMETHOD.

  METHOD zero_consumption.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( input( iv_consumption = '0'
                                      iv_stock       = '100' ) )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
