CLASS zcl_alloc_milk_run DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_ids_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_stop,
             stop_id TYPE string,
             demand  TYPE menge_d,
           END OF ty_stop.
    TYPES ty_stop_tt TYPE STANDARD TABLE OF ty_stop WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_tour,
             tour_index TYPE i,
             load       TYPE menge_d,
             stop_ids   TYPE ty_ids_tt,
           END OF ty_tour.
    TYPES ty_tour_tt TYPE STANDARD TABLE OF ty_tour WITH DEFAULT KEY.

    METHODS group
      IMPORTING
        it_stops        TYPE ty_stop_tt
        iv_capacity     TYPE menge_d
      RETURNING
        VALUE(rt_tours) TYPE ty_tour_tt.

    METHODS unassigned
      IMPORTING
        it_stops        TYPE ty_stop_tt
        iv_capacity     TYPE menge_d
      RETURNING
        VALUE(rt_stops) TYPE ty_stop_tt.

ENDCLASS.


CLASS zcl_alloc_milk_run IMPLEMENTATION.

  METHOD group.
    DATA lt_sorted TYPE ty_stop_tt.
    DATA lt_tours  TYPE ty_tour_tt.
    DATA ls_tour   TYPE ty_tour.
    DATA lv_next   TYPE i.
    DATA lv_found  TYPE abap_bool.

    IF iv_capacity <= 0.
      RETURN.
    ENDIF.

    lt_sorted = it_stops.
    SORT lt_sorted BY demand DESCENDING.

    LOOP AT lt_sorted INTO DATA(ls_stop).
      IF ls_stop-demand <= 0 OR ls_stop-demand > iv_capacity.
        CONTINUE.
      ENDIF.

      lv_found = abap_false.

      LOOP AT lt_tours ASSIGNING FIELD-SYMBOL(<ls_tour>).
        IF <ls_tour>-load + ls_stop-demand <= iv_capacity.
          <ls_tour>-load = <ls_tour>-load + ls_stop-demand.
          APPEND ls_stop-stop_id TO <ls_tour>-stop_ids.
          lv_found = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_found = abap_true.
        CONTINUE.
      ENDIF.

      lv_next = lines( lt_tours ) + 1.
      CLEAR ls_tour.
      ls_tour-tour_index = lv_next.
      ls_tour-load = ls_stop-demand.
      APPEND ls_stop-stop_id TO ls_tour-stop_ids.
      APPEND ls_tour TO lt_tours.
    ENDLOOP.

    rt_tours = lt_tours.
  ENDMETHOD.

  METHOD unassigned.
    LOOP AT it_stops INTO DATA(ls_stop).
      IF ls_stop-demand > iv_capacity.
        APPEND ls_stop TO rt_stops.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
