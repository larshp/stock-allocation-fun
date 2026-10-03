CLASS ltcl_t439i_cal_period_repo DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS skips_empty_request FOR TESTING.
ENDCLASS.

CLASS ltcl_t439i_cal_period_repo IMPLEMENTATION.
  METHOD skips_empty_request.
    DATA(lo_cut) = NEW zcl_t439i_cal_period_repo( ).
    DATA(lt_periods) = lo_cut->zif_planning_calendar_repo~get_periods_bulk(
      it_requests = VALUE #( ) ).

    cl_abap_unit_assert=>assert_initial(
      act = lt_periods ).
  ENDMETHOD.
ENDCLASS.
