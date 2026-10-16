CLASS zcl_alloc_cv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_result,
             mean_x100 TYPE i,
             sd_x100   TYPE i,
             cv_x10000 TYPE i,
           END OF ty_result.

    METHODS calculate
      IMPORTING
        it_values        TYPE zcl_alloc_stddev=>ty_series_tt
      RETURNING
        VALUE(rs_result) TYPE ty_result.

    METHODS band_of
      IMPORTING
        iv_cv_x10000   TYPE i
      RETURNING
        VALUE(rv_band) TYPE string.

ENDCLASS.


CLASS zcl_alloc_cv IMPLEMENTATION.

  METHOD calculate.
    DATA lo_sd TYPE REF TO zcl_alloc_stddev.
    DATA ls_sd TYPE zcl_alloc_stddev=>ty_result.

    lo_sd = NEW zcl_alloc_stddev( ).
    ls_sd = lo_sd->calculate( it_values ).

    rs_result-sd_x100 = ls_sd-sd_x100.
    rs_result-mean_x100 = ls_sd-mean * 100.

    " Both values are zero for an empty series and a series without spread.
    IF ls_sd-mean <= 0 OR ls_sd-sd_x100 <= 0.
      RETURN.
    ENDIF.

    " cv = sd / mean, with both in hundredths, expressed in ten-thousandths.
    rs_result-cv_x10000 = ls_sd-sd_x100 * 10000 DIV rs_result-mean_x100.
  ENDMETHOD.

  METHOD band_of.
    IF iv_cv_x10000 < 1000.
      rv_band = 'low'.
    ELSEIF iv_cv_x10000 < 2500.
      rv_band = 'moderate'.
    ELSE.
      rv_band = 'high'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
