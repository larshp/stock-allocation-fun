CLASS zcl_alloc_valm_drift DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS drift
      IMPORTING
        iv_target       TYPE i
        iv_actual       TYPE i
      RETURNING
        VALUE(rv_drift) TYPE i.

    METHODS is_drifting
      IMPORTING
        iv_target    TYPE i
        iv_actual    TYPE i
        iv_tolerance TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS direction
      IMPORTING
        iv_target     TYPE i
        iv_actual     TYPE i
      RETURNING
        VALUE(rv_dir) TYPE string.

ENDCLASS.


CLASS zcl_alloc_valm_drift IMPLEMENTATION.

  METHOD drift.
    " The drift is how far the actual value sits from the target.
    rv_drift = iv_actual - iv_target.
  ENDMETHOD.

  METHOD is_drifting.
    DATA lv_drift TYPE i.

    " The value is drifting once it moves past the tolerance either way.
    lv_drift = drift( iv_target = iv_target iv_actual = iv_actual ).
    IF lv_drift < 0.
      lv_drift = -1 * lv_drift.
    ENDIF.

    rv_ok = xsdbool( lv_drift > iv_tolerance ).
  ENDMETHOD.

  METHOD direction.
    " The direction says whether the actual ran over or under the target.
    IF iv_actual > iv_target.
      rv_dir = 'OVER'.
    ELSEIF iv_actual < iv_target.
      rv_dir = 'UNDER'.
    ELSE.
      rv_dir = 'ON'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
