CLASS zcl_alloc_recall_status DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS status
      IMPORTING
        iv_expected      TYPE i
        iv_recovered     TYPE i
      RETURNING
        VALUE(rv_status) TYPE string.

    METHODS recovered_percent
      IMPORTING
        iv_expected   TYPE i
        iv_recovered  TYPE i
      RETURNING
        VALUE(rv_pct) TYPE i.

    METHODS is_complete
      IMPORTING
        iv_expected  TYPE i
        iv_recovered TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_recall_status IMPLEMENTATION.

  METHOD recovered_percent.
    DATA lv_pct TYPE i.

    IF iv_expected <= 0 OR iv_recovered <= 0.
      RETURN.
    ENDIF.

    lv_pct = iv_recovered * 100 DIV iv_expected.

    " The recovered share can never exceed the whole recall.
    IF lv_pct > 100.
      rv_pct = 100.
    ELSE.
      rv_pct = lv_pct.
    ENDIF.
  ENDMETHOD.

  METHOD is_complete.
    rv_ok = xsdbool( iv_expected > 0 AND iv_recovered >= iv_expected ).
  ENDMETHOD.

  METHOD status.
    " The recall walks from open, to in progress, to complete.
    IF iv_expected <= 0.
      rv_status = 'NONE'.
    ELSEIF is_complete( iv_expected  = iv_expected
                        iv_recovered = iv_recovered ) = abap_true.
      rv_status = 'COMPLETE'.
    ELSEIF iv_recovered > 0.
      rv_status = 'IN_PROGRESS'.
    ELSE.
      rv_status = 'OPEN'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
