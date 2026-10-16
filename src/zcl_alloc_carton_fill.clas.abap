CLASS zcl_alloc_carton_fill DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_volume,
             volume TYPE i,
           END OF ty_volume.
    TYPES ty_volume_tt TYPE STANDARD TABLE OF ty_volume WITH DEFAULT KEY.

    METHODS fill_percent
      IMPORTING
        iv_item_volume    TYPE i
        iv_carton_volume  TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS fits
      IMPORTING
        iv_item_volume   TYPE i
        iv_carton_volume TYPE i
      RETURNING
        VALUE(rv_fits)   TYPE abap_bool.

    METHODS cartons_needed
      IMPORTING
        it_volumes        TYPE ty_volume_tt
        iv_carton_volume  TYPE i
      RETURNING
        VALUE(rv_cartons) TYPE i.

ENDCLASS.


CLASS zcl_alloc_carton_fill IMPLEMENTATION.

  METHOD fill_percent.
    IF iv_carton_volume <= 0 OR iv_item_volume <= 0.
      RETURN.
    ENDIF.

    rv_percent = iv_item_volume * 100 DIV iv_carton_volume.
  ENDMETHOD.

  METHOD fits.
    rv_fits = xsdbool( iv_carton_volume > 0
                   AND iv_item_volume <= iv_carton_volume ).
  ENDMETHOD.

  METHOD cartons_needed.
    DATA lv_total TYPE i.

    LOOP AT it_volumes INTO DATA(ls_volume).
      IF ls_volume-volume > 0.
        lv_total = lv_total + ls_volume-volume.
      ENDIF.
    ENDLOOP.

    IF lv_total <= 0 OR iv_carton_volume <= 0.
      RETURN.
    ENDIF.

    rv_cartons = ( lv_total + iv_carton_volume - 1 ) DIV iv_carton_volume.
  ENDMETHOD.

ENDCLASS.
