CLASS zcl_alloc_cache_warm DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_key    TYPE c LENGTH 20.
    TYPES ty_key_tt TYPE STANDARD TABLE OF ty_key WITH DEFAULT KEY.

    METHODS missing
      IMPORTING
        it_cached         TYPE ty_key_tt
        it_wanted         TYPE ty_key_tt
      RETURNING
        VALUE(rt_missing) TYPE ty_key_tt.

    METHODS cached_count
      IMPORTING
        it_cached       TYPE ty_key_tt
        it_wanted       TYPE ty_key_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_cache_warm IMPLEMENTATION.

  METHOD missing.
    DATA lv_key   TYPE ty_key.
    DATA lv_other TYPE ty_key.
    DATA lv_found TYPE abap_bool.

    LOOP AT it_wanted INTO lv_key.
      lv_found = abap_false.

      LOOP AT it_cached INTO lv_other.
        IF lv_other = lv_key.
          lv_found = abap_true.
        ENDIF.
      ENDLOOP.

      IF lv_found = abap_false.
        APPEND lv_key TO rt_missing.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD cached_count.
    DATA lv_key   TYPE ty_key.
    DATA lv_other TYPE ty_key.
    DATA lv_found TYPE abap_bool.

    LOOP AT it_wanted INTO lv_key.
      lv_found = abap_false.

      LOOP AT it_cached INTO lv_other.
        IF lv_other = lv_key.
          lv_found = abap_true.
        ENDIF.
      ENDLOOP.

      IF lv_found = abap_true.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
