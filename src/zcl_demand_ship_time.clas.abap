CLASS zcl_demand_ship_time DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    "! <p class="shorttext synchronized">The stock has to be there before the day it is wanted</p>
    "!
    "! A customer wanting goods on the 10th does not want them to leave the
    "! plant on the 10th. Picking, packing and the lorry take time, and a
    "! receipt landing on the 9th is no use to a line that has to be on a
    "! trailer on the 8th. This puts that many days between the two dates, so
    "! the run stops confirming lines out of stock that arrives too late to
    "! ship.
    "!
    "! Zero days is a plant that ships the day it picks, and changes nothing.
    "!
    "! Which days count is the calendar's business: every day for a plant that
    "! has not said otherwise, and the working days of its factory calendar for
    "! one that has.
    "!
    "! @parameter io_demand   | <p class="shorttext synchronized">Reader of the demand as the documents have it</p>
    "! @parameter iv_days     | <p class="shorttext synchronized">Days between the goods being ready and gone</p>
    "! @parameter io_calendar | <p class="shorttext synchronized">Which days the plant works, every day if none</p>
    METHODS constructor
      IMPORTING
        io_demand   TYPE REF TO zif_demand_reader
        iv_days     TYPE i DEFAULT 0
        io_calendar TYPE REF TO zif_work_calendar OPTIONAL.

  PRIVATE SECTION.

    DATA mo_demand   TYPE REF TO zif_demand_reader.
    DATA mv_days     TYPE i.
    DATA mo_calendar TYPE REF TO zif_work_calendar.

ENDCLASS.


CLASS zcl_demand_ship_time IMPLEMENTATION.

  METHOD constructor.

    mo_demand = io_demand.

    " a negative shipping time would mean the goods leave before they are
    " picked, so it is read as none rather than obeyed
    mv_days = iv_days.
    IF mv_days < 0.
      CLEAR mv_days.
    ENDIF.

    " a caller that names no calendar gets the one the solution has always
    " used, which counts every day
    mo_calendar = io_calendar.
    IF mo_calendar IS NOT BOUND.
      mo_calendar = NEW zcl_calendar_plain( ).
    ENDIF.

  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.

    rt_demand = mo_demand->read_open_demand(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    IF mv_days <= 0.
      RETURN.
    ENDIF.

    LOOP AT rt_demand ASSIGNING FIELD-SYMBOL(<ls_demand>).

      " a line with no date at all is wanted now, and now is not a day that
      " can be brought forward
      IF <ls_demand>-req_date IS INITIAL.
        CONTINUE.
      ENDIF.

      <ls_demand>-ready_by = mo_calendar->days_before(
        iv_werks = iv_werks
        iv_date  = <ls_demand>-req_date
        iv_days  = mv_days ).

    ENDLOOP.

  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.

    " how long shipping takes does not change which materials are waiting
    rt_matnr = mo_demand->materials_with_demand( iv_werks ).

  ENDMETHOD.

ENDCLASS.
