CLASS zcl_alloc_pvar_price DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS price_variance
      IMPORTING
        iv_actual_price    TYPE i
        iv_standard_price  TYPE i
        iv_actual_qty      TYPE i
      RETURNING
        VALUE(rv_variance) TYPE i.

    METHODS is_adverse
      IMPORTING
        iv_variance  TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS sign_of
      IMPORTING
        iv_variance      TYPE i
      RETURNING
        VALUE(rv_choice) TYPE string.

ENDCLASS.


CLASS zcl_alloc_pvar_price IMPLEMENTATION.

  METHOD price_variance.
    DATA lv_diff TYPE i.

    " A price variance is the price difference at the actual quantity.
    lv_diff = iv_actual_price - iv_standard_price.
    rv_variance = lv_diff * iv_actual_qty.
  ENDMETHOD.

  METHOD is_adverse.
    " The variance is adverse once it costs more than planned.
    rv_ok = xsdbool( iv_variance > 0 ).
  ENDMETHOD.

  METHOD sign_of.
    " The variance reads adverse, favourable or none.
    IF iv_variance > 0.
      rv_choice = 'ADVERSE'.
    ELSEIF iv_variance < 0.
      rv_choice = 'FAVOURABLE'.
    ELSE.
      rv_choice = 'NONE'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
