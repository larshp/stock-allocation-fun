CLASS zcl_alloc_act_curve DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS is_improving
      IMPORTING
        it_values    TYPE ty_values_tt
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS change
      IMPORTING
        it_values        TYPE ty_values_tt
      RETURNING
        VALUE(rv_change) TYPE i.

    METHODS count
      IMPORTING
        it_values       TYPE ty_values_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_act_curve IMPLEMENTATION.

  METHOD is_improving.
    DATA lv_first TYPE i.
    DATA lv_last  TYPE i.
    DATA lv_seen  TYPE abap_bool.

    " The curve improves once its last rate sits below its first.
    LOOP AT it_values INTO DATA(lv_value).
      IF lv_seen = abap_false.
        lv_first = lv_value.
        lv_seen = abap_true.
      ENDIF.
      lv_last = lv_value.
    ENDLOOP.

    IF lv_seen = abap_false.
      RETURN.
    ENDIF.

    rv_ok = xsdbool( lv_last < lv_first ).
  ENDMETHOD.

  METHOD change.
    DATA lv_first TYPE i.
    DATA lv_last  TYPE i.
    DATA lv_seen  TYPE abap_bool.

    " The change is the last rate less the first.
    LOOP AT it_values INTO DATA(lv_value).
      IF lv_seen = abap_false.
        lv_first = lv_value.
        lv_seen = abap_true.
      ENDIF.
      lv_last = lv_value.
    ENDLOOP.

    IF lv_seen = abap_false.
      RETURN.
    ENDIF.

    rv_change = lv_last - lv_first.
  ENDMETHOD.

  METHOD count.
    rv_count = lines( it_values ).
  ENDMETHOD.

ENDCLASS.
