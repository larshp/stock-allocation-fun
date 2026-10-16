CLASS zcl_alloc_drv_normalize DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS factor
      IMPORTING
        iv_total         TYPE i
        iv_target        TYPE i
      RETURNING
        VALUE(rv_factor) TYPE i.

    METHODS normalize
      IMPORTING
        iv_value         TYPE i
        iv_total         TYPE i
        iv_target        TYPE i
      RETURNING
        VALUE(rv_scaled) TYPE i.

    METHODS is_normal
      IMPORTING
        iv_total     TYPE i
        iv_target    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_drv_normalize IMPLEMENTATION.

  METHOD factor.
    " The factor scales the total up or down to the target.
    IF iv_total = 0.
      RETURN.
    ENDIF.

    rv_factor = iv_target * 100 DIV iv_total.
  ENDMETHOD.

  METHOD normalize.
    " A driver is scaled so that the whole set lands on the target.
    IF iv_total = 0.
      RETURN.
    ENDIF.

    rv_scaled = iv_value * iv_target DIV iv_total.
  ENDMETHOD.

  METHOD is_normal.
    " The driver set is normal once its total already matches the target.
    rv_ok = xsdbool( iv_total = iv_target ).
  ENDMETHOD.

ENDCLASS.
