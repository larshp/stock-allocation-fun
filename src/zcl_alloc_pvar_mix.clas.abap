CLASS zcl_alloc_pvar_mix DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS mix_variance
      IMPORTING
        iv_total_variance  TYPE i
        iv_volume_variance TYPE i
      RETURNING
        VALUE(rv_variance) TYPE i.

    METHODS is_adverse
      IMPORTING
        iv_variance  TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS delta
      IMPORTING
        iv_first        TYPE i
        iv_second       TYPE i
      RETURNING
        VALUE(rv_delta) TYPE i.

ENDCLASS.


CLASS zcl_alloc_pvar_mix IMPLEMENTATION.

  METHOD mix_variance.
    " The mix variance is what is left of the total after volume.
    rv_variance = iv_total_variance - iv_volume_variance.
  ENDMETHOD.

  METHOD is_adverse.
    " The variance is adverse once it costs more than planned.
    rv_ok = xsdbool( iv_variance > 0 ).
  ENDMETHOD.

  METHOD delta.
    " The delta is the first amount less the second one.
    rv_delta = iv_first - iv_second.
  ENDMETHOD.

ENDCLASS.
