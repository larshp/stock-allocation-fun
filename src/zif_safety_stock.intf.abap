INTERFACE zif_safety_stock
  PUBLIC.

  TYPES: BEGIN OF ty_config,
           lgort TYPE lgort_d,
           qty   TYPE menge_d,
         END OF ty_config.

  TYPES ty_config_tt TYPE STANDARD TABLE OF ty_config WITH DEFAULT KEY.

  METHODS read
    IMPORTING
      iv_matnr         TYPE matnr
      iv_werks         TYPE werks_d
    RETURNING
      VALUE(rt_config) TYPE ty_config_tt.

ENDINTERFACE.
