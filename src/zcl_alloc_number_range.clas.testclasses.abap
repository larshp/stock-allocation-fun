CLASS ltcl_alloc_number_range DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_number_range.

    METHODS setup.

    METHODS next_input
      IMPORTING
        iv_current    TYPE i
        iv_interval   TYPE i
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_number_range=>ty_next.

    METHODS range_input
      IMPORTING
        iv_number     TYPE i
        iv_from       TYPE i
        iv_to         TYPE i
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_number_range=>ty_range.

    METHODS remaining_input
      IMPORTING
        iv_current    TYPE i
        iv_to         TYPE i
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_number_range=>ty_remaining.

    METHODS advances       FOR TESTING.
    METHODS inside_range   FOR TESTING.
    METHODS outside_range  FOR TESTING.
    METHODS counts_free    FOR TESTING.
    METHODS never_negative FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_number_range IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_number_range( ).
  ENDMETHOD.

  METHOD next_input.
    rs_row-current = iv_current.
    rs_row-interval = iv_interval.
  ENDMETHOD.

  METHOD range_input.
    rs_row-number = iv_number.
    rs_row-from = iv_from.
    rs_row-to = iv_to.
  ENDMETHOD.

  METHOD remaining_input.
    rs_row-current = iv_current.
    rs_row-to = iv_to.
  ENDMETHOD.

  METHOD advances.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->next( next_input( iv_current = 10 iv_interval = 1 ) )
      exp = 11 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->next( next_input( iv_current = 10 iv_interval = 5 ) )
      exp = 15 ).
  ENDMETHOD.

  METHOD inside_range.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->in_range( range_input( iv_number = 5
                                           iv_from   = 1
                                           iv_to     = 10 ) )
      exp = abap_true ).
  ENDMETHOD.

  METHOD outside_range.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->in_range( range_input( iv_number = 11
                                           iv_from   = 1
                                           iv_to     = 10 ) )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->in_range( range_input( iv_number = 0
                                           iv_from   = 1
                                           iv_to     = 10 ) )
      exp = abap_false ).
  ENDMETHOD.

  METHOD counts_free.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->remaining( remaining_input( iv_current = 3
                                                iv_to      = 10 ) )
      exp = 7 ).
  ENDMETHOD.

  METHOD never_negative.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->remaining( remaining_input( iv_current = 12
                                                iv_to      = 10 ) )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
