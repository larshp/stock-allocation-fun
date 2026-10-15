CLASS zcl_alloc_cert_check DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_text_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS missing
      IMPORTING
        it_required       TYPE ty_text_tt
        it_held           TYPE ty_text_tt
      RETURNING
        VALUE(rt_missing) TYPE ty_text_tt.

    METHODS is_complete
      IMPORTING
        it_required  TYPE ty_text_tt
        it_held      TYPE ty_text_tt
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_cert_check IMPLEMENTATION.

  METHOD missing.
    DATA lv_found TYPE abap_bool.

    " A held certificate covers a requirement only on an exact type match, and the
    " result keeps the order of the requirement list.
    LOOP AT it_required INTO DATA(lv_required).
      CLEAR lv_found.

      LOOP AT it_held INTO DATA(lv_held).
        IF lv_held = lv_required.
          lv_found = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_found = abap_false.
        APPEND lv_required TO rt_missing.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_complete.
    rv_ok = xsdbool( lines( missing( it_required = it_required
                                      it_held    = it_held ) ) = 0 ).
  ENDMETHOD.

ENDCLASS.
