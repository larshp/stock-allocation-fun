CLASS zcl_alloc_bulk_load DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_id    TYPE c LENGTH 20.
    TYPES ty_id_tt TYPE STANDARD TABLE OF ty_id WITH DEFAULT KEY.

    METHODS stage
      IMPORTING
        iv_id TYPE ty_id.

    METHODS commit
      RETURNING
        VALUE(rv_loaded) TYPE i.

    METHODS staged_count
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS loaded_count
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS is_loaded
      IMPORTING
        iv_id            TYPE ty_id
      RETURNING
        VALUE(rv_loaded) TYPE abap_bool.

  PRIVATE SECTION.
    DATA mt_loaded TYPE ty_id_tt.
    DATA mt_staged TYPE ty_id_tt.

ENDCLASS.


CLASS zcl_alloc_bulk_load IMPLEMENTATION.

  METHOD stage.
    DATA lv_id     TYPE ty_id.
    DATA lv_exists TYPE abap_bool.

    LOOP AT mt_staged INTO lv_id.
      IF lv_id = iv_id.
        lv_exists = abap_true.
      ENDIF.
    ENDLOOP.

    IF lv_exists = abap_false.
      APPEND iv_id TO mt_staged.
    ENDIF.
  ENDMETHOD.

  METHOD commit.
    DATA lv_id TYPE ty_id.

    LOOP AT mt_staged INTO lv_id.
      APPEND lv_id TO mt_loaded.
      rv_loaded = rv_loaded + 1.
    ENDLOOP.

    CLEAR mt_staged.
  ENDMETHOD.

  METHOD staged_count.
    rv_count = lines( mt_staged ).
  ENDMETHOD.

  METHOD loaded_count.
    rv_count = lines( mt_loaded ).
  ENDMETHOD.

  METHOD is_loaded.
    DATA lv_id    TYPE ty_id.
    DATA lv_found TYPE abap_bool.

    LOOP AT mt_loaded INTO lv_id.
      IF lv_id = iv_id.
        lv_found = abap_true.
      ENDIF.
    ENDLOOP.

    rv_loaded = lv_found.
  ENDMETHOD.

ENDCLASS.
