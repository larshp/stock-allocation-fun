CLASS zcl_alloc_valm_band DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS is_in_band
      IMPORTING
        iv_value     TYPE i
        iv_lower     TYPE i
        iv_upper     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS position
      IMPORTING
        iv_value      TYPE i
        iv_lower      TYPE i
        iv_upper      TYPE i
      RETURNING
        VALUE(rv_pos) TYPE string.

    METHODS band_gap
      IMPORTING
        iv_value      TYPE i
        iv_lower      TYPE i
        iv_upper      TYPE i
      RETURNING
        VALUE(rv_gap) TYPE i.

ENDCLASS.


CLASS zcl_alloc_valm_band IMPLEMENTATION.

  METHOD is_in_band.
    " The value is inside the band once it sits between the edges.
    rv_ok = xsdbool( iv_value >= iv_lower AND iv_value <= iv_upper ).
  ENDMETHOD.

  METHOD position.
    " The position says whether the value sits below, inside or above.
    IF iv_value < iv_lower.
      rv_pos = 'BELOW'.
    ELSEIF iv_value > iv_upper.
      rv_pos = 'ABOVE'.
    ELSE.
      rv_pos = 'INSIDE'.
    ENDIF.
  ENDMETHOD.

  METHOD band_gap.
    " The gap is how far outside the band the value sits, zero if inside.
    IF iv_value < iv_lower.
      rv_gap = iv_lower - iv_value.
    ELSEIF iv_value > iv_upper.
      rv_gap = iv_value - iv_upper.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
