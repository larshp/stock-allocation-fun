CLASS zcl_alloc_lead_avg DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS average
      IMPORTING
        it_values     TYPE ty_values_tt
      RETURNING
        VALUE(rv_avg) TYPE i.

    METHODS min_days
      IMPORTING
        it_values     TYPE ty_values_tt
      RETURNING
        VALUE(rv_min) TYPE i.

    METHODS max_days
      IMPORTING
        it_values     TYPE ty_values_tt
      RETURNING
        VALUE(rv_max) TYPE i.

ENDCLASS.


CLASS zcl_alloc_lead_avg IMPLEMENTATION.

  METHOD average.
    DATA lv_sum   TYPE i.
    DATA lv_count TYPE i.

    LOOP AT it_values INTO DATA(lv_value).
      lv_sum = lv_sum + lv_value.
      lv_count = lv_count + 1.
    ENDLOOP.

    IF lv_count <= 0.
      RETURN.
    ENDIF.

    rv_avg = lv_sum DIV lv_count.
  ENDMETHOD.

  METHOD min_days.
    DATA lv_found TYPE abap_bool.

    " The first value seeds the minimum; each smaller value replaces it.
    LOOP AT it_values INTO DATA(lv_value).
      IF lv_found = abap_false OR lv_value < rv_min.
        lv_found = abap_true.
        rv_min = lv_value.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD max_days.
    DATA lv_found TYPE abap_bool.

    " The first value seeds the maximum; each larger value replaces it.
    LOOP AT it_values INTO DATA(lv_value).
      IF lv_found = abap_false OR lv_value > rv_max.
        lv_found = abap_true.
        rv_max = lv_value.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
