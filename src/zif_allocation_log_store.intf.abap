INTERFACE zif_allocation_log_store PUBLIC.
  TYPES ty_current_entries TYPE STANDARD TABLE OF zstock_alog WITH EMPTY KEY.
  TYPES ty_history_entries TYPE STANDARD TABLE OF zstock_algh WITH EMPTY KEY.

  METHODS save
    IMPORTING
      it_current      TYPE ty_current_entries
      it_history      TYPE ty_history_entries
    RETURNING
      VALUE(rv_saved) TYPE abap_bool.
ENDINTERFACE.
