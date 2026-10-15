CLASS zcl_alloc_service_factor DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS factor
      IMPORTING
        iv_service_level_percent TYPE i
      RETURNING
        VALUE(rv_factor)         TYPE i.

    METHODS level_of
      IMPORTING
        iv_factor         TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS is_high
      IMPORTING
        iv_service_level_percent TYPE i
      RETURNING
        VALUE(rv_ok)             TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_service_factor IMPLEMENTATION.

  METHOD factor.
    " The factor follows the usual normal-distribution service levels.
    IF iv_service_level_percent >= 99.
      rv_factor = 233.
    ELSEIF iv_service_level_percent >= 98.
      rv_factor = 205.
    ELSEIF iv_service_level_percent >= 95.
      rv_factor = 165.
    ELSEIF iv_service_level_percent >= 90.
      rv_factor = 128.
    ELSE.
      rv_factor = 0.
    ENDIF.
  ENDMETHOD.

  METHOD level_of.
    " The reverse of factor maps a factor back to its service level.
    IF iv_factor >= 233.
      rv_percent = 99.
    ELSEIF iv_factor >= 205.
      rv_percent = 98.
    ELSEIF iv_factor >= 165.
      rv_percent = 95.
    ELSEIF iv_factor >= 128.
      rv_percent = 90.
    ELSE.
      rv_percent = 0.
    ENDIF.
  ENDMETHOD.

  METHOD is_high.
    " A service level of 95 percent or more counts as high.
    rv_ok = xsdbool( iv_service_level_percent >= 95 ).
  ENDMETHOD.

ENDCLASS.
