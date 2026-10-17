INTERFACE zif_factory_calendar_api PUBLIC.

  TYPES:
    BEGIN OF ty_result,
      date          TYPE d,
      is_successful TYPE abap_bool,
    END OF ty_result.

  METHODS subtract_workdays
    IMPORTING
      iv_date                TYPE d
      iv_factory_calendar_id TYPE t001w-fabkl
      iv_workdays            TYPE i
    RETURNING
      VALUE(rs_result)       TYPE ty_result.

ENDINTERFACE.
