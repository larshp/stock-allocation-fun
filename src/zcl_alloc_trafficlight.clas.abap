CLASS zcl_alloc_trafficlight DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_limits,
             warning_max TYPE menge_d,
             error_max   TYPE menge_d,
           END OF ty_limits.

    METHODS of_value
      IMPORTING
        is_limits       TYPE ty_limits
        iv_value        TYPE menge_d
      RETURNING
        VALUE(rv_light) TYPE i.

    METHODS text_of
      IMPORTING
        iv_light       TYPE i
      RETURNING
        VALUE(rv_text) TYPE string.

ENDCLASS.


CLASS zcl_alloc_trafficlight IMPLEMENTATION.

  METHOD of_value.
    IF iv_value <= is_limits-warning_max.
      rv_light = 1.
    ELSEIF iv_value <= is_limits-error_max.
      rv_light = 2.
    ELSE.
      rv_light = 3.
    ENDIF.
  ENDMETHOD.

  METHOD text_of.
    IF iv_light = 1.
      rv_text = 'green'.
    ELSEIF iv_light = 2.
      rv_text = 'yellow'.
    ELSEIF iv_light = 3.
      rv_text = 'red'.
    ELSE.
      rv_text = 'unknown'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
