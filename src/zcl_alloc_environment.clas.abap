CLASS zcl_alloc_environment DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_sysid   TYPE c LENGTH 8.
    TYPES ty_mandt   TYPE c LENGTH 3.
    TYPES ty_release TYPE c LENGTH 4.

    TYPES: BEGIN OF ty_info,
             system_id     TYPE ty_sysid,
             client        TYPE ty_mandt,
             release       TYPE ty_release,
             is_production TYPE abap_bool,
           END OF ty_info.

    METHODS build
      IMPORTING
        iv_system_id   TYPE ty_sysid
        iv_client      TYPE ty_mandt
        iv_release     TYPE ty_release
      RETURNING
        VALUE(rs_info) TYPE ty_info.

    METHODS is_production
      IMPORTING
        iv_client            TYPE ty_mandt
      RETURNING
        VALUE(rv_productive) TYPE abap_bool.

    METHODS describe
      IMPORTING
        is_info        TYPE ty_info
      RETURNING
        VALUE(rv_text) TYPE string.

ENDCLASS.


CLASS zcl_alloc_environment IMPLEMENTATION.

  METHOD build.
    rs_info-system_id = iv_system_id.
    rs_info-client = iv_client.
    rs_info-release = iv_release.
    rs_info-is_production = me->is_production( iv_client = iv_client ).
  ENDMETHOD.

  METHOD is_production.
    IF iv_client = '000' OR iv_client = '066'.
      rv_productive = abap_false.
    ELSE.
      rv_productive = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD describe.
    IF is_info-is_production = abap_true.
      rv_text = |{ is_info-system_id }/{ is_info-client } { is_info-release } (productive)|.
    ELSE.
      rv_text = |{ is_info-system_id }/{ is_info-client } { is_info-release } (non-productive)|.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
