CLASS zcl_alloc_config DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_alloc_config.

    "! ZSTOCK_ALLOC_CFG-STRATEGY: distribute as a fair share. Anything else,
    "! including a plant with no setting at all, is served by priority.
    CONSTANTS c_fair_share TYPE zstock_alloc_cfg-strategy VALUE 'F'.

    "! What a plant that nobody has configured gets: everything off, which is
    "! what the report parameters defaulted to before there was a table.
    CONSTANTS c_default_keep_days TYPE i VALUE 90.

    "! A share of the pool cannot be more than the whole of it.
    CONSTANTS c_max_percent TYPE i VALUE 100.

ENDCLASS.


CLASS zcl_alloc_config IMPLEMENTATION.

  METHOD zif_alloc_config~for_plant.

    rs_config-werks     = iv_werks.
    rs_config-keep_days = c_default_keep_days.

    SELECT SINGLE strategy,
                  horizon_days,
                  lgort,
                  cap_percent,
                  keep_days
      FROM zstock_alloc_cfg
      WHERE werks = @iv_werks
      INTO @DATA(ls_row).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    rs_config-fair_share = xsdbool( ls_row-strategy = c_fair_share ).
    rs_config-lgort      = ls_row-lgort.

    " a setting that cannot be honoured is corrected rather than obeyed: none
    " of these has a sensible meaning below zero, and a nightly run must not
    " stop because somebody typed a minus
    IF ls_row-horizon_days > 0.
      rs_config-horizon_days = ls_row-horizon_days.
    ENDIF.

    IF ls_row-cap_percent > 0.
      rs_config-cap_percent = COND #( WHEN ls_row-cap_percent > c_max_percent
                                      THEN c_max_percent
                                      ELSE ls_row-cap_percent ).
    ENDIF.

    " zero days is a real answer here, meaning keep nothing beyond today, so
    " the default only applies where the plant has no row at all
    IF ls_row-keep_days >= 0.
      rs_config-keep_days = ls_row-keep_days.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
