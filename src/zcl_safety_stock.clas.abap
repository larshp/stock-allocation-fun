CLASS zcl_safety_stock DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_safety_stock.

ENDCLASS.


CLASS zcl_safety_stock IMPLEMENTATION.

  METHOD zif_safety_stock~read.
    SELECT lgort,
           qty
      FROM zsafetystk
      INTO TABLE @DATA(lt_config)
      WHERE matnr = @iv_matnr
        AND werks = @iv_werks
      ORDER BY lgort.

    LOOP AT lt_config INTO DATA(ls_config).
      APPEND VALUE #( lgort = ls_config-lgort
                      qty   = ls_config-qty ) TO rt_config.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
