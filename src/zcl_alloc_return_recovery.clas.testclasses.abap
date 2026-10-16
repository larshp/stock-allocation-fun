CLASS ltcl_alloc_return_recovery DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_recovery.
    DATA mt_lin TYPE zcl_alloc_return_recovery=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value     TYPE i
        iv_recovered TYPE i.

    METHODS rate_value      FOR TESTING.
    METHODS rate_guard      FOR TESTING.
    METHODS recovers_lines  FOR TESTING.
    METHODS caps_recovered  FOR TESTING.
    METHODS good_threshold  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_recovery IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_recovery( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_return_recovery=>ty_line.

    ls_line-value = iv_value.
    ls_line-recovered = iv_recovered.
    APPEND ls_line TO mt_lin.
  ENDMETHOD.

  METHOD rate_value.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rate( iv_recovered = 120 iv_total = 200 )
      exp = 60 ).
  ENDMETHOD.

  METHOD rate_guard.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rate( iv_recovered = 120 iv_total = 0 )
      exp = 0 ).
  ENDMETHOD.

  METHOD recovers_lines.
    add( iv_value = 100 iv_recovered = 80 ).
    add( iv_value = 100 iv_recovered = 40 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->recovered_value( mt_lin ) exp = 120 ).
  ENDMETHOD.

  METHOD caps_recovered.
    add( iv_value = 100 iv_recovered = 150 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->recovered_value( mt_lin ) exp = 100 ).
  ENDMETHOD.

  METHOD good_threshold.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_good( iv_pct = 60 iv_target = 50 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_good( iv_pct = 60 iv_target = 70 )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_good( iv_pct = 60 iv_target = 0 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
