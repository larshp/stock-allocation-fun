CLASS zcl_demand_reader_net DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    "! <p class="shorttext synchronized">Wrap a demand reader with what it has already been given</p>
    "!
    "! @parameter io_demand | <p class="shorttext synchronized">Reader of the open demand</p>
    METHODS constructor
      IMPORTING
        io_demand TYPE REF TO zif_demand_reader.

  PRIVATE SECTION.

    "! A run whose reservation number is still initial never earmarked
    "! anything, so it does not count as covered.
    CONSTANTS c_no_reservation TYPE zstock_alloc_res-reservation VALUE '0000000000'.

    TYPES:
      BEGIN OF ty_allocated,
        demand_id TYPE zstock_alloc_res-demand_id,
        confirmed TYPE zstock_alloc_res-confirmed,
      END OF ty_allocated.
    TYPES ty_allocated_tab TYPE STANDARD TABLE OF ty_allocated WITH EMPTY KEY.

    DATA mo_demand TYPE REF TO zif_demand_reader.

    METHODS already_allocated
      IMPORTING
        iv_matnr            TYPE mard-matnr
        iv_werks            TYPE mard-werks
      RETURNING
        VALUE(rt_allocated) TYPE ty_allocated_tab.

    METHODS covered
      IMPORTING
        it_allocated       TYPE ty_allocated_tab
        iv_demand_id       TYPE zif_allocation=>ty_demand_id
      RETURNING
        VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity.

ENDCLASS.


CLASS zcl_demand_reader_net IMPLEMENTATION.

  METHOD constructor.
    mo_demand = io_demand.
  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.
    rt_matnr = mo_demand->materials_with_demand( iv_werks ).
  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.

    " typed explicitly, see ANOMALIES.md
    DATA lv_open TYPE zif_allocation=>ty_quantity.

    DATA(lt_demand) = mo_demand->read_open_demand(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    DATA(lt_allocated) = already_allocated(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

    " a line that has already been served in full has nothing left to ask for
    " and drops out; one served in part asks for the remainder
    LOOP AT lt_demand INTO DATA(ls_demand).

      lv_open = ls_demand-quantity - covered(
        it_allocated = lt_allocated
        iv_demand_id = ls_demand-demand_id ).

      IF lv_open > 0.
        ls_demand-quantity = lv_open.
        APPEND ls_demand TO rt_demand.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD already_allocated.

    SELECT demand_id,
           confirmed
      FROM zstock_alloc_res
      WHERE matnr = @iv_matnr
        AND werks = @iv_werks
        AND reservation <> @c_no_reservation
      ORDER BY demand_id
      INTO TABLE @rt_allocated.
    IF sy-subrc <> 0.
      CLEAR rt_allocated.
    ENDIF.

  ENDMETHOD.

  METHOD covered.

    LOOP AT it_allocated INTO DATA(ls_allocated) WHERE demand_id = iv_demand_id.
      IF ls_allocated-confirmed > 0.
        rv_quantity = rv_quantity + ls_allocated-confirmed.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
