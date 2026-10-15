CLASS zcl_alloc_pack_hier DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_level,
             name   TYPE string,
             factor TYPE i,
           END OF ty_level.
    TYPES ty_level_tt TYPE STANDARD TABLE OF ty_level WITH DEFAULT KEY.

    METHODS total_units
      IMPORTING
        it_levels       TYPE ty_level_tt
      RETURNING
        VALUE(rv_units) TYPE i.

    METHODS units_up_to
      IMPORTING
        it_levels       TYPE ty_level_tt
        iv_level        TYPE i
      RETURNING
        VALUE(rv_units) TYPE i.

ENDCLASS.


CLASS zcl_alloc_pack_hier IMPLEMENTATION.

  METHOD total_units.
    DATA lv_units TYPE i.
    DATA lv_any   TYPE abap_bool.

    " The levels are one inside the next (each, carton, layer, pallet), so the
    " units on the top level are the product of the factors.
    LOOP AT it_levels INTO DATA(ls_level).
      IF ls_level-factor <= 0.
        CONTINUE.
      ENDIF.

      IF lv_any = abap_false.
        lv_units = ls_level-factor.
        lv_any = abap_true.
      ELSE.
        lv_units = lv_units * ls_level-factor.
      ENDIF.
    ENDLOOP.

    rv_units = lv_units.
  ENDMETHOD.

  METHOD units_up_to.
    DATA lv_index TYPE i.
    DATA lv_units TYPE i.
    DATA lv_any   TYPE abap_bool.

    LOOP AT it_levels INTO DATA(ls_level).
      lv_index = lv_index + 1.
      IF lv_index > iv_level.
        EXIT.
      ENDIF.

      IF ls_level-factor <= 0.
        CONTINUE.
      ENDIF.

      IF lv_any = abap_false.
        lv_units = ls_level-factor.
        lv_any = abap_true.
      ELSE.
        lv_units = lv_units * ls_level-factor.
      ENDIF.
    ENDLOOP.

    rv_units = lv_units.
  ENDMETHOD.

ENDCLASS.
