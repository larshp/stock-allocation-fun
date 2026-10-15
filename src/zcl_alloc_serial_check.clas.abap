CLASS zcl_alloc_serial_check DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_int_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS in_range
      IMPORTING
        iv_serial    TYPE i
        iv_from      TYPE i
        iv_to        TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS is_unique
      IMPORTING
        it_serials       TYPE ty_int_tt
      RETURNING
        VALUE(rv_unique) TYPE abap_bool.

    METHODS duplicates
      IMPORTING
        it_serials      TYPE ty_int_tt
      RETURNING
        VALUE(rt_dupes) TYPE ty_int_tt.

ENDCLASS.


CLASS zcl_alloc_serial_check IMPLEMENTATION.

  METHOD in_range.
    rv_ok = xsdbool( iv_from <= iv_to
                     AND iv_serial >= iv_from
                     AND iv_serial <= iv_to ).
  ENDMETHOD.

  METHOD duplicates.
    DATA lo_seen TYPE REF TO zcl_alloc_key_map.
    DATA lv_key  TYPE string.

    " The map makes the duplicate scan one lookup per serial instead of a rescan
    " of the result table.
    lo_seen = NEW zcl_alloc_key_map( ).

    LOOP AT it_serials INTO DATA(lv_serial).
      lv_key = |{ lv_serial }|.

      IF lo_seen->has( iv_key = lv_key ) = abap_true.
        APPEND lv_serial TO rt_dupes.
      ELSE.
        lo_seen->put( iv_key   = lv_key
                      iv_value = 1 ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_unique.
    rv_unique = xsdbool( lines( duplicates( it_serials ) ) = 0 ).
  ENDMETHOD.

ENDCLASS.
