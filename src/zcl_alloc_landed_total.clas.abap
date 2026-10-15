CLASS zcl_alloc_landed_total DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS total
      IMPORTING
        iv_base_cost    TYPE i
        iv_add_on       TYPE i
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS markup_percent
      IMPORTING
        iv_base_cost      TYPE i
        iv_landed         TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS is_custom
      IMPORTING
        iv_component_count TYPE i
      RETURNING
        VALUE(rv_ok)       TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_landed_total IMPLEMENTATION.

  METHOD total.
    " The landed cost is the base cost plus what it took to land it.
    rv_total = iv_base_cost + iv_add_on.
  ENDMETHOD.

  METHOD markup_percent.
    DATA lv_add_on TYPE i.

    " The mark-up is the landing cost related to the base cost.
    IF iv_base_cost <= 0.
      RETURN.
    ENDIF.

    lv_add_on = iv_landed - iv_base_cost.
    rv_percent = lv_add_on * 100 DIV iv_base_cost.
  ENDMETHOD.

  METHOD is_custom.
    " A landed cost built from more than one component is a custom one.
    rv_ok = xsdbool( iv_component_count > 1 ).
  ENDMETHOD.

ENDCLASS.
