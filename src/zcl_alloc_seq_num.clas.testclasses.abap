CLASS ltcl_alloc_seq_num DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_seq_num.

    METHODS setup.

    METHODS starts_at_start FOR TESTING.
    METHODS advances        FOR TESTING.
    METHODS current_peeks   FOR TESTING.
    METHODS reset_restarts  FOR TESTING.
    METHODS strict_sequence FOR TESTING.
    METHODS negative_start  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_seq_num IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_seq_num( iv_start = 100 ).
  ENDMETHOD.

  METHOD starts_at_start.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->current( ) exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->next( ) exp = 100 ).
  ENDMETHOD.

  METHOD advances.
    mo_cut->next( ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->next( ) exp = 101 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->next( ) exp = 102 ).
  ENDMETHOD.

  METHOD current_peeks.
    mo_cut->next( ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->current( ) exp = 101 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->current( ) exp = 101 ).
  ENDMETHOD.

  METHOD reset_restarts.
    mo_cut->next( ).
    mo_cut->next( ).
    mo_cut->reset( ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->next( ) exp = 100 ).
  ENDMETHOD.

  METHOD strict_sequence.
    DATA lv_value TYPE i.
    DATA lt_seen  TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    DO 3 TIMES.
      lv_value = mo_cut->next( ).
      APPEND lv_value TO lt_seen.
    ENDDO.

    cl_abap_unit_assert=>assert_equals( act = lt_seen[ 1 ] exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = lt_seen[ 2 ] exp = 101 ).
    cl_abap_unit_assert=>assert_equals( act = lt_seen[ 3 ] exp = 102 ).
  ENDMETHOD.

  METHOD negative_start.
    DATA lo_negative TYPE REF TO zcl_alloc_seq_num.

    lo_negative = NEW zcl_alloc_seq_num( iv_start = -2 ).

    cl_abap_unit_assert=>assert_equals( act = lo_negative->next( ) exp = -2 ).
    cl_abap_unit_assert=>assert_equals( act = lo_negative->next( ) exp = -1 ).
  ENDMETHOD.

ENDCLASS.
