INTERFACE zif_priority_authorization PUBLIC.
  TYPES ty_activity TYPE c LENGTH 2.
  METHODS is_authorized
    IMPORTING
      iv_activity          TYPE ty_activity
    RETURNING
      VALUE(rv_authorized) TYPE abap_bool.
ENDINTERFACE.
