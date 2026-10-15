CLASS zcl_alloc_mixed_pallet DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_volume,
             volume TYPE i,
           END OF ty_volume.
    TYPES ty_volume_tt TYPE STANDARD TABLE OF ty_volume WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_pallet,
             pallet_no TYPE i,
             used      TYPE i,
             items     TYPE i,
           END OF ty_pallet.
    TYPES ty_pallet_tt TYPE STANDARD TABLE OF ty_pallet WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_volumes        TYPE ty_volume_tt
        iv_pallet_volume  TYPE i
      RETURNING
        VALUE(rt_pallets) TYPE ty_pallet_tt.

ENDCLASS.


CLASS zcl_alloc_mixed_pallet IMPLEMENTATION.

  METHOD build.
    DATA ls_new    TYPE ty_pallet.
    DATA lv_placed TYPE abap_bool.

    LOOP AT it_volumes INTO DATA(ls_volume).
      IF ls_volume-volume <= 0 OR iv_pallet_volume <= 0.
        CONTINUE.
      ENDIF.

      " First fit: put the volume on the first pallet that still has room. A
      " volume larger than a whole pallet gets a pallet of its own, with `used`
      " over the limit, so the caller can see the oversize instead of losing it.
      lv_placed = abap_false.

      LOOP AT rt_pallets ASSIGNING FIELD-SYMBOL(<ls_pallet>).
        IF <ls_pallet>-used + ls_volume-volume <= iv_pallet_volume.
          <ls_pallet>-used = <ls_pallet>-used + ls_volume-volume.
          <ls_pallet>-items = <ls_pallet>-items + 1.
          lv_placed = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_placed = abap_true.
        CONTINUE.
      ENDIF.

      CLEAR ls_new.
      ls_new-pallet_no = lines( rt_pallets ) + 1.
      ls_new-used = ls_volume-volume.
      ls_new-items = 1.
      APPEND ls_new TO rt_pallets.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
