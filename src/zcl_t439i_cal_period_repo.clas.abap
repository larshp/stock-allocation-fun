CLASS zcl_t439i_cal_period_repo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_planning_calendar_repo.
ENDCLASS.

CLASS zcl_t439i_cal_period_repo IMPLEMENTATION.

  METHOD zif_planning_calendar_repo~get_periods_bulk.
    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    SELECT t439i~werks AS plant,
           t439i~mrppp AS planning_calendar_id,
           t439i~ppvon AS start_date,
           t439i~ppbis AS end_date
      FROM t439i
      FOR ALL ENTRIES IN @it_requests
      WHERE t439i~werks = @it_requests-plant
        AND t439i~mrppp = @it_requests-planning_calendar_id
        AND t439i~ppbis >= @it_requests-from_date
        AND t439i~ppvon <= @it_requests-through_date
      INTO CORRESPONDING FIELDS OF TABLE @rt_periods.
  ENDMETHOD.

ENDCLASS.
