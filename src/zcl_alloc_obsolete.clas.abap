CLASS zcl_alloc_obsolete DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS is_obsolete
      IMPORTING
        iv_age_days  TYPE i
        iv_threshold TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS risk
      IMPORTING
        iv_age_days    TYPE i
        iv_threshold   TYPE i
      RETURNING
        VALUE(rv_risk) TYPE string.

    METHODS count_obsolete
      IMPORTING
        it_values       TYPE ty_values_tt
        iv_threshold    TYPE i
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_obsolete IMPLEMENTATION.

  METHOD is_obsolete.
    " Stock is obsolete once its age reaches the threshold.
    rv_ok = xsdbool( iv_age_days >= iv_threshold ).
  ENDMETHOD.

  METHOD risk.
    " The risk rises from half the threshold to the threshold itself.
    IF iv_age_days >= iv_threshold.
      rv_risk = 'HIGH'.
    ELSEIF iv_age_days >= iv_threshold DIV 2.
      rv_risk = 'MEDIUM'.
    ELSE.
      rv_risk = 'LOW'.
    ENDIF.
  ENDMETHOD.

  METHOD count_obsolete.
    LOOP AT it_values INTO DATA(lv_age).
      IF is_obsolete( iv_age_days  = lv_age
                      iv_threshold = iv_threshold ) = abap_true.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
