INTERFACE zif_allocation_history_reader PUBLIC.
  TYPES ty_entries TYPE STANDARD TABLE OF zstock_algh WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_result,
      is_success TYPE abap_bool,
      message    TYPE string,
      entries    TYPE ty_entries,
    END OF ty_result.

  METHODS read
    IMPORTING
      iv_from_date     TYPE d
      iv_to_date       TYPE d
      iv_request_id    TYPE zstock_algh-request_id OPTIONAL
      iv_run_mode      TYPE zstock_algh-run_mode OPTIONAL
      iv_run_id        TYPE zstock_algh-run_id OPTIONAL
      iv_max_rows      TYPE i
    RETURNING
      VALUE(rs_result) TYPE ty_result.
ENDINTERFACE.
