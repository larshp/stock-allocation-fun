CLASS zcl_alloc_surrogate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_key TYPE c LENGTH 60.
    TYPES ty_sid TYPE c LENGTH 10.

    TYPES: BEGIN OF ty_map,
             key TYPE ty_key,
             sid TYPE ty_sid,
           END OF ty_map.
    TYPES ty_map_tt TYPE STANDARD TABLE OF ty_map WITH DEFAULT KEY.

    METHODS get_or_create
      IMPORTING
        iv_key        TYPE ty_key
      RETURNING
        VALUE(rv_sid) TYPE ty_sid.

    METHODS lookup
      IMPORTING
        iv_key        TYPE ty_key
      RETURNING
        VALUE(rv_sid) TYPE ty_sid.

    METHODS count
      RETURNING
        VALUE(rv_count) TYPE i.

  PRIVATE SECTION.
    DATA mt_map  TYPE ty_map_tt.
    DATA mv_next TYPE i.

ENDCLASS.


CLASS zcl_alloc_surrogate IMPLEMENTATION.

  METHOD get_or_create.
    DATA ls_map TYPE ty_map.

    READ TABLE mt_map INTO ls_map WITH KEY key = iv_key.

    IF sy-subrc = 0.
      rv_sid = ls_map-sid.
      RETURN.
    ENDIF.

    mv_next = mv_next + 1.
    ls_map-key = iv_key.
    ls_map-sid = |SID-{ mv_next }|.

    APPEND ls_map TO mt_map.

    rv_sid = ls_map-sid.
  ENDMETHOD.

  METHOD lookup.
    DATA ls_map TYPE ty_map.

    READ TABLE mt_map INTO ls_map WITH KEY key = iv_key.

    IF sy-subrc = 0.
      rv_sid = ls_map-sid.
    ENDIF.
  ENDMETHOD.

  METHOD count.
    rv_count = lines( mt_map ).
  ENDMETHOD.

ENDCLASS.
