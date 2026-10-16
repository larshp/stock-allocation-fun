CLASS zcl_alloc_return_route DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_stop,
             customer TYPE string,
             quantity TYPE i,
             distance TYPE i,
           END OF ty_stop.
    TYPES ty_stop_tt TYPE STANDARD TABLE OF ty_stop WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_leg,
             customer   TYPE string,
             quantity   TYPE i,
             distance   TYPE i,
             cumulative TYPE i,
           END OF ty_leg.
    TYPES ty_leg_tt TYPE STANDARD TABLE OF ty_leg WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_stops        TYPE ty_stop_tt
      RETURNING
        VALUE(rt_route) TYPE ty_leg_tt.

    METHODS stop_count
      IMPORTING
        it_stops        TYPE ty_stop_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS total_quantity
      IMPORTING
        it_stops      TYPE ty_stop_tt
      RETURNING
        VALUE(rv_qty) TYPE i.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_work,
             customer TYPE string,
             quantity TYPE i,
             distance TYPE i,
             seq      TYPE i,
           END OF ty_work.
    TYPES ty_work_tt TYPE STANDARD TABLE OF ty_work WITH DEFAULT KEY.

ENDCLASS.


CLASS zcl_alloc_return_route IMPLEMENTATION.

  METHOD build.
    DATA lt_work TYPE ty_work_tt.
    DATA ls_work TYPE ty_work.
    DATA lv_seq  TYPE i.
    DATA lv_cum  TYPE i.
    DATA ls_leg  TYPE ty_leg.

    " A pickup route visits the nearest stop first; stops with no pickup chosen
    " are left off, and each leg carries the distance travelled so far.
    LOOP AT it_stops INTO DATA(ls_stop).
      IF ls_stop-customer IS INITIAL OR ls_stop-quantity <= 0.
        CONTINUE.
      ENDIF.

      lv_seq = lv_seq + 1.

      CLEAR ls_work.
      ls_work-customer = ls_stop-customer.
      ls_work-quantity = ls_stop-quantity.
      ls_work-distance = ls_stop-distance.
      ls_work-seq = lv_seq.
      APPEND ls_work TO lt_work.
    ENDLOOP.

    SORT lt_work BY distance ASCENDING
                    seq      ASCENDING.

    LOOP AT lt_work INTO ls_work.
      lv_cum = lv_cum + ls_work-distance.

      CLEAR ls_leg.
      ls_leg-customer = ls_work-customer.
      ls_leg-quantity = ls_work-quantity.
      ls_leg-distance = ls_work-distance.
      ls_leg-cumulative = lv_cum.
      APPEND ls_leg TO rt_route.
    ENDLOOP.
  ENDMETHOD.

  METHOD stop_count.
    rv_count = lines( it_stops ).
  ENDMETHOD.

  METHOD total_quantity.
    LOOP AT it_stops INTO DATA(ls_stop).
      IF ls_stop-quantity > 0.
        rv_qty = rv_qty + ls_stop-quantity.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
