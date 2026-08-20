CLASS zcl_reservation_status_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_reservation_status.
ENDCLASS.

CLASS zcl_reservation_status_sap IMPLEMENTATION.
  METHOD zif_reservation_status~is_cancelled.
    SELECT xloek
      FROM resb
      WHERE rsnum = @iv_document_id
      INTO TABLE @DATA(lt_items).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    rv_is_cancelled = abap_true.
    LOOP AT lt_items INTO DATA(ls_item).
      IF ls_item-xloek IS INITIAL.
        rv_is_cancelled = abap_false.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
