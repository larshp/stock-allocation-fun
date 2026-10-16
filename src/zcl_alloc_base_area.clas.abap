CLASS zcl_alloc_base_area DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS area
      IMPORTING
        it_areas       TYPE ty_values_tt
      RETURNING
        VALUE(rv_area) TYPE i.

    METHODS share
      IMPORTING
        iv_area           TYPE i
        iv_total          TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS total
      IMPORTING
        it_values       TYPE ty_values_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_base_area IMPLEMENTATION.

  METHOD area.
    " The area adds up over the base lines.
    LOOP AT it_areas INTO DATA(lv_area).
      rv_area = rv_area + lv_area.
    ENDLOOP.
  ENDMETHOD.

  METHOD share.
    " The share is one area against the whole.
    IF iv_total = 0.
      RETURN.
    ENDIF.

    rv_percent = iv_area * 100 DIV iv_total.
  ENDMETHOD.

  METHOD total.
    " The total adds up the areas.
    LOOP AT it_values INTO DATA(lv_value).
      rv_total = rv_total + lv_value.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
