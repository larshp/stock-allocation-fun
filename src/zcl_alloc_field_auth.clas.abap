CLASS zcl_alloc_field_auth DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_field   TYPE c LENGTH 20.
    TYPES ty_field_tt TYPE STANDARD TABLE OF ty_field WITH DEFAULT KEY.

    METHODS constructor
      IMPORTING
        it_hidden TYPE ty_field_tt.

    METHODS is_visible
      IMPORTING
        iv_field          TYPE ty_field
      RETURNING
        VALUE(rv_visible) TYPE abap_bool.

    METHODS hide
      IMPORTING
        iv_field TYPE ty_field.

    METHODS visible_count
      IMPORTING
        it_fields       TYPE ty_field_tt
      RETURNING
        VALUE(rv_count) TYPE i.

  PRIVATE SECTION.
    DATA mt_hidden TYPE ty_field_tt.

ENDCLASS.


CLASS zcl_alloc_field_auth IMPLEMENTATION.

  METHOD constructor.
    mt_hidden = it_hidden.
  ENDMETHOD.

  METHOD is_visible.
    DATA lv_hidden TYPE ty_field.

    LOOP AT mt_hidden INTO lv_hidden.
      IF lv_hidden = iv_field.
        rv_visible = abap_false.
        RETURN.
      ENDIF.
    ENDLOOP.

    rv_visible = abap_true.
  ENDMETHOD.

  METHOD hide.
    DATA lv_hidden TYPE ty_field.

    LOOP AT mt_hidden INTO lv_hidden.
      IF lv_hidden = iv_field.
        RETURN.
      ENDIF.
    ENDLOOP.

    APPEND iv_field TO mt_hidden.
  ENDMETHOD.

  METHOD visible_count.
    DATA lv_field  TYPE ty_field.
    DATA lv_hidden TYPE ty_field.
    DATA lv_found  TYPE abap_bool.

    LOOP AT it_fields INTO lv_field.
      lv_found = abap_false.

      LOOP AT mt_hidden INTO lv_hidden.
        IF lv_hidden = lv_field.
          lv_found = abap_true.
        ENDIF.
      ENDLOOP.

      IF lv_found = abap_false.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
