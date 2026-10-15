CLASS zcl_alloc_val_return DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS value
      IMPORTING
        iv_original_value    TYPE i
        iv_reduction_percent TYPE i
      RETURNING
        VALUE(rv_value)      TYPE i.

    METHODS is_reduced
      IMPORTING
        iv_reduction_percent TYPE i
      RETURNING
        VALUE(rv_ok)         TYPE abap_bool.

    METHODS reduction_percent
      IMPORTING
        iv_original_value TYPE i
        iv_return_value   TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

ENDCLASS.


CLASS zcl_alloc_val_return IMPLEMENTATION.

  METHOD value.
    " Returned stock is valued below its original price by the reduction.
    IF iv_reduction_percent <= 0.
      rv_value = iv_original_value.
      RETURN.
    ENDIF.

    IF iv_reduction_percent >= 100.
      RETURN.
    ENDIF.

    rv_value = iv_original_value * ( 100 - iv_reduction_percent ) DIV 100.
  ENDMETHOD.

  METHOD is_reduced.
    " A return is reduced once a reduction rate is set.
    rv_ok = xsdbool( iv_reduction_percent > 0 ).
  ENDMETHOD.

  METHOD reduction_percent.
    " The reduction is the part the return value fell short of the original.
    IF iv_original_value <= 0.
      RETURN.
    ENDIF.

    rv_percent = ( iv_original_value - iv_return_value ) * 100
                 DIV iv_original_value.
  ENDMETHOD.

ENDCLASS.
