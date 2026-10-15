CLASS zcl_alloc_count_freq DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS frequency
      IMPORTING
        iv_abc_class   TYPE string
        iv_base_days   TYPE i
      RETURNING
        VALUE(rv_days) TYPE i.

    METHODS counts_per_year
      IMPORTING
        iv_interval_days TYPE i
      RETURNING
        VALUE(rv_count)  TYPE i.

    METHODS is_valid_class
      IMPORTING
        iv_abc_class    TYPE string
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_count_freq IMPLEMENTATION.

  METHOD frequency.
    IF iv_base_days <= 0.
      RETURN.
    ENDIF.

    " A items are counted most often, C items least: the interval grows with the
    " class letter.
    IF iv_abc_class = 'A'.
      rv_days = iv_base_days.
    ELSEIF iv_abc_class = 'B'.
      rv_days = iv_base_days * 2.
    ELSEIF iv_abc_class = 'C'.
      rv_days = iv_base_days * 4.
    ENDIF.
  ENDMETHOD.

  METHOD counts_per_year.
    IF iv_interval_days <= 0.
      RETURN.
    ENDIF.

    rv_count = 365 DIV iv_interval_days.
  ENDMETHOD.

  METHOD is_valid_class.
    rv_valid = xsdbool( iv_abc_class = 'A'
                     OR iv_abc_class = 'B'
                     OR iv_abc_class = 'C' ).
  ENDMETHOD.

ENDCLASS.
