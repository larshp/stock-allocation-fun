INTERFACE zif_planning_calendar_repo PUBLIC.

  TYPES:
    BEGIN OF ty_request,
      plant                TYPE t439i-werks,
      planning_calendar_id TYPE t439i-mrppp,
      from_date            TYPE d,
      through_date         TYPE d,
    END OF ty_request.
  TYPES ty_requests TYPE STANDARD TABLE OF ty_request WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_period,
      plant                TYPE t439i-werks,
      planning_calendar_id TYPE t439i-mrppp,
      start_date           TYPE t439i-ppvon,
      end_date             TYPE t439i-ppbis,
    END OF ty_period.
  TYPES ty_periods TYPE STANDARD TABLE OF ty_period WITH EMPTY KEY.

  METHODS get_periods_bulk
    IMPORTING
      it_requests       TYPE ty_requests
    RETURNING
      VALUE(rt_periods) TYPE ty_periods.

ENDINTERFACE.
