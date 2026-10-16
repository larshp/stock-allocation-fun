CLASS ltcl_alloc_cycle_plan DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cycle_plan.
    DATA mt_bin TYPE zcl_alloc_cycle_plan=>ty_bin_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_id  TYPE string
        iv_day TYPE i.

    METHODS marks_due       FOR TESTING.
    METHODS not_yet_due     FOR TESTING.
    METHODS never_counted   FOR TESTING.
    METHODS due_count_read  FOR TESTING.
    METHODS zero_frequency  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cycle_plan IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cycle_plan( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_bin TYPE zcl_alloc_cycle_plan=>ty_bin.

    ls_bin-bin_id = iv_id.
    ls_bin-last_count_day = iv_day.
    APPEND ls_bin TO mt_bin.
  ENDMETHOD.

  METHOD marks_due.
    DATA lt_plan TYPE zcl_alloc_cycle_plan=>ty_plan_tt.

    add( iv_id = 'B1' iv_day = 80 ).

    lt_plan = mo_cut->plan( it_bins = mt_bin iv_today = 100
                            iv_frequency = 20 ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_plan[ 1 ]-days_since exp = 20 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_plan[ 1 ]-due exp = abap_true ).
  ENDMETHOD.

  METHOD not_yet_due.
    DATA lt_plan TYPE zcl_alloc_cycle_plan=>ty_plan_tt.

    add( iv_id = 'B1' iv_day = 90 ).

    lt_plan = mo_cut->plan( it_bins = mt_bin iv_today = 100
                            iv_frequency = 20 ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_plan[ 1 ]-due exp = abap_false ).
  ENDMETHOD.

  METHOD never_counted.
    DATA lt_plan TYPE zcl_alloc_cycle_plan=>ty_plan_tt.

    add( iv_id = 'NEW' iv_day = 0 ).

    lt_plan = mo_cut->plan( it_bins = mt_bin iv_today = 100
                            iv_frequency = 20 ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_plan[ 1 ]-days_since exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_plan[ 1 ]-due exp = abap_true ).
  ENDMETHOD.

  METHOD due_count_read.
    DATA lt_plan TYPE zcl_alloc_cycle_plan=>ty_plan_tt.

    add( iv_id = 'B1' iv_day = 50 ).
    add( iv_id = 'B2' iv_day = 99 ).

    lt_plan = mo_cut->plan( it_bins = mt_bin iv_today = 100
                            iv_frequency = 20 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->due_count( lt_plan ) exp = 1 ).
  ENDMETHOD.

  METHOD zero_frequency.
    DATA lt_plan TYPE zcl_alloc_cycle_plan=>ty_plan_tt.

    add( iv_id = 'B1' iv_day = 50 ).

    lt_plan = mo_cut->plan( it_bins = mt_bin iv_today = 100
                            iv_frequency = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_plan[ 1 ]-due exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
