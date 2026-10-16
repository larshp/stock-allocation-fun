CLASS zcl_alloc_replenish_policy DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS target_days
      IMPORTING
        iv_preset      TYPE string
      RETURNING
        VALUE(rv_days) TYPE i.

    METHODS service_level
      IMPORTING
        iv_preset         TYPE string
      RETURNING
        VALUE(rv_service) TYPE i.

    METHODS preset
      IMPORTING
        iv_target_days   TYPE i
        iv_service_level TYPE i
      RETURNING
        VALUE(rv_preset) TYPE string.

ENDCLASS.


CLASS zcl_alloc_replenish_policy IMPLEMENTATION.

  METHOD target_days.
    " The coverage target widens from the lean preset to the safe one.
    CASE iv_preset.
      WHEN 'LEAN'.
        rv_days = 7.
      WHEN 'SAFE'.
        rv_days = 30.
      WHEN OTHERS.
        rv_days = 14.
    ENDCASE.
  ENDMETHOD.

  METHOD service_level.
    " The service target rises with the coverage target.
    CASE iv_preset.
      WHEN 'LEAN'.
        rv_service = 90.
      WHEN 'SAFE'.
        rv_service = 99.
      WHEN OTHERS.
        rv_service = 95.
    ENDCASE.
  ENDMETHOD.

  METHOD preset.
    " The preset is named back from the two settings it stands for.
    IF iv_target_days = 7 AND iv_service_level = 90.
      rv_preset = 'LEAN'.
    ELSEIF iv_target_days = 14 AND iv_service_level = 95.
      rv_preset = 'BALANCED'.
    ELSEIF iv_target_days = 30 AND iv_service_level = 99.
      rv_preset = 'SAFE'.
    ELSE.
      rv_preset = 'CUSTOM'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
