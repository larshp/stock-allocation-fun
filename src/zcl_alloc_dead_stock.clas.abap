CLASS zcl_alloc_dead_stock DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material          TYPE matnr,
             last_movement_day TYPE d,
             stock             TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    METHODS days_since
      IMPORTING
        iv_last_movement_day TYPE d
        iv_today             TYPE d
      RETURNING
        VALUE(rv_days)       TYPE i.

    METHODS is_dead
      IMPORTING
        iv_days_since TYPE i
        iv_threshold  TYPE i
      RETURNING
        VALUE(rv_ok)  TYPE abap_bool.

    METHODS count_dead
      IMPORTING
        it_items        TYPE ty_item_tt
        iv_today        TYPE d
        iv_threshold    TYPE i
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_dead_stock IMPLEMENTATION.

  METHOD days_since.
    DATA lv_days TYPE i.

    " Without a movement date the age cannot be told.
    IF iv_last_movement_day IS INITIAL OR iv_today IS INITIAL.
      RETURN.
    ENDIF.

    lv_days = iv_today - iv_last_movement_day.
    IF lv_days < 0.
      RETURN.
    ENDIF.

    rv_days = lv_days.
  ENDMETHOD.

  METHOD is_dead.
    " Stock is dead once nothing has moved for the threshold span.
    rv_ok = xsdbool( iv_days_since >= iv_threshold ).
  ENDMETHOD.

  METHOD count_dead.
    DATA lv_days TYPE i.

    LOOP AT it_items INTO DATA(ls_item).
      lv_days = days_since( iv_last_movement_day = ls_item-last_movement_day
                            iv_today             = iv_today ).

      IF is_dead( iv_days_since = lv_days
                  iv_threshold  = iv_threshold ) = abap_true.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
