CLASS zcl_alloc_cache_policy DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        iv_max_age   TYPE i DEFAULT 60
        iv_max_items TYPE i DEFAULT 100.

    METHODS is_stale
      IMPORTING
        iv_age_seconds  TYPE i
      RETURNING
        VALUE(rv_stale) TYPE abap_bool.

    METHODS is_full
      IMPORTING
        iv_item_count TYPE i
      RETURNING
        VALUE(rv_ok)  TYPE abap_bool.

    METHODS describe
      RETURNING
        VALUE(rv_text) TYPE string.

  PRIVATE SECTION.
    DATA mv_max_age   TYPE i.
    DATA mv_max_items TYPE i.

ENDCLASS.


CLASS zcl_alloc_cache_policy IMPLEMENTATION.

  METHOD constructor.
    mv_max_age = iv_max_age.
    mv_max_items = iv_max_items.
  ENDMETHOD.

  METHOD is_stale.
    IF iv_age_seconds >= mv_max_age.
      rv_stale = abap_true.
    ELSE.
      rv_stale = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD is_full.
    IF iv_item_count >= mv_max_items.
      rv_ok = abap_true.
    ELSE.
      rv_ok = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD describe.
    rv_text = |max age { mv_max_age }s, max items { mv_max_items }|.
  ENDMETHOD.

ENDCLASS.
