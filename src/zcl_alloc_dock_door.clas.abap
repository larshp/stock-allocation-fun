CLASS zcl_alloc_dock_door DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_door_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_load,
             load_id TYPE string,
           END OF ty_load.
    TYPES ty_load_tt TYPE STANDARD TABLE OF ty_load WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_assign,
             load_id TYPE string,
             door    TYPE string,
           END OF ty_assign.
    TYPES ty_assign_tt TYPE STANDARD TABLE OF ty_assign WITH DEFAULT KEY.

    METHODS assign
      IMPORTING
        it_loads         TYPE ty_load_tt
        it_doors         TYPE ty_door_tt
      RETURNING
        VALUE(rt_assign) TYPE ty_assign_tt.

ENDCLASS.


CLASS zcl_alloc_dock_door IMPLEMENTATION.

  METHOD assign.
    DATA lo_count      TYPE REF TO zcl_alloc_key_map.
    DATA lv_best       TYPE string.
    DATA lv_best_count TYPE menge_d.
    DATA lv_count      TYPE menge_d.
    DATA ls_assign     TYPE ty_assign.

    IF lines( it_doors ) = 0.
      RETURN.
    ENDIF.

    " The least busy door gets the next load, and the door counts are kept in the
    " scale-safe map so the choice stays one lookup per door per load.
    lo_count = NEW zcl_alloc_key_map( ).

    LOOP AT it_loads INTO DATA(ls_load).
      CLEAR lv_best.
      CLEAR lv_best_count.

      LOOP AT it_doors INTO DATA(lv_door).
        lv_count = lo_count->get( iv_key = lv_door ).

        IF lv_best IS INITIAL OR lv_count < lv_best_count.
          lv_best = lv_door.
          lv_best_count = lv_count.
        ENDIF.
      ENDLOOP.

      lo_count->add( iv_key   = lv_best
                     iv_delta = 1 ).

      CLEAR ls_assign.
      ls_assign-load_id = ls_load-load_id.
      ls_assign-door = lv_best.
      APPEND ls_assign TO rt_assign.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
