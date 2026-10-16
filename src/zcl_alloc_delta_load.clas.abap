CLASS zcl_alloc_delta_load DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_id    TYPE c LENGTH 20.
    TYPES ty_id_tt TYPE STANDARD TABLE OF ty_id WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_delta,
             added   TYPE ty_id_tt,
             removed TYPE ty_id_tt,
             kept    TYPE ty_id_tt,
           END OF ty_delta.

    METHODS compare
      IMPORTING
        it_existing     TYPE ty_id_tt
        it_incoming     TYPE ty_id_tt
      RETURNING
        VALUE(rs_delta) TYPE ty_delta.

ENDCLASS.


CLASS zcl_alloc_delta_load IMPLEMENTATION.

  METHOD compare.
    DATA lv_id    TYPE ty_id.
    DATA lv_other TYPE ty_id.
    DATA lv_found TYPE abap_bool.

    LOOP AT it_incoming INTO lv_id.
      lv_found = abap_false.

      LOOP AT it_existing INTO lv_other.
        IF lv_other = lv_id.
          lv_found = abap_true.
        ENDIF.
      ENDLOOP.

      IF lv_found = abap_true.
        APPEND lv_id TO rs_delta-kept.
      ELSE.
        APPEND lv_id TO rs_delta-added.
      ENDIF.
    ENDLOOP.

    LOOP AT it_existing INTO lv_id.
      lv_found = abap_false.

      LOOP AT it_incoming INTO lv_other.
        IF lv_other = lv_id.
          lv_found = abap_true.
        ENDIF.
      ENDLOOP.

      IF lv_found = abap_false.
        APPEND lv_id TO rs_delta-removed.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
