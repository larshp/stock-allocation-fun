CLASS zcl_calendar_factory DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_work_calendar.

  PRIVATE SECTION.

    "! A date that is not a working day is read as the working day before it:
    "! goods that have to be ready on a Saturday have to be ready on the
    "! Friday, because nobody is there on the Saturday to pick them.
    CONSTANTS c_backwards TYPE calind VALUE '-'.

    "! Which calendar a plant keeps, read once per plant.
    TYPES:
      BEGIN OF ty_plant,
        werks TYPE mard-werks,
        fabkl TYPE t001w-fabkl,
      END OF ty_plant.
    TYPES ty_plant_tab TYPE STANDARD TABLE OF ty_plant WITH EMPTY KEY.

    DATA mt_plant TYPE ty_plant_tab.

    METHODS calendar_of
      IMPORTING
        iv_werks        TYPE mard-werks
      RETURNING
        VALUE(rv_fabkl) TYPE t001w-fabkl
      RAISING
        zcx_allocation.

ENDCLASS.


CLASS zcl_calendar_factory IMPLEMENTATION.

  METHOD zif_work_calendar~days_before.

    DATA lv_factorydate TYPE facdate.
    DATA lv_indicator   TYPE calind.
    DATA lv_date        TYPE d.
    DATA lv_wanted      TYPE i.

    rv_date = iv_date.

    IF iv_days <= 0 OR iv_date IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lv_fabkl) = calendar_of( iv_werks ).

    CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
      EXPORTING
        correct_option               = c_backwards
        date                         = iv_date
        factory_calendar_id          = lv_fabkl
      IMPORTING
        factorydate                  = lv_factorydate
        workingday_indicator         = lv_indicator
      EXCEPTIONS
        calendar_buffer_not_loadable = 1
        date_after_range             = 2
        date_before_range            = 3
        date_invalid                 = 4
        factory_calendar_not_found   = 5
        OTHERS                       = 6.
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>no_calendar
        mv_message = |{ lv_fabkl }| ).
    ENDIF.

    " counting back from a day the plant does not work on starts at the
    " working day before it, which the conversion has already done
    lv_wanted = lv_factorydate - iv_days.
    IF lv_wanted < 0.
      CLEAR lv_wanted.
    ENDIF.

    CALL FUNCTION 'FACTORYDATE_CONVERT_TO_DATE'
      EXPORTING
        factorydate                  = lv_wanted
        factory_calendar_id          = lv_fabkl
      IMPORTING
        date                         = lv_date
      EXCEPTIONS
        calendar_buffer_not_loadable = 1
        factorydate_after_range      = 2
        factorydate_before_range     = 3
        factory_calendar_not_found   = 4
        OTHERS                       = 5.
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>no_calendar
        mv_message = |{ lv_fabkl }| ).
    ENDIF.

    rv_date = lv_date.

  ENDMETHOD.

  METHOD calendar_of.

    DATA ls_plant TYPE ty_plant.

    READ TABLE mt_plant INTO DATA(ls_known)
      WITH KEY werks = iv_werks.
    IF sy-subrc = 0.
      rv_fabkl = ls_known-fabkl.
      RETURN.
    ENDIF.

    SELECT SINGLE fabkl
      FROM t001w
      WHERE werks = @iv_werks
      INTO @rv_fabkl.
    IF sy-subrc <> 0 OR rv_fabkl IS INITIAL.
      " a plant with no calendar cannot be counted back through one, and
      " guessing at a five day week for it would put dates on confirmations
      " that the plant never agreed to
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>no_calendar
        mv_message = |{ iv_werks }| ).
    ENDIF.

    ls_plant-werks = iv_werks.
    ls_plant-fabkl = rv_fabkl.
    APPEND ls_plant TO mt_plant.

  ENDMETHOD.

ENDCLASS.
