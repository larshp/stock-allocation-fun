CLASS zcl_alloc_truck_select DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_truck,
             truck_type TYPE string,
             max_weight TYPE i,
             max_volume TYPE i,
           END OF ty_truck.
    TYPES ty_truck_tt TYPE STANDARD TABLE OF ty_truck WITH DEFAULT KEY.

    METHODS select
      IMPORTING
        it_trucks      TYPE ty_truck_tt
        iv_weight      TYPE i
        iv_volume      TYPE i
      RETURNING
        VALUE(rv_type) TYPE string.

ENDCLASS.


CLASS zcl_alloc_truck_select IMPLEMENTATION.

  METHOD select.
    DATA lv_best_weight TYPE i.
    DATA lv_best_volume TYPE i.
    DATA lv_found       TYPE abap_bool.

    " The smallest truck that still fits is the cheapest, so a fitting truck
    " replaces the current best only when it is smaller in both dimensions.
    LOOP AT it_trucks INTO DATA(ls_truck).
      IF ls_truck-max_weight <= 0 OR ls_truck-max_volume <= 0.
        CONTINUE.
      ENDIF.
      IF iv_weight > ls_truck-max_weight OR iv_volume > ls_truck-max_volume.
        CONTINUE.
      ENDIF.

      IF lv_found = abap_true
         AND ( ls_truck-max_weight > lv_best_weight
            OR ( ls_truck-max_weight = lv_best_weight
             AND ls_truck-max_volume >= lv_best_volume ) ).
        CONTINUE.
      ENDIF.

      rv_type = ls_truck-truck_type.
      lv_best_weight = ls_truck-max_weight.
      lv_best_volume = ls_truck-max_volume.
      lv_found = abap_true.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
