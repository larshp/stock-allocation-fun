CLASS zcl_alloc_absorb_amount DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS absorbed
      IMPORTING
        iv_rate            TYPE i
        iv_actual_base     TYPE i
      RETURNING
        VALUE(rv_absorbed) TYPE i.

    METHODS variance
      IMPORTING
        iv_absorbed        TYPE i
        iv_actual          TYPE i
      RETURNING
        VALUE(rv_variance) TYPE i.

    METHODS is_over
      IMPORTING
        iv_absorbed  TYPE i
        iv_actual    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_absorb_amount IMPLEMENTATION.

  METHOD absorbed.
    " The absorbed overhead is the rate over the actual base.
    rv_absorbed = iv_rate * iv_actual_base.
  ENDMETHOD.

  METHOD variance.
    " A positive variance is overhead absorbed above the actual one.
    rv_variance = iv_absorbed - iv_actual.
  ENDMETHOD.

  METHOD is_over.
    " The absorption is over once more is absorbed than was spent.
    rv_ok = xsdbool( iv_absorbed > iv_actual ).
  ENDMETHOD.

ENDCLASS.
