CLASS zcl_alloc_space_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS percent
      IMPORTING
        iv_used       TYPE i
        iv_total      TYPE i
      RETURNING
        VALUE(rv_pct) TYPE i.

    METHODS above_threshold
      IMPORTING
        iv_used        TYPE i
        iv_total       TYPE i
        iv_threshold   TYPE i
      RETURNING
        VALUE(rv_over) TYPE abap_bool.

    METHODS classify
      IMPORTING
        iv_used         TYPE i
        iv_total        TYPE i
      RETURNING
        VALUE(rv_class) TYPE string.

ENDCLASS.


CLASS zcl_alloc_space_util IMPLEMENTATION.

  METHOD percent.
    IF iv_used <= 0 OR iv_total <= 0.
      RETURN.
    ENDIF.

    rv_pct = iv_used * 100 DIV iv_total.
  ENDMETHOD.

  METHOD above_threshold.
    IF iv_threshold <= 0.
      RETURN.
    ENDIF.

    rv_over = xsdbool( percent( iv_used = iv_used
                               iv_total = iv_total ) > iv_threshold ).
  ENDMETHOD.

  METHOD classify.
    DATA lv_pct TYPE i.

    lv_pct = percent( iv_used = iv_used iv_total = iv_total ).

    IF lv_pct <= 0.
      rv_class = 'EMPTY'.
    ELSEIF lv_pct < 50.
      rv_class = 'LOW'.
    ELSEIF lv_pct < 80.
      rv_class = 'OK'.
    ELSEIF lv_pct < 100.
      rv_class = 'HIGH'.
    ELSE.
      rv_class = 'FULL'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
