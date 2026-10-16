CLASS ltcl_alloc_stress DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_stress.

    METHODS setup.

    METHODS ladder_full_range FOR TESTING.
    METHODS ladder_offset     FOR TESTING.
    METHODS ladder_zero_step  FOR TESTING.
    METHODS ladder_reversed   FOR TESTING.
    METHODS assess_thresholds FOR TESTING.
    METHODS assess_no_breach  FOR TESTING.
    METHODS assess_empty      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_stress IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_stress( ).
  ENDMETHOD.

  METHOD ladder_full_range.
    DATA(lt_levels) = mo_cut->ladder( iv_from = 0 iv_to = 100 iv_step = 25 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_levels ) exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = lt_levels[ 1 ] exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lt_levels[ 5 ] exp = 100 ).
  ENDMETHOD.

  METHOD ladder_offset.
    DATA(lt_levels) = mo_cut->ladder( iv_from = 10 iv_to = 30 iv_step = 10 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_levels ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_levels[ 2 ] exp = 20 ).
  ENDMETHOD.

  METHOD ladder_zero_step.
    DATA(lt_levels) = mo_cut->ladder( iv_from = 0 iv_to = 100 iv_step = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_levels ) exp = 0 ).
  ENDMETHOD.

  METHOD ladder_reversed.
    DATA(lt_levels) = mo_cut->ladder( iv_from = 100 iv_to = 0 iv_step = 10 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_levels ) exp = 0 ).
  ENDMETHOD.

  METHOD assess_thresholds.
    DATA(lt_levels) = mo_cut->ladder( iv_from = 50 iv_to = 100 iv_step = 50 ).
    DATA(lt_steps) = mo_cut->assess( it_levels = lt_levels
                                     iv_base   = 200
                                     iv_total  = 150 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_steps ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_steps[ 1 ]-threshold exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = lt_steps[ 1 ]-breached exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lt_steps[ 2 ]-threshold exp = 200 ).
    cl_abap_unit_assert=>assert_equals( act = lt_steps[ 2 ]-breached exp = abap_false ).
  ENDMETHOD.

  METHOD assess_no_breach.
    DATA(lt_levels) = mo_cut->ladder( iv_from = 100 iv_to = 100 iv_step = 10 ).
    DATA(lt_steps) = mo_cut->assess( it_levels = lt_levels
                                     iv_base   = 500
                                     iv_total  = 100 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_steps ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_steps[ 1 ]-breached exp = abap_false ).
  ENDMETHOD.

  METHOD assess_empty.
    DATA lt_levels TYPE zcl_alloc_stress=>ty_levels_tt.

    DATA(lt_steps) = mo_cut->assess( it_levels = lt_levels
                                     iv_base   = 100
                                     iv_total  = 50 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_steps ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
