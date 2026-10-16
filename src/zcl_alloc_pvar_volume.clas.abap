CLASS zcl_alloc_pvar_volume DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS volume_variance
      IMPORTING
        iv_actual_qty      TYPE i
        iv_budget_qty      TYPE i
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


CLASS zcl_alloc_pvar_volume IMPLEMENTATION.

  METHOD volume_variance.
    DATA lv_diff TYPE i.

    " A volume variance is the output difference at the standard price.
    lv_diff = iv_actual_qty - iv_budget_qty.
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
