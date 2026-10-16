CLASS zcl_alloc_var_alert DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS is_over_threshold
      IMPORTING
        iv_variance  TYPE i
        iv_threshold TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS alert
      IMPORTING
        iv_variance    TYPE i
        iv_threshold   TYPE i
      RETURNING
        VALUE(rv_over) TYPE i.

    METHODS level
      IMPORTING
        iv_variance     TYPE i
        iv_threshold    TYPE i
      RETURNING
        VALUE(rv_level) TYPE string.

ENDCLASS.


CLASS zcl_alloc_var_alert IMPLEMENTATION.

  METHOD is_over_threshold.
    " The size of the variance is what matters, whichever way it points.
    IF iv_variance < 0.
      rv_ok = xsdbool( -1 * iv_variance > iv_threshold ).
    ELSE.
      rv_ok = xsdbool( iv_variance > iv_threshold ).
    ENDIF.
  ENDMETHOD.

  METHOD alert.
    " The alert is what the variance runs over the threshold by.
    DATA lv_size TYPE i.

    IF iv_variance < 0.
      lv_size = -1 * iv_variance.
    ELSE.
      lv_size = iv_variance.
    ENDIF.

    IF lv_size <= iv_threshold.
      RETURN.
    ENDIF.

    rv_over = lv_size - iv_threshold.
  ENDMETHOD.

  METHOD level.
    DATA lv_size TYPE i.

    " Twice the threshold is a high alert, anything over it is medium.
    IF iv_variance < 0.
      lv_size = -1 * iv_variance.
    ELSE.
      lv_size = iv_variance.
    ENDIF.

    IF lv_size > 2 * iv_threshold.
      rv_level = 'HIGH'.
    ELSEIF lv_size > iv_threshold.
      rv_level = 'MEDIUM'.
    ELSE.
      rv_level = 'NONE'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
