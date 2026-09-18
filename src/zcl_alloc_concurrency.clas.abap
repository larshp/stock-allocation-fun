CLASS zcl_alloc_concurrency DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_holder,
             key TYPE string,
           END OF ty_holder.
    TYPES ty_holder_tt TYPE STANDARD TABLE OF ty_holder WITH DEFAULT KEY.

    METHODS constructor
      IMPORTING
        iv_limit TYPE i.

    METHODS acquire
      IMPORTING
        iv_key            TYPE string
      RETURNING
        VALUE(rv_granted) TYPE abap_bool.

    METHODS release
      IMPORTING
        iv_key TYPE string.

    METHODS active_count
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS is_saturated
      RETURNING
        VALUE(rv_full) TYPE abap_bool.

  PRIVATE SECTION.
    DATA mv_limit   TYPE i.
    DATA mt_holders TYPE ty_holder_tt.

ENDCLASS.


CLASS zcl_alloc_concurrency IMPLEMENTATION.

  METHOD constructor.
    mv_limit = iv_limit.
  ENDMETHOD.

  METHOD acquire.
    DATA ls_holder TYPE ty_holder.

    READ TABLE mt_holders INTO ls_holder WITH KEY key = iv_key.
    IF sy-subrc = 0.
      rv_granted = abap_true.
      RETURN.
    ENDIF.

    IF mv_limit > 0 AND lines( mt_holders ) >= mv_limit.
      rv_granted = abap_false.
      RETURN.
    ENDIF.

    CLEAR ls_holder.
    ls_holder-key = iv_key.
    APPEND ls_holder TO mt_holders.
    rv_granted = abap_true.
  ENDMETHOD.

  METHOD release.
    DELETE mt_holders WHERE key = iv_key.
  ENDMETHOD.

  METHOD active_count.
    rv_count = lines( mt_holders ).
  ENDMETHOD.

  METHOD is_saturated.
    rv_full = abap_false.

    IF mv_limit <= 0.
      RETURN.
    ENDIF.

    IF lines( mt_holders ) >= mv_limit.
      rv_full = abap_true.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
