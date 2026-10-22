CLASS zcl_sap_factory_calendar DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_factory_calendar_api.
ENDCLASS.

CLASS zcl_sap_factory_calendar IMPLEMENTATION.

  METHOD zif_factory_calendar_api~subtract_workdays.
    IF iv_date IS INITIAL
        OR iv_factory_calendar_id IS INITIAL
        OR iv_workdays < 0.
      RETURN.
    ENDIF.

    DATA lv_factory_date TYPE p LENGTH 3 DECIMALS 0.
    DATA lv_workingday_indicator TYPE c LENGTH 1.
    DATA lv_date TYPE d.

    CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
      EXPORTING
        date                         = iv_date
        factory_calendar_id          = iv_factory_calendar_id
        correct_option               = '-'
      IMPORTING
        factorydate                  = lv_factory_date
        workingday_indicator         = lv_workingday_indicator
      EXCEPTIONS
        calendar_buffer_not_loadable = 1
        correct_option_invalid       = 2
        date_after_range             = 3
        date_before_range            = 4
        date_invalid                 = 5
        factory_calendar_not_found   = 6
        OTHERS                       = 7.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    lv_factory_date = lv_factory_date - iv_workdays.
    CALL FUNCTION 'FACTORYDATE_CONVERT_TO_DATE'
      EXPORTING
        factorydate                  = lv_factory_date
        factory_calendar_id          = iv_factory_calendar_id
      IMPORTING
        date                         = lv_date
      EXCEPTIONS
        calendar_buffer_not_loadable = 1
        factorydate_after_range      = 2
        factorydate_before_range     = 3
        factorydate_invalid          = 4
        factory_calendar_id_missing  = 5
        factory_calendar_not_found   = 6
        OTHERS                       = 7.
    IF sy-subrc = 0.
      rs_result-date = lv_date.
      rs_result-is_successful = abap_true.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
