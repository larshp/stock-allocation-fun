INTERFACE zif_allocation_authorization PUBLIC.
  METHODS is_authorized
    RETURNING
      VALUE(rv_authorized) TYPE abap_bool.
ENDINTERFACE.
