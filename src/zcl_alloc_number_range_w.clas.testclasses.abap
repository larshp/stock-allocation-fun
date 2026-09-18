CLASS ltcl_alloc_number_range_w DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_number_range_w.

    METHODS setup.

    METHODS reserve_input
      IMPORTING
        iv_requested  TYPE i
        iv_available  TYPE i
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_number_range_w=>ty_reserve.

    METHODS state_input
      IMPORTING
        iv_used       TYPE i
        iv_capacity   TYPE i
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_number_range_w=>ty_state.

    METHODS grants_request  FOR TESTING.
    METHODS grants_remainder FOR TESTING.
    METHODS zero_request    FOR TESTING.
    METHODS not_exhausted   FOR TESTING.
    METHODS is_exhausted    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_number_range_w IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_number_range_w( ).
  ENDMETHOD.

  METHOD reserve_input.
    rs_row-range_name = 'ZALLOC'.
    rs_row-requested = iv_requested.
    rs_row-available = iv_available.
  ENDMETHOD.

  METHOD state_input.
    rs_row-range_name = 'ZALLOC'.
    rs_row-used = iv_used.
    rs_row-capacity = iv_capacity.
  ENDMETHOD.

  METHOD grants_request.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reserve( reserve_input( iv_requested = 5
                                            iv_available = 10 ) )
      exp = 5 ).
  ENDMETHOD.

  METHOD grants_remainder.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reserve( reserve_input( iv_requested = 15
                                            iv_available = 10 ) )
      exp = 10 ).
  ENDMETHOD.

  METHOD zero_request.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reserve( reserve_input( iv_requested = 0
                                            iv_available = 10 ) )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reserve( reserve_input( iv_requested = 5
                                            iv_available = 0 ) )
      exp = 0 ).
  ENDMETHOD.

  METHOD not_exhausted.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->exhausted( state_input( iv_used = 3 iv_capacity = 10 ) )
      exp = abap_false ).
  ENDMETHOD.

  METHOD is_exhausted.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->exhausted( state_input( iv_used = 10 iv_capacity = 10 ) )
      exp = abap_true ).
  ENDMETHOD.

ENDCLASS.
