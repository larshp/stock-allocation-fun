CLASS zcl_alloc_client DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_mandt TYPE c LENGTH 3.

    METHODS constructor
      IMPORTING
        iv_client TYPE ty_mandt DEFAULT '000'.

    METHODS get_client
      RETURNING
        VALUE(rv_client) TYPE ty_mandt.

    METHODS is_productive
      RETURNING
        VALUE(rv_productive) TYPE abap_bool.

    METHODS label
      RETURNING
        VALUE(rv_label) TYPE string.

  PRIVATE SECTION.
    DATA mv_client TYPE ty_mandt.

ENDCLASS.


CLASS zcl_alloc_client IMPLEMENTATION.

  METHOD constructor.
    IF iv_client IS INITIAL.
      mv_client = '000'.
    ELSE.
      mv_client = iv_client.
    ENDIF.
  ENDMETHOD.

  METHOD get_client.
    rv_client = mv_client.
  ENDMETHOD.

  METHOD is_productive.
    IF mv_client = '000' OR mv_client = '066'.
      rv_productive = abap_false.
    ELSE.
      rv_productive = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD label.
    IF me->is_productive( ) = abap_true.
      rv_label = |Client { mv_client } (productive)|.
    ELSE.
      rv_label = |Client { mv_client } (non-productive)|.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
