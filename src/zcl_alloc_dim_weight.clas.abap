CLASS zcl_alloc_dim_weight DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS dim_weight
      IMPORTING
        iv_volume        TYPE i
        iv_divisor       TYPE i
      RETURNING
        VALUE(rv_weight) TYPE i.

    METHODS chargeable
      IMPORTING
        iv_actual        TYPE i
        iv_dim           TYPE i
      RETURNING
        VALUE(rv_weight) TYPE i.

ENDCLASS.


CLASS zcl_alloc_dim_weight IMPLEMENTATION.

  METHOD dim_weight.
    IF iv_volume <= 0 OR iv_divisor <= 0.
      RETURN.
    ENDIF.

    " A freight carrier rounds the volumetric weight up to the next whole unit.
    rv_weight = ( iv_volume + iv_divisor - 1 ) DIV iv_divisor.
  ENDMETHOD.

  METHOD chargeable.
    IF iv_actual > iv_dim.
      rv_weight = iv_actual.
    ELSE.
      rv_weight = iv_dim.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
