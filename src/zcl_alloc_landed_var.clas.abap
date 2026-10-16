CLASS zcl_alloc_landed_var DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS variance
      IMPORTING
        iv_actual          TYPE i
        iv_planned         TYPE i
      RETURNING
        VALUE(rv_variance) TYPE i.

    METHODS is_over
      IMPORTING
        iv_actual    TYPE i
        iv_planned   TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS percent
      IMPORTING
        iv_actual         TYPE i
        iv_planned        TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

ENDCLASS.


CLASS zcl_alloc_landed_var IMPLEMENTATION.

  METHOD variance.
    " The variance is the actual landed cost less the planned one.
    rv_variance = iv_actual - iv_planned.
  ENDMETHOD.

  METHOD is_over.
    " The landed cost is over plan once the actual passes the planned cost.
    rv_ok = xsdbool( iv_actual > iv_planned ).
  ENDMETHOD.

  METHOD percent.
    DATA lv_variance TYPE i.

    " The variance is related to the planned cost it was measured against.
    IF iv_planned = 0.
      RETURN.
    ENDIF.

    lv_variance = variance( iv_actual = iv_actual iv_planned = iv_planned ).
    rv_percent = lv_variance * 100 DIV iv_planned.
  ENDMETHOD.

ENDCLASS.
