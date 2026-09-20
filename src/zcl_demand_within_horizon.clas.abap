CLASS zcl_demand_within_horizon DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    "! Zero means no horizon at all: every open requirement competes, however
    "! far out it is. Whether that is right is a business decision, so it is
    "! the default rather than a number this code invents.
    CONSTANTS c_no_horizon TYPE i VALUE 0.

    "! <p class="shorttext synchronized">Wrap a demand reader with a horizon</p>
    "!
    "! @parameter io_demand | <p class="shorttext synchronized">Reader of the open demand</p>
    "! @parameter iv_days   | <p class="shorttext synchronized">Days ahead to look, 0 for no limit</p>
    METHODS constructor
      IMPORTING
        io_demand TYPE REF TO zif_demand_reader
        iv_days   TYPE i DEFAULT c_no_horizon.

  PRIVATE SECTION.
    DATA mo_demand TYPE REF TO zif_demand_reader.
    DATA mv_days   TYPE i.

ENDCLASS.


CLASS zcl_demand_within_horizon IMPLEMENTATION.

  METHOD constructor.

    mo_demand = io_demand.
    mv_days   = iv_days.

  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.
    rt_matnr = mo_demand->materials_with_demand( iv_werks ).
  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.

    " typed explicitly, see ANOMALIES.md
    DATA lv_cutoff TYPE d.

    DATA(lt_demand) = mo_demand->read_open_demand(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    IF mv_days <= c_no_horizon.
      rt_demand = lt_demand.
      RETURN.
    ENDIF.

    lv_cutoff = sy-datum + mv_days.

    " a requirement without a date is wanted as soon as possible, so it is
    " inside any horizon
    LOOP AT lt_demand INTO DATA(ls_demand).
      IF ls_demand-req_date IS INITIAL
          OR ls_demand-req_date <= lv_cutoff.
        APPEND ls_demand TO rt_demand.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
