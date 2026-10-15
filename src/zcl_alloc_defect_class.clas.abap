CLASS zcl_alloc_defect_class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_defect,
             defect_code TYPE string,
             quantity    TYPE i,
           END OF ty_defect.
    TYPES ty_defect_tt TYPE STANDARD TABLE OF ty_defect WITH DEFAULT KEY.

    METHODS classify
      IMPORTING
        iv_code         TYPE string
      RETURNING
        VALUE(rv_class) TYPE string.

    METHODS worst
      IMPORTING
        it_defects      TYPE ty_defect_tt
      RETURNING
        VALUE(rv_class) TYPE string.

    METHODS count_of
      IMPORTING
        it_defects      TYPE ty_defect_tt
        iv_class        TYPE string
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_defect_class IMPLEMENTATION.

  METHOD classify.
    DATA lv_len      TYPE i.
    DATA lv_prefix   TYPE string.

    lv_len = strlen( iv_code ).

    " The code prefix carries the severity, and the length is checked first
    " because substring( ) would run past a short code.
    IF lv_len >= 4.
      lv_prefix = substring( val = iv_code off = 0 len = 4 ).
      IF lv_prefix = 'CRIT'.
        rv_class = 'CRITICAL'.
        RETURN.
      ENDIF.
    ENDIF.

    IF lv_len >= 3.
      lv_prefix = substring( val = iv_code off = 0 len = 3 ).
      IF lv_prefix = 'MAJ'.
        rv_class = 'MAJOR'.
        RETURN.
      ENDIF.
    ENDIF.

    rv_class = 'MINOR'.
  ENDMETHOD.

  METHOD worst.
    DATA lv_class TYPE string.

    " CRITICAL beats MAJOR beats MINOR, and no defect at all is the empty string.
    LOOP AT it_defects INTO DATA(ls_defect).
      lv_class = classify( ls_defect-defect_code ).

      IF lv_class = 'CRITICAL'.
        rv_class = 'CRITICAL'.
        RETURN.
      ELSEIF lv_class = 'MAJOR' AND rv_class <> 'CRITICAL'.
        rv_class = 'MAJOR'.
      ELSEIF rv_class IS INITIAL.
        rv_class = lv_class.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD count_of.
    LOOP AT it_defects INTO DATA(ls_defect).
      IF classify( ls_defect-defect_code ) = iv_class.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
