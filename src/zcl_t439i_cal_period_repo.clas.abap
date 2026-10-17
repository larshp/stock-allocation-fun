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

    SELECT werks AS plant,
           mrppp AS planning_calendar_id,
           ppvon AS start_date,
           ppbis AS end_date
      FROM t439i
      FOR ALL ENTRIES IN @it_requests
      WHERE werks = @it_requests-plant
        AND mrppp = @it_requests-planning_calendar_id
        AND ppbis >= @it_requests-from_date
        AND ppvon <= @it_requests-through_date
      INTO CORRESPONDING FIELDS OF TABLE @rt_periods.
  ENDMETHOD.

ENDCLASS.
