CLASS zcl_alloc_pvar_usage DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS usage_variance
      IMPORTING
        iv_actual_qty      TYPE i
        iv_standard_qty    TYPE i
        iv_standard_price  TYPE i
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


CLASS zcl_alloc_pvar_usage IMPLEMENTATION.

  METHOD usage_variance.
    DATA lv_diff TYPE i.

    " A usage variance is the quantity difference at the standard price.
    lv_diff = iv_actual_qty - iv_standard_qty.
    rv_variance = lv_diff * iv_standard_price.
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
